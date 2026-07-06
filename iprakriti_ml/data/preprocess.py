"""
IPrakriti — Data Preprocessing Pipeline (Real Data Version)
=============================================================
Matched exactly to the Google Form CSV exported from IPrakriti – AI Dataset
Collection Form (112 responses as of June 2026).

Usage:
    python data/preprocess.py                        # auto-finds CSV in data/raw/
    python data/preprocess.py --input path/to/file.csv
    python data/preprocess.py --dummy               # 300 synthetic samples
"""

import argparse
import os
import sys
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

# ---------------------------------------------------------------------------
# PATHS
# ---------------------------------------------------------------------------
RAW_DIR       = os.path.join(os.path.dirname(__file__), "raw")
PROCESSED_DIR = os.path.join(os.path.dirname(__file__), "processed")
os.makedirs(PROCESSED_DIR, exist_ok=True)

# ---------------------------------------------------------------------------
# EXACT column names as they appear in your Google Form CSV export.
# NOTE: some columns have trailing spaces — kept intentionally to match CSV.
# ---------------------------------------------------------------------------

# Columns to DROP (metadata, images, consent — not used for ML)
DROP_COLUMNS = [
    "Timestamp",
    "Email address",
    "Mandatory for legal compliance.",
    "Date",
    "Upload Front Face Image",
    "Upload Left Face Image",
    "Upload Right Face Image",
    "Was your Prakriti confirmed by an Ayurvedic doctor?",
]

# The 25 feature columns (exact names including trailing spaces from CSV)
FEATURE_COLUMNS = [
    "Eyes_Colour",
    "Lips_Texture",
    "Lips_Thickness ",          # trailing space — matches CSV exactly
    "Lips_Color ",              # trailing space
    "Face_Color ",              # trailing space
    "Face_Texture ",            # trailing space
    "Skin_Color ",              # trailing space
    "Hair_Color ",              # trailing space
    "Hair_Texture ",            # trailing space
    "Forehead_Size \n(How to measure- keep your fingers horizontally on the forehead)\n",
    "Appetite\n\nHabit-if meal is skipped/meal timings are changed/style of food is changed",
    "If_meal_is_skipped_what_changes_occurs",
    "Stool_consistency",
    "  Sleep  ",                # leading+trailing spaces — matches CSV exactly
    "Work_Duration / Capacity ",
    "Excitement_Response ",
    "Working_Style ",
    "Body_Movements ",
    "Strength ",
    "Problem_Handling ",
    "Control_on_Desires ",
    "Concentration ",
    "Grasping_Power ",
    "Storage ",
    "Memory ",
]

# Short names used in model (same order as FEATURE_COLUMNS)
FEATURE_SHORT_NAMES = [
    "Eyes_Colour",
    "Lips_Texture",
    "Lips_Thickness",
    "Lips_Color",
    "Face_Color",
    "Face_Texture",
    "Skin_Color",
    "Hair_Color",
    "Hair_Texture",
    "Forehead_Size",
    "Appetite",
    "Meal_Skip_Response",
    "Stool_Consistency",
    "Sleep",
    "Work_Capacity",
    "Excitement_Response",
    "Working_Style",
    "Body_Movements",
    "Strength",
    "Problem_Handling",
    "Control_on_Desires",
    "Concentration",
    "Grasping_Power",
    "Storage",
    "Memory",
]

# Demographic columns (included as extra features — optional but helpful)
DEMO_COLUMNS = ["Age", "Gender"]

# Target column (the Prakriti label filled in by Ayurvedic experts/self-assessed)
TARGET_COLUMN = "Skip if unsure, this is only for users already assessed by an Ayurvedic doctor."

# ---------------------------------------------------------------------------
# ANSWER → NUMBER ENCODING
# Ayurvedic mapping: Vata=0, Pitta=1, Kapha=2
# Dual/mixed answers → nearest single or average
# ---------------------------------------------------------------------------
ANSWER_ENCODINGS = {
    "Eyes_Colour": {
        "Blackish": 0,             # Vata (dark, small)
        "Reddish/Brown": 1,        # Pitta (sharp, reddish)
        "Milky/WhitishEdges": 2,   # Kapha (white, large)
    },
    "Lips_Texture": {
        "Cracked / Shapeless": 0,              # Vata
        "Smooth, Soft, Thin": 1,               # Pitta
        "Smooth, Glossy, Proportionate": 2,    # Kapha
        "Smooth, Glossy": 2,                   # Kapha variant
    },
    "Lips_Thickness": {
        "Thin": 0,          # Vata
        "Medium": 1,        # Pitta
        "Broad / Large": 2, # Kapha
    },
    "Lips_Color": {
        "Blackish": 0,  # Vata
        "Reddish": 1,   # Pitta
        "Pinkish": 2,   # Kapha
    },
    "Face_Color": {
        "Blackish": 0,  # Vata
        "Reddish": 1,   # Pitta
        "Pinkish": 2,   # Kapha
    },
    "Face_Texture": {
        "Cracky / Rough": 0,                    # Vata
        "Soft, Oily, Pimples/Freckles": 1,     # Pitta
        "Smooth, Glossy": 2,                    # Kapha
        "Smooth, Glossy, Proportionate": 2,     # Kapha variant
    },
    "Skin_Color": {
        "Blackish tinge": 0,    # Vata (dark)
        "Yellowish tinge": 1,   # Pitta (yellowish)
        "Fair/Light tinge": 2,  # Kapha (fair/light)
        "Blackish": 0,          # Vata variant
    },
    "Hair_Color": {
        "Black": 0,         # Vata (dry black)
        "Gray / Brown": 1,  # Pitta (lighter)
        "Black(Shiny)": 2,  # Kapha (shiny black)
    },
    "Hair_Texture": {
        "Rough & Dry": 0,   # Vata
        "Soft & Delicate": 1, # Pitta
        "Soft & Shiny": 2,  # Kapha
    },
    "Forehead_Size": {
        "Narrow(<4 fingers)": 0,    # Vata
        "Medium (=4 fingers)": 1,   # Pitta
        "Broad (>4 fingers)": 2,    # Kapha
    },
    "Appetite": {
        "Variable / Irregular (Vata)": 0,       # Vata
        "Strong / Sharp appetite (Pitta)": 1,   # Pitta
        "Slow / Low appetite (Kapha)": 2,       # Kapha
    },
    "Meal_Skip_Response": {
        "Constipation": 0,                              # Vata
        "Headache /vomitting": 1,                       # Pitta
        "Mild discomfort or no change (Kapha)": 2,     # Kapha
    },
    "Stool_Consistency": {
        "Hard": 0,          # Vata
        "Semisolid": 1,     # Pitta (loose/fast)
        "Well formed": 2,   # Kapha (regular, heavy)
    },
    "Sleep": {
        "Interrupted / <6 hrs": 0,              # Vata
        "6–8 hrs": 1,                           # Pitta (note: en-dash)
        "6-8 hrs": 1,                           # Pitta (hyphen variant)
        "More than 8 hrs, sound sleep (Kapha)": 2,  # Kapha
    },
    "Work_Capacity": {
        "Less": 0,      # Vata (low endurance)
        "Medium": 1,    # Pitta
        "More": 2,      # Kapha (high endurance)
    },
    "Excitement_Response": {
        "Quick, cools quickly": 0,  # Vata (quick, unstable)
        "Quick, slow to cool": 1,   # Pitta (intense, slow to calm)
        "Rare": 2,                  # Kapha (stable, rarely excited)
    },
    "Working_Style": {
        "Quick": 0,     # Vata
        "Medium": 1,    # Pitta
        "Slow": 2,      # Kapha
    },
    "Body_Movements": {
        "Fast, unnecessary": 0,  # Vata
        "Moderate": 1,           # Pitta
        "Slow, steady": 2,       # Kapha
    },
    "Strength": {
        "Less, fatigues easily": 0, # Vata
        "Moderate": 1,              # Pitta
        "Good": 2,                  # Kapha
    },
    "Problem_Handling": {
        "Worrying": 0,          # Vata (anxiety)
        "Irritable / Angry": 1, # Pitta (anger)
        "Calm & Stable": 2,     # Kapha (calm)
    },
    "Control_on_Desires": {
        "Poor": 0,      # Vata
        "Moderate": 1,  # Pitta
        "Good": 2,      # Kapha
    },
    "Concentration": {
        "Poor": 0,              # Vata
        "Good on interest": 1,  # Pitta
        "Excellent": 2,         # Kapha
    },
    "Grasping_Power": {
        "Slow to grasp": 0,             # Vata (slow but retains)
        "Quick but poor retention": 1,  # Pitta
        "Quick and good retention": 2,  # Kapha
    },
    "Storage": {
        "Poor": 0,      # Vata
        "Average": 1,   # Pitta
        "Good": 2,      # Kapha
    },
    "Memory": {
        "Poor": 0,      # Vata
        "Average": 1,   # Pitta
        "Good": 2,      # Kapha
    },
}

# ---------------------------------------------------------------------------
# PRAKRITI LABEL ENCODING
# Handles all label variations found in your actual data
# ---------------------------------------------------------------------------
LABEL_ENCODING = {
    # Pure doshas — all case/spelling variants found in real data
    "Vata dominant": 0,
    "Vata Dominant": 0,
    "Vata": 0,
    "Pitta dominant": 1,
    "Pitta Dominant": 1,
    "Pitta": 1,
    "Kapha dominant": 2,
    "Kapha Dominant": 2,
    "Kapha": 2,

    # Vata-Pitta variants
    "Vata-Pitta dominant": 3,
    "Vata-Pitta Dominant": 3,
    "Vata-Pitta": 3,
    "Vata Pitta dominant": 3,
    "Vata Pitta Dominant": 3,
    "Pitta-Vata dominant": 3,       # reversed order
    "Pitta-Vata Dominant": 3,
    "Pitta-vata dominant": 3,
    "Pitta vata dominant": 3,
    "Pitta Vata dominant": 3,
    "Pitta Vata Dominant": 3,

    # Pitta-Kapha variants
    "Pitta-Kapha dominant": 4,
    "Pitta-Kapha Dominant": 4,
    "Pitta-Kapha": 4,
    "Pitta Kapha dominant": 4,
    "Pitta Kapha Dominant": 4,
    "Pitta kapha dominant": 4,
    "Pitta-kapha Dominant": 4,
    "Pitta-kapha dominant": 4,
    "Kapha-Pitta dominant": 4,      # reversed order
    "Kapha-Pitta Dominant": 4,
    "Kapha Pitta dominant": 4,
    "Kapha Pitta Dominant": 4,

    # Vata-Kapha variants
    "Vata-Kapha dominant": 5,
    "Vata-Kapha Dominant": 5,
    "Vata-Kapha": 5,
    "Vata Kapha dominant": 5,
    "Vata Kapha Dominant": 5,
    "Kapha-Vata dominant": 5,       # reversed order
    "Kapha-Vata Dominant": 5,
    "Kapha Vata dominant": 5,
    "Kapha Vata Dominant": 5,

    # Tridosha variants
    "Tridosha / Balanced": 6,
    "Tridosha": 6,
    "Tridosha dominant": 6,
    "Tridosha Dominant": 6,
    "Balanced": 6,
}

LABEL_DECODING = {v: k for k, v in {
    0: "Vata", 1: "Pitta", 2: "Kapha",
    3: "Vata-Pitta", 4: "Pitta-Kapha",
    5: "Vata-Kapha", 6: "Tridosha",
}.items()}

# ---------------------------------------------------------------------------
# SYNTHETIC DATA GENERATOR (fallback for testing)
# ---------------------------------------------------------------------------

def generate_dummy_data(n_samples: int = 300, random_state: int = 42) -> pd.DataFrame:
    rng = np.random.default_rng(random_state)
    labels = [0, 1, 2, 3, 4, 5, 6]
    weights = [0.12, 0.20, 0.08, 0.28, 0.14, 0.12, 0.06]
    chosen = rng.choice(labels, size=n_samples, p=weights)

    # Dosha → answer bias per feature (0=Vata, 1=Pitta, 2=Kapha)
    bias_map = {
        0: [0]*25, 1: [1]*25, 2: [2]*25,
        3: [rng.choice([0,1]) for _ in range(25)],
        4: [rng.choice([1,2]) for _ in range(25)],
        5: [rng.choice([0,2]) for _ in range(25)],
        6: [rng.choice([0,1,2]) for _ in range(25)],
    }
    rows = []
    for label in chosen:
        bias = bias_map[label]
        answers = [b if rng.random() < 0.72 else int(rng.integers(0,3)) for b in bias]
        row = dict(zip(FEATURE_SHORT_NAMES, answers))
        row["Age"] = int(rng.integers(18, 50))
        row["Gender"] = rng.choice([0, 1])
        row["Prakriti_Label"] = label
        rows.append(row)

    return pd.DataFrame(rows)


# ---------------------------------------------------------------------------
# REAL DATA LOADER & ENCODER
# ---------------------------------------------------------------------------

def load_and_encode_real_data(csv_path: str) -> pd.DataFrame:
    print(f"  Loading: {csv_path}")
    df = pd.read_csv(csv_path)
    print(f"  Raw shape: {df.shape}")
    print(f"  Columns ({len(df.columns)}): found in CSV")

    # ── 1. Extract & encode target label ──────────────────────────────────
    if TARGET_COLUMN not in df.columns:
        raise ValueError(
            f"\n❌ Target column not found!\n"
            f"   Expected: {repr(TARGET_COLUMN)}\n"
            f"   Found: {list(df.columns)}"
        )

    raw_labels = df[TARGET_COLUMN].astype(str).str.strip()
    df["Prakriti_Label"] = raw_labels.map(LABEL_ENCODING)

    # Show which labels couldn't be mapped
    unmapped_labels = raw_labels[df["Prakriti_Label"].isna()].unique()
    if len(unmapped_labels) > 0:
        safe = [v for v in unmapped_labels if v not in ("nan", "", "Not sure")]
        if safe:
            print(f"\n  ⚠️  Unmapped labels (will be dropped): {safe}")

    # Drop rows with no label (blank, "Not sure", or unmapped)
    before = len(df)
    df = df.dropna(subset=["Prakriti_Label"])
    dropped = before - len(df)
    if dropped > 0:
        print(f"  ℹ️  Dropped {dropped} rows without a valid Prakriti label")
    print(f"  ✅ Labeled rows remaining: {len(df)}")

    df["Prakriti_Label"] = df["Prakriti_Label"].astype(int)

    # ── 2. Encode feature columns ─────────────────────────────────────────
    encoded_rows = []
    for _, row in df.iterrows():
        encoded = {}
        for col_csv, col_short in zip(FEATURE_COLUMNS, FEATURE_SHORT_NAMES):
            raw_val = str(row.get(col_csv, "")).strip()
            mapping = ANSWER_ENCODINGS.get(col_short, {})
            encoded[col_short] = mapping.get(raw_val, np.nan)
        encoded["Prakriti_Label"] = row["Prakriti_Label"]
        encoded_rows.append(encoded)

    encoded_df = pd.DataFrame(encoded_rows)

    # ── 3. Handle unmapped answers ────────────────────────────────────────
    for col in FEATURE_SHORT_NAMES:
        n_nan = encoded_df[col].isna().sum()
        if n_nan > 0:
            median_val = encoded_df[col].median()
            print(f"  ⚠️  {col}: {n_nan} unmapped answers → filled with median ({median_val:.0f})")
            encoded_df[col] = encoded_df[col].fillna(median_val)
        encoded_df[col] = encoded_df[col].astype(int)

    return encoded_df


# ---------------------------------------------------------------------------
# MAIN PIPELINE
# ---------------------------------------------------------------------------

def run_pipeline(csv_path: str | None = None, dummy: bool = False) -> dict:
    print("=" * 58)
    print("  IPrakriti — Preprocessing Pipeline (Real Data)")
    print("=" * 58)

    if dummy:
        print("\n📋 Mode: SYNTHETIC (dummy) — 300 samples")
        df = generate_dummy_data(n_samples=300)
        feature_cols = FEATURE_SHORT_NAMES
    else:
        # Auto-find CSV in data/raw/ if not specified
        if csv_path is None:
            csvs = [f for f in os.listdir(RAW_DIR) if f.endswith(".csv")]
            if not csvs:
                raise FileNotFoundError(
                    f"No CSV found in {RAW_DIR}.\n"
                    "Drop your Google Form export there and re-run."
                )
            csv_path = os.path.join(RAW_DIR, csvs[0])

        print(f"\n📂 Loading real data...")
        df = load_and_encode_real_data(csv_path)
        feature_cols = FEATURE_SHORT_NAMES

    print(f"\n📊 Dataset: {len(df)} rows × {len(feature_cols)} features")

    # Label distribution
    label_counts = df["Prakriti_Label"].value_counts().sort_index()
    print("\n📈 Prakriti label distribution:")
    for code, count in label_counts.items():
        name = LABEL_DECODING.get(int(code), f"Unknown({code})")
        bar = "█" * count
        print(f"   {name:<15} {count:>3}  {bar}")

    X = df[feature_cols].values
    y = df["Prakriti_Label"].values

    # Stratified 80/20 split
    # If any class has < 2 samples, can't stratify — fall back to random
    min_class = min(np.bincount(y))
    stratify = y if min_class >= 2 else None
    if stratify is None:
        print("\n⚠️  Some classes have < 2 samples — splitting without stratify")

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.20, random_state=42, stratify=stratify
    )

    print(f"\n✂️  Train/test split (80/20):")
    print(f"   Train: {len(X_train)} samples")
    print(f"   Test : {len(X_test)} samples")

    # Save processed CSVs
    train_df = pd.DataFrame(X_train, columns=feature_cols)
    train_df["Prakriti_Label"] = y_train
    test_df = pd.DataFrame(X_test, columns=feature_cols)
    test_df["Prakriti_Label"] = y_test

    train_path = os.path.join(PROCESSED_DIR, "train.csv")
    test_path  = os.path.join(PROCESSED_DIR, "test.csv")
    train_df.to_csv(train_path, index=False)
    test_df.to_csv(test_path,  index=False)

    print(f"\n💾 Saved processed data:")
    print(f"   {train_path}")
    print(f"   {test_path}")
    print("\n✅ Preprocessing complete!\n")

    return {
        "X_train": X_train, "X_test": X_test,
        "y_train": y_train, "y_test": y_test,
        "feature_names": feature_cols,
        "label_decoding": LABEL_DECODING,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dummy", action="store_true")
    parser.add_argument("--input", type=str)
    args = parser.parse_args()
    run_pipeline(csv_path=args.input, dummy=args.dummy)
    
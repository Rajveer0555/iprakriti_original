"""
IPrakriti — Model Training Script (Real Data Version)
=======================================================
Usage:
    python model/train.py                    # train on CSV in data/raw/
    python model/train.py --dummy            # train on synthetic data
    python model/train.py --input file.csv   # custom CSV path
"""

import argparse
import json
import os
import sys
import joblib
import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from data.preprocess import run_pipeline, LABEL_DECODING

MODEL_DIR  = os.path.dirname(__file__)
MODEL_PATH = os.path.join(MODEL_DIR, "prakriti_model.pkl")
META_PATH  = os.path.join(MODEL_DIR, "model_meta.json")


def train(dummy: bool = False, csv_path: str | None = None):
    print("=" * 58)
    print("  IPrakriti — Model Training")
    print("=" * 58)

    data    = run_pipeline(csv_path=csv_path, dummy=dummy)
    X_train = data["X_train"]
    y_train = data["y_train"]
    X_test  = data["X_test"]
    y_test  = data["y_test"]

    # ── SMOTE for class imbalance ─────────────────────────────────────────
    print("⚖️  Applying SMOTE to balance classes...")
    try:
        from imblearn.over_sampling import SMOTE
        counts = np.bincount(y_train)
        k = min(5, min(counts[counts > 0]) - 1)
        if k >= 1:
            X_train, y_train = SMOTE(random_state=42, k_neighbors=k).fit_resample(X_train, y_train)
            print(f"   After SMOTE: {len(X_train)} training samples")
        else:
            print("   Skipped (need ≥2 samples per class)")
    except Exception as e:
        print(f"   Skipped: {e}")

    # ── Build pipeline ────────────────────────────────────────────────────
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.pipeline import Pipeline
    from sklearn.preprocessing import StandardScaler

    pipeline = Pipeline([
        ("scaler", StandardScaler()),
        ("clf", RandomForestClassifier(
            n_estimators=300,
            max_depth=None,
            min_samples_split=2,
            class_weight="balanced",
            random_state=42,
            n_jobs=-1,
        )),
    ])

    print("\n🌲 Training RandomForestClassifier (300 trees)...")
    pipeline.fit(X_train, y_train)

    # ── Evaluate ──────────────────────────────────────────────────────────
    from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

    y_pred   = pipeline.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    present  = sorted(set(y_test))
    names    = [LABEL_DECODING.get(i, str(i)) for i in present]

    print(f"\n📊 Test accuracy: {accuracy * 100:.1f}%")

    if accuracy >= 0.85:
        print("   🟢 Excellent — ready for production")
    elif accuracy >= 0.70:
        print("   🟡 Good — acceptable for beta")
    elif accuracy >= 0.55:
        print("   🟠 Fair — consider collecting more data")
    else:
        print("   🔴 Low — review label quality or add more samples")

    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, labels=present,
                                target_names=names, zero_division=0))

    # Feature importance
    rf = pipeline.named_steps["clf"]
    importances = rf.feature_importances_
    feature_names = data["feature_names"]
    top_idx = np.argsort(importances)[::-1][:10]
    print("🔍 Top 10 most predictive features:")
    for rank, idx in enumerate(top_idx, 1):
        bar = "█" * int(importances[idx] * 200)
        print(f"   {rank:>2}. {feature_names[idx]:<30} {importances[idx]:.4f}  {bar}")

    # ── Save ──────────────────────────────────────────────────────────────
    joblib.dump(pipeline, MODEL_PATH)
    print(f"\n💾 Model saved: {MODEL_PATH}")

    meta = {
        "accuracy": round(float(accuracy), 4),
        "n_train_samples": len(X_train),
        "n_test_samples": len(X_test),
        "n_features": len(feature_names),
        "n_classes": len(present),
        "classes": names,
        "top_features": [feature_names[i] for i in top_idx],
        "trained_on_dummy": dummy,
    }
    with open(META_PATH, "w") as f:
        json.dump(meta, f, indent=2)
    print(f"   Metadata saved: {META_PATH}")

    if dummy:
        print("\n⚠️  Trained on SYNTHETIC data.")
        print("   Re-run without --dummy once real CSV is in data/raw/")

    print("\n✅ Training complete!\n")
    return pipeline, meta


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dummy", action="store_true")
    parser.add_argument("--input", type=str)
    args = parser.parse_args()
    train(dummy=args.dummy, csv_path=args.input)

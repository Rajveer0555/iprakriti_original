"""
IPrakriti — Model Training Script (Multi-Algorithm Version)
============================================================
Trains and compares multiple ML algorithms and saves the best one.

Usage:
    python model/train.py --input data/raw/prakriti_responses.xlsx           # tries all algorithms
    python model/train.py --input data/raw/prakriti_responses.xlsx --algo rf  # Random Forest only
    python model/train.py --input data/raw/prakriti_responses.xlsx --algo gb  # Gradient Boosting
    python model/train.py --input data/raw/prakriti_responses.xlsx --algo svm # SVM
    python model/train.py --input data/raw/prakriti_responses.xlsx --algo knn # KNN
    python model/train.py --input data/raw/prakriti_responses.xlsx --algo all # compare all
    python model/train.py --dummy                                              # synthetic data test
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

# ---------------------------------------------------------------------------
# ALGORITHM DEFINITIONS
# ---------------------------------------------------------------------------

def get_algorithms():
    from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
    from sklearn.svm import SVC
    from sklearn.neighbors import KNeighborsClassifier
    from sklearn.linear_model import LogisticRegression
    from sklearn.pipeline import Pipeline
    from sklearn.preprocessing import StandardScaler

    return {
        "rf": {
            "name": "Random Forest",
            "pipeline": Pipeline([
                ("scaler", StandardScaler()),
                ("clf", RandomForestClassifier(
                    n_estimators=300,
                    max_depth=None,
                    class_weight="balanced",
                    random_state=42,
                    n_jobs=-1,
                )),
            ]),
        },
        "gb": {
            "name": "Gradient Boosting",
            "pipeline": Pipeline([
                ("scaler", StandardScaler()),
                ("clf", GradientBoostingClassifier(
                    n_estimators=300,
                    learning_rate=0.05,
                    max_depth=4,
                    min_samples_split=4,
                    subsample=0.8,
                    random_state=42,
                )),
            ]),
        },
        "svm": {
            "name": "Support Vector Machine",
            "pipeline": Pipeline([
                ("scaler", StandardScaler()),
                ("clf", SVC(
                    kernel="rbf",
                    C=10,
                    gamma="scale",
                    class_weight="balanced",
                    probability=True,
                    random_state=42,
                )),
            ]),
        },
        "knn": {
            "name": "K-Nearest Neighbors",
            "pipeline": Pipeline([
                ("scaler", StandardScaler()),
                ("clf", KNeighborsClassifier(
                    n_neighbors=7,
                    weights="distance",
                    metric="euclidean",
                )),
            ]),
        },
        "lr": {
            "name": "Logistic Regression",
            "pipeline": Pipeline([
                ("scaler", StandardScaler()),
                ("clf", LogisticRegression(
                    C=1.0,
                    class_weight="balanced",
                    max_iter=1000,
                    random_state=42,
                    solver="lbfgs",
                )),
            ]),
        },
    }


# ---------------------------------------------------------------------------
# TRAINING
# ---------------------------------------------------------------------------

def train_single(pipeline, name, X_train, y_train, X_test, y_test, feature_names):
    from sklearn.metrics import accuracy_score, classification_report

    print(f"\n🔧 Training {name}...")
    pipeline.fit(X_train, y_train)

    y_pred   = pipeline.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    present  = sorted(set(y_test))
    names    = [LABEL_DECODING.get(i, str(i)) for i in present]

    print(f"   Accuracy: {accuracy * 100:.1f}%")
    print(classification_report(
        y_test, y_pred,
        labels=present,
        target_names=names,
        zero_division=0,
    ))

    return accuracy, pipeline


def train(dummy: bool = False, csv_path: str | None = None, algo: str = "all"):
    print("=" * 58)
    print("  IPrakriti — Model Training (Multi-Algorithm)")
    print("=" * 58)

    # ── Load data ─────────────────────────────────────────────────────────
    data     = run_pipeline(csv_path=csv_path, dummy=dummy)
    X_train  = data["X_train"]
    y_train  = data["y_train"]
    X_test   = data["X_test"]
    y_test   = data["y_test"]
    feature_names = data["feature_names"]

    # ── SMOTE ─────────────────────────────────────────────────────────────
    print("\n⚖️  Applying SMOTE to balance classes...")
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

    # ── Select algorithms ─────────────────────────────────────────────────
    all_algos = get_algorithms()

    if algo == "all":
        selected = all_algos
        print(f"\n🔬 Comparing all {len(selected)} algorithms...")
    elif algo in all_algos:
        selected = {algo: all_algos[algo]}
        print(f"\n🔬 Training: {all_algos[algo]['name']}")
    else:
        print(f"❌ Unknown algorithm '{algo}'. Choose from: rf, gb, svm, knn, lr, all")
        return

    # ── Train all selected ────────────────────────────────────────────────
    results = {}
    for key, config in selected.items():
        acc, fitted_pipeline = train_single(
            config["pipeline"], config["name"],
            X_train, y_train, X_test, y_test, feature_names
        )
        results[key] = {"name": config["name"], "accuracy": acc, "pipeline": fitted_pipeline}

    # ── Pick best ─────────────────────────────────────────────────────────
    best_key  = max(results, key=lambda k: results[k]["accuracy"])
    best      = results[best_key]
    best_acc  = best["accuracy"]
    best_pipe = best["pipeline"]

    print("\n" + "=" * 58)
    print("  📊 RESULTS SUMMARY")
    print("=" * 58)
    for key, r in sorted(results.items(), key=lambda x: -x[1]["accuracy"]):
        marker = " ← BEST" if key == best_key else ""
        bar = "█" * int(r["accuracy"] * 40)
        print(f"  {r['name']:<28} {r['accuracy']*100:>5.1f}%  {bar}{marker}")

    print(f"\n🏆 Best model: {best['name']} ({best_acc*100:.1f}%)")

    if best_acc >= 0.75:
        grade = "🟢 Excellent — ready for production"
    elif best_acc >= 0.60:
        grade = "🟡 Good — acceptable for beta"
    elif best_acc >= 0.50:
        grade = "🟠 Fair — usable but needs more data"
    else:
        grade = "🔴 Low — collect more Vata-Kapha samples"
    print(f"   {grade}")

    # ── Feature importance (RF/GB only) ───────────────────────────────────
    clf = best_pipe.named_steps["clf"]
    if hasattr(clf, "feature_importances_"):
        importances = clf.feature_importances_
        top_idx = np.argsort(importances)[::-1][:10]
        print("\n🔍 Top 10 most predictive features:")
        for rank, idx in enumerate(top_idx, 1):
            bar = "█" * int(importances[idx] * 200)
            print(f"   {rank:>2}. {feature_names[idx]:<30} {importances[idx]:.4f}  {bar}")

    # ── Save best model ───────────────────────────────────────────────────
    joblib.dump(best_pipe, MODEL_PATH)
    print(f"\n💾 Model saved: {MODEL_PATH}")

    meta = {
        "algorithm": best["name"],
        "accuracy": round(float(best_acc), 4),
        "n_train_samples": len(X_train),
        "n_test_samples": len(X_test),
        "n_features": len(feature_names),
        "n_classes": len(set(y_test)),
        "classes": [LABEL_DECODING.get(i, str(i)) for i in sorted(set(y_test))],
        "top_features": [feature_names[i] for i in np.argsort(
            clf.feature_importances_ if hasattr(clf, "feature_importances_")
            else np.ones(len(feature_names))
        )[::-1][:10]],
        "trained_on_dummy": dummy,
        "all_results": {k: {"name": v["name"], "accuracy": round(v["accuracy"], 4)}
                        for k, v in results.items()},
    }
    with open(META_PATH, "w") as f:
        json.dump(meta, f, indent=2)
    print(f"   Metadata saved: {META_PATH}")
    print("\n✅ Training complete!\n")

    return best_pipe, meta


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dummy", action="store_true")
    parser.add_argument("--input", type=str)
    parser.add_argument("--algo", type=str, default="all",
                        help="Algorithm: rf, gb, svm, knn, lr, all (default: all)")
    args = parser.parse_args()
    train(dummy=args.dummy, csv_path=args.input, algo=args.algo)
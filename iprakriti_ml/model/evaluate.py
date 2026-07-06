"""
IPrakriti — Model Evaluation Script
=====================================
Loads the saved model and runs detailed evaluation on the test set.
Run this any time after training to check how well the model is performing.

Usage:
    python model/evaluate.py
"""

import json
import os
import sys
import joblib
import numpy as np
import pandas as pd
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
)

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

MODEL_DIR      = os.path.dirname(__file__)
MODEL_PATH     = os.path.join(MODEL_DIR, "prakriti_model.pkl")
META_PATH      = os.path.join(MODEL_DIR, "model_meta.json")
PROCESSED_DIR  = os.path.join(MODEL_DIR, "..", "data", "processed")
TEST_CSV       = os.path.join(PROCESSED_DIR, "test.csv")

LABEL_DECODING = {
    0: "Vata", 1: "Pitta", 2: "Kapha",
    3: "Vata-Pitta", 4: "Pitta-Kapha",
    5: "Vata-Kapha", 6: "Tridosha",
}


def evaluate():
    print("=" * 55)
    print("  IPrakriti — Model Evaluation")
    print("=" * 55)

    # Load model
    if not os.path.exists(MODEL_PATH):
        print(f"\n❌ No model found at {MODEL_PATH}")
        print("   Run `python model/train.py --dummy` first.")
        return
    model = joblib.load(MODEL_PATH)
    print(f"\n✅ Model loaded from: {MODEL_PATH}")

    # Load metadata
    if os.path.exists(META_PATH):
        with open(META_PATH) as f:
            meta = json.load(f)
        print(f"\n📋 Model info:")
        print(f"   Trained on {'SYNTHETIC' if meta['trained_on_dummy'] else 'REAL'} data")
        print(f"   Training samples : {meta['n_train_samples']}")
        print(f"   Features         : {meta['n_features']}")
        print(f"   Classes          : {', '.join(meta['classes'])}")

    # Load test data
    if not os.path.exists(TEST_CSV):
        print(f"\n❌ No test data at {TEST_CSV}")
        print("   Run preprocessing first.")
        return

    df = pd.read_csv(TEST_CSV)
    feature_cols = [c for c in df.columns if c != "Prakriti_Label"]
    X_test = df[feature_cols].values
    y_test = df["Prakriti_Label"].values

    # Predict
    y_pred      = model.predict(X_test)
    y_proba     = model.predict_proba(X_test)
    accuracy    = accuracy_score(y_test, y_pred)
    present     = sorted(set(y_test))
    names       = [LABEL_DECODING.get(i, str(i)) for i in present]

    print(f"\n📊 Accuracy on test set: {accuracy * 100:.1f}%")

    # Interpret the score
    if accuracy >= 0.85:
        grade = "🟢 Excellent — ready for production"
    elif accuracy >= 0.75:
        grade = "🟡 Good — acceptable for beta testing"
    elif accuracy >= 0.60:
        grade = "🟠 Fair — more data or tuning needed"
    else:
        grade = "🔴 Poor — review data quality and labels"
    print(f"   {grade}")

    # Per-class report
    print(f"\nClassification Report:")
    print(classification_report(
        y_test, y_pred,
        labels=present,
        target_names=names,
        zero_division=0,
    ))

    # Confusion matrix
    print("Confusion Matrix (rows=actual, cols=predicted):")
    cm = confusion_matrix(y_test, y_pred, labels=present)
    header = "".join(f"{n[:8]:>10}" for n in names)
    print(f"{'':>14}{header}")
    for i, row in enumerate(cm):
        row_str = "".join(f"{v:>10}" for v in row)
        print(f"{names[i][:13]:<14}{row_str}")

    # Confidence analysis
    max_probas = y_proba.max(axis=1)
    print(f"\n🎯 Prediction confidence:")
    print(f"   Mean confidence  : {max_probas.mean() * 100:.1f}%")
    print(f"   Min confidence   : {max_probas.min() * 100:.1f}%")
    print(f"   Max confidence   : {max_probas.max() * 100:.1f}%")
    high_conf = (max_probas >= 0.80).sum()
    low_conf  = (max_probas < 0.50).sum()
    print(f"   High conf (≥80%) : {high_conf}/{len(y_test)} predictions")
    print(f"   Low conf  (<50%) : {low_conf}/{len(y_test)} predictions")

    # Worst predictions (most confused)
    wrong_mask = y_pred != y_test
    if wrong_mask.sum() > 0:
        print(f"\n❌ {wrong_mask.sum()} wrong predictions — common mistakes:")
        wrong_actual    = y_test[wrong_mask]
        wrong_predicted = y_pred[wrong_mask]
        from collections import Counter
        mistakes = Counter(zip(wrong_actual, wrong_predicted))
        for (actual, predicted), count in mistakes.most_common(5):
            print(f"   {LABEL_DECODING.get(actual, actual):>15} → predicted as "
                  f"{LABEL_DECODING.get(predicted, predicted):<15}  ({count}x)")

    print("\n✅ Evaluation complete!\n")


if __name__ == "__main__":
    evaluate()

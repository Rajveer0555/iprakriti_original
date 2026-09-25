"""
IPrakriti — FastAPI Prediction Server (Real Data Version)
==========================================================
Start with:
    cd api
    uvicorn main:app --reload --port 8000

Test at: http://localhost:8000/docs
"""

import json
import os
import joblib
import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from schemas import DoshaScore, ModelInfo, PrakritiInput, PrakritiResult

MODEL_DIR  = os.path.join(os.path.dirname(__file__), "..", "model")
MODEL_PATH = os.path.join(MODEL_DIR, "prakriti_model.pkl")
META_PATH  = os.path.join(MODEL_DIR, "model_meta.json")

LABEL_DECODING = {
    0: "Vata-Pitta",
    1: "Pitta-Kapha",
    2: "Vata-Kapha",
}

# Load model at startup
model      = None
model_meta = {}

if os.path.exists(MODEL_PATH):
    model = joblib.load(MODEL_PATH)
    print(f"✅ Model loaded from {MODEL_PATH}")
else:
    print(f"⚠️  No model found at {MODEL_PATH}")

if os.path.exists(META_PATH):
    with open(META_PATH) as f:
        model_meta = json.load(f)

app = FastAPI(
    title="IPrakriti ML API",
    description="Predicts Ayurvedic Prakriti (Vata-Pitta, Pitta-Kapha, Vata-Kapha) from a 25-feature assessment.",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/", tags=["Health"])
def health_check():
    return {
        "status": "ok",
        "model_loaded": model is not None,
        "algorithm": model_meta.get("algorithm", "unknown"),
        "accuracy": model_meta.get("accuracy", 0),
        "trained_on_dummy": model_meta.get("trained_on_dummy", True),
    }


@app.post("/predict", response_model=PrakritiResult, tags=["Prediction"])
def predict(data: PrakritiInput):
    """
    Predict Prakriti from 25 facial and behavioral features.
    Each answer: 0=Vata-type, 1=Pitta-type, 2=Kapha-type.
    Returns predicted dosha, confidence score, and all class probabilities.
    """
    if model is None:
        raise HTTPException(
            status_code=503,
            detail="Model not loaded. Run `python model/train.py --input data/raw/prakriti_responses.xlsx --algo all` first.",
        )

    try:
        features = np.array(data.to_feature_list()).reshape(1, -1)
        predicted_label = int(model.predict(features)[0])
        probabilities   = model.predict_proba(features)[0]
        classes         = model.classes_

        all_scores = [
            DoshaScore(
                dosha=LABEL_DECODING.get(int(cls), str(cls)),
                score=round(float(prob), 4),
            )
            for cls, prob in zip(classes, probabilities)
        ]
        all_scores.sort(key=lambda x: x.score, reverse=True)

        return PrakritiResult(
            predicted_prakriti=LABEL_DECODING.get(predicted_label, str(predicted_label)),
            confidence=round(float(probabilities.max()), 4),
            all_scores=all_scores,
            is_dummy_model=model_meta.get("trained_on_dummy", True),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


@app.get("/model/info", response_model=ModelInfo, tags=["Model"])
def model_info():
    if not model_meta:
        raise HTTPException(status_code=404, detail="Model metadata not found.")
    return ModelInfo(
        algorithm=model_meta.get("algorithm", "unknown"),
        accuracy=model_meta.get("accuracy", 0),
        n_train_samples=model_meta.get("n_train_samples", 0),
        n_features=model_meta.get("n_features", 0),
        classes=model_meta.get("classes", []),
        top_features=model_meta.get("top_features", []),
        trained_on_dummy=model_meta.get("trained_on_dummy", True),
    )
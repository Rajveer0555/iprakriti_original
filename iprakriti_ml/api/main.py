"""
IPrakriti — FastAPI Prediction Server
=======================================
Loads the trained model and exposes a REST API for the Flutter app.

Start with:
    uvicorn api.main:app --reload --port 8000

Then test at:
    http://localhost:8000/docs   ← interactive Swagger UI (test all endpoints here)
"""

import json
import os
import joblib
import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from schemas import DoshaScore, ModelInfo, PrakritiInput, PrakritiResult

# ---------------------------------------------------------------------------
# PATHS
# ---------------------------------------------------------------------------
MODEL_DIR  = os.path.join(os.path.dirname(__file__), "..", "model")
MODEL_PATH = os.path.join(MODEL_DIR, "prakriti_model.pkl")
META_PATH  = os.path.join(MODEL_DIR, "model_meta.json")

LABEL_DECODING = {
    0: "Vata", 1: "Pitta", 2: "Kapha",
    3: "Vata-Pitta", 4: "Pitta-Kapha",
    5: "Vata-Kapha", 6: "Tridosha",
}

# ---------------------------------------------------------------------------
# LOAD MODEL AT STARTUP
# ---------------------------------------------------------------------------
model = None
model_meta = {}

if os.path.exists(MODEL_PATH):
    model = joblib.load(MODEL_PATH)
    print(f"✅ Model loaded from {MODEL_PATH}")
else:
    print(f"⚠️  No model found at {MODEL_PATH}")
    print("   Run `python model/train.py --dummy` to create one.")

if os.path.exists(META_PATH):
    with open(META_PATH) as f:
        model_meta = json.load(f)

# ---------------------------------------------------------------------------
# APP
# ---------------------------------------------------------------------------
app = FastAPI(
    title="IPrakriti ML API",
    description="Predicts Ayurvedic Prakriti (dosha type) from a 35-question assessment.",
    version="1.0.0",
)

# Allow Flutter app (any origin during development) to call the API.
# In production, replace "*" with your actual Flutter app domain.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# ENDPOINTS
# ---------------------------------------------------------------------------

@app.get("/", tags=["Health"])
def health_check():
    """Quick health check — returns OK if server is running."""
    return {
        "status": "ok",
        "model_loaded": model is not None,
        "trained_on_dummy": model_meta.get("trained_on_dummy", True),
    }


@app.post("/predict", response_model=PrakritiResult, tags=["Prediction"])
def predict(data: PrakritiInput):
    """
    Predict Prakriti from 35 assessment answers.

    Each answer is 0, 1, or 2:
    - 0 = Vata-type response
    - 1 = Pitta-type response
    - 2 = Kapha-type response

    Returns the predicted dosha, confidence score, and probability breakdown.
    """
    if model is None:
        raise HTTPException(
            status_code=503,
            detail="Model not loaded. Run `python model/train.py --dummy` first.",
        )

    features = np.array(data.to_feature_list()).reshape(1, -1)

    # Predict
    predicted_label = int(model.predict(features)[0])
    probabilities   = model.predict_proba(features)[0]

    # Build per-class score list
    classes = model.classes_
    all_scores = [
        DoshaScore(
            dosha=LABEL_DECODING.get(int(cls), str(cls)),
            score=round(float(prob), 4),
        )
        for cls, prob in zip(classes, probabilities)
    ]
    # Sort descending by score
    all_scores.sort(key=lambda x: x.score, reverse=True)

    return PrakritiResult(
        predicted_prakriti=LABEL_DECODING.get(predicted_label, str(predicted_label)),
        confidence=round(float(probabilities.max()), 4),
        all_scores=all_scores,
        is_dummy_model=model_meta.get("trained_on_dummy", True),
    )


@app.get("/model/info", response_model=ModelInfo, tags=["Model"])
def model_info():
    """Returns metadata about the currently loaded model."""
    if not model_meta:
        raise HTTPException(status_code=404, detail="Model metadata not found.")
    return ModelInfo(**model_meta)

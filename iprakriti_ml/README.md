# IPrakriti ML Backend

AI model that predicts a user's Prakriti (Ayurvedic body type) from their
35-question assessment responses.

---

## Project Structure

```
iprakriti_ml/
├── data/
│   ├── raw/          ← drop the Google Form CSV export here
│   └── processed/    ← cleaned, encoded data (auto-generated)
├── notebooks/
│   └── eda.ipynb     ← exploratory data analysis
├── model/
│   ├── train.py      ← run this to train and save the model
│   ├── evaluate.py   ← run this to check accuracy and metrics
│   └── prakriti_model.pkl  ← saved model (auto-generated after training)
├── api/
│   ├── main.py       ← FastAPI server
│   └── schemas.py    ← request / response data shapes
├── requirements.txt
└── README.md
```

---

## Setup

```bash
# 1. Create a virtual environment
python -m venv venv
source venv/bin/activate        # Mac/Linux
venv\Scripts\activate           # Windows

# 2. Install dependencies
pip install -r requirements.txt
```

---

## Workflow

### While data is being collected
```bash
# Train on synthetic dummy data to verify the pipeline works
python model/train.py --dummy

# Start the API server (returns mock predictions)
uvicorn api.main:app --reload
```

### When real data arrives (Google Form CSV export)
```bash
# 1. Copy the CSV into data/raw/
cp ~/Downloads/prakriti_responses.csv data/raw/

# 2. Train on real data
python model/train.py

# 3. Check accuracy
python model/evaluate.py

# 4. Restart the API — it auto-loads the new model
uvicorn api.main:app --reload
```

---

## API Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `/` | Health check |
| POST | `/predict` | Predict Prakriti from 35 answers |
| GET | `/model/info` | Current model accuracy and metadata |

---

## Prakriti Labels

| Code | Dosha | Meaning |
|------|-------|---------|
| 0 | Vata | Air + Space dominant |
| 1 | Pitta | Fire + Water dominant |
| 2 | Kapha | Earth + Water dominant |
| 3 | Vata-Pitta | Dual: Air/Space + Fire/Water |
| 4 | Pitta-Kapha | Dual: Fire/Water + Earth/Water |
| 5 | Vata-Kapha | Dual: Air/Space + Earth/Water |
| 6 | Tridosha | All three in balance |

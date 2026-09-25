"""
IPrakriti — API Data Schemas (Real Data Version)
==================================================
Matches the 25 features from the actual Google Form dataset.
All answers are integers 0, 1, or 2.
"""

from pydantic import BaseModel, Field


class PrakritiInput(BaseModel):
    """
    25-feature Prakriti assessment input matched to real Google Form columns.
    Every answer: 0 = Vata-type, 1 = Pitta-type, 2 = Kapha-type
    """
    Eyes_Colour:           int = Field(..., ge=0, le=2)
    Lips_Texture:          int = Field(..., ge=0, le=2)
    Lips_Thickness:        int = Field(..., ge=0, le=2)
    Lips_Color:            int = Field(..., ge=0, le=2)
    Face_Color:            int = Field(..., ge=0, le=2)
    Face_Texture:          int = Field(..., ge=0, le=2)
    Skin_Color:            int = Field(..., ge=0, le=2)
    Hair_Color:            int = Field(..., ge=0, le=2)
    Hair_Texture:          int = Field(..., ge=0, le=2)
    Forehead_Size:         int = Field(..., ge=0, le=2)
    Appetite:              int = Field(..., ge=0, le=2)
    Meal_Skip_Response:    int = Field(..., ge=0, le=2)
    Stool_Consistency:     int = Field(..., ge=0, le=2)
    Sleep:                 int = Field(..., ge=0, le=2)
    Work_Capacity:         int = Field(..., ge=0, le=2)
    Excitement_Response:   int = Field(..., ge=0, le=2)
    Working_Style:         int = Field(..., ge=0, le=2)
    Body_Movements:        int = Field(..., ge=0, le=2)
    Strength:              int = Field(..., ge=0, le=2)
    Problem_Handling:      int = Field(..., ge=0, le=2)
    Control_on_Desires:    int = Field(..., ge=0, le=2)
    Concentration:         int = Field(..., ge=0, le=2)
    Grasping_Power:        int = Field(..., ge=0, le=2)
    Storage:               int = Field(..., ge=0, le=2)
    Memory:                int = Field(..., ge=0, le=2)

    def to_feature_list(self) -> list[int]:
        return [
            self.Eyes_Colour, self.Lips_Texture, self.Lips_Thickness,
            self.Lips_Color, self.Face_Color, self.Face_Texture,
            self.Skin_Color, self.Hair_Color, self.Hair_Texture,
            self.Forehead_Size, self.Appetite, self.Meal_Skip_Response,
            self.Stool_Consistency, self.Sleep, self.Work_Capacity,
            self.Excitement_Response, self.Working_Style, self.Body_Movements,
            self.Strength, self.Problem_Handling, self.Control_on_Desires,
            self.Concentration, self.Grasping_Power, self.Storage, self.Memory,
        ]


class DoshaScore(BaseModel):
    dosha: str
    score: float


class PrakritiResult(BaseModel):
    predicted_prakriti: str
    confidence:         float
    all_scores:         list[DoshaScore]
    is_dummy_model:     bool


class ModelInfo(BaseModel):
    algorithm:         str
    accuracy:          float
    n_train_samples:   int
    n_features:        int
    classes:           list[str]
    top_features:      list[str]
    trained_on_dummy:  bool
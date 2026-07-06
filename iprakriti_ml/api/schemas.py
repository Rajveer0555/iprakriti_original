"""
IPrakriti — API Data Schemas
==============================
Defines the shape of every request and response the FastAPI server handles.
All 35 question fields are declared here with valid ranges and descriptions.
"""

from pydantic import BaseModel, Field


class PrakritiInput(BaseModel):
    """
    35-question Prakriti assessment input.
    Every answer is an integer:
        0 = Vata-type answer
        1 = Pitta-type answer
        2 = Kapha-type answer
    """
    # Physical characteristics (Q1–Q9)
    Q1_Body_Frame:         int = Field(..., ge=0, le=2, description="Body frame: 0=Thin, 1=Medium, 2=Heavy")
    Q2_Body_Weight:        int = Field(..., ge=0, le=2, description="Weight tendency: 0=Low, 1=Moderate, 2=High")
    Q3_Skin_Texture:       int = Field(..., ge=0, le=2, description="Skin texture: 0=Dry, 1=Soft/Oily, 2=Thick/Moist")
    Q4_Skin_Color:         int = Field(..., ge=0, le=2, description="Skin color: 0=Dusky, 1=Fair/Reddish, 2=Pale")
    Q5_Hair_Type:          int = Field(..., ge=0, le=2, description="Hair: 0=Dry/Curly, 1=Straight/Fine, 2=Thick/Wavy")
    Q6_Hair_Color:         int = Field(..., ge=0, le=2, description="Hair color: 0=Black, 1=Brown/Red, 2=Dark/Oily")
    Q7_Eye_Size:           int = Field(..., ge=0, le=2, description="Eyes: 0=Small, 1=Medium/Sharp, 2=Large/Calm")
    Q8_Eye_Color:          int = Field(..., ge=0, le=2, description="Eye color: 0=Brown/Gray, 1=Green, 2=Dark Blue")
    Q9_Teeth_Size:         int = Field(..., ge=0, le=2, description="Teeth: 0=Irregular, 1=Medium/Sharp, 2=Large/White")

    # Digestive & metabolic (Q10–Q13)
    Q10_Appetite:          int = Field(..., ge=0, le=2, description="Appetite: 0=Irregular, 1=Strong, 2=Slow/Steady")
    Q11_Digestion:         int = Field(..., ge=0, le=2, description="Digestion: 0=Gassy, 1=Fast/Acidic, 2=Slow/Heavy")
    Q12_Bowel_Movement:    int = Field(..., ge=0, le=2, description="Bowel: 0=Dry, 1=Loose, 2=Regular/Heavy")
    Q13_Sweat:             int = Field(..., ge=0, le=2, description="Sweat: 0=Minimal, 1=Profuse, 2=Moderate")

    # Sleep & dreams (Q14–Q16)
    Q14_Sleep_Pattern:     int = Field(..., ge=0, le=2, description="Sleep: 0=Light, 1=Moderate, 2=Heavy/Deep")
    Q15_Sleep_Duration:    int = Field(..., ge=0, le=2, description="Duration: 0=Short, 1=Medium, 2=Long")
    Q16_Dream_Type:        int = Field(..., ge=0, le=2, description="Dreams: 0=Fearful, 1=Fiery, 2=Romantic/Water")

    # Mental & psychological (Q17–Q22)
    Q17_Memory:            int = Field(..., ge=0, le=2, description="Memory: 0=Quick forget, 1=Sharp, 2=Never forget")
    Q18_Speech:            int = Field(..., ge=0, le=2, description="Speech: 0=Fast, 1=Sharp, 2=Slow/Melodious")
    Q19_Mind_Nature:       int = Field(..., ge=0, le=2, description="Mind: 0=Restless, 1=Focused, 2=Calm")
    Q20_Stress_Response:   int = Field(..., ge=0, le=2, description="Stress: 0=Anxiety, 1=Anger, 2=Withdrawal")
    Q21_Emotional_Tendency:int = Field(..., ge=0, le=2, description="Emotion: 0=Enthusiastic, 1=Ambitious, 2=Calm")
    Q22_Decision_Making:   int = Field(..., ge=0, le=2, description="Decisions: 0=Indecisive, 1=Decisive, 2=Slow")

    # Behavioral & social (Q23–Q25)
    Q23_Work_Style:        int = Field(..., ge=0, le=2, description="Work: 0=Creative, 1=Organized, 2=Methodical")
    Q24_Financial_Tendency:int = Field(..., ge=0, le=2, description="Finance: 0=Impulsive, 1=Quality, 2=Saves")
    Q25_Social_Preference: int = Field(..., ge=0, le=2, description="Social: 0=Many, 1=Few close, 2=Loyal/Long-term")

    # Physical tendencies (Q26–Q28)
    Q26_Weather_Preference:int = Field(..., ge=0, le=2, description="Weather: 0=Dislikes cold, 1=Dislikes heat, 2=Dislikes damp")
    Q27_Exercise_Capacity: int = Field(..., ge=0, le=2, description="Exercise: 0=Low, 1=Moderate, 2=High endurance")
    Q28_Disease_Tendency:  int = Field(..., ge=0, le=2, description="Disease: 0=Nervous/Joints, 1=Inflammation, 2=Congestion")

    # Physical markers (Q29–Q35)
    Q29_Pulse_Nature:      int = Field(..., ge=0, le=2, description="Pulse: 0=Thin/Fast, 1=Strong, 2=Slow/Deep")
    Q30_Voice_Quality:     int = Field(..., ge=0, le=2, description="Voice: 0=Hoarse, 1=Sharp, 2=Deep/Melodious")
    Q31_Walk_Style:        int = Field(..., ge=0, le=2, description="Walk: 0=Fast/Irregular, 1=Purposeful, 2=Slow/Graceful")
    Q32_Hand_Nature:       int = Field(..., ge=0, le=2, description="Hands: 0=Dry/Cool, 1=Warm/Moist, 2=Thick/Cool")
    Q33_Nail_Type:         int = Field(..., ge=0, le=2, description="Nails: 0=Brittle, 1=Pink/Sharp, 2=Thick/Smooth")
    Q34_Tongue_Coating:    int = Field(..., ge=0, le=2, description="Tongue: 0=Thin/Gray, 1=Yellow/Red, 2=White/Thick")
    Q35_Prakriti_Self_Assessment: int = Field(..., ge=0, le=2, description="Self-assessment: 0=Vata, 1=Pitta, 2=Kapha")

    def to_feature_list(self) -> list[int]:
        """Returns answers as an ordered list matching QUESTION_COLUMNS in preprocess.py."""
        return [
            self.Q1_Body_Frame, self.Q2_Body_Weight, self.Q3_Skin_Texture,
            self.Q4_Skin_Color, self.Q5_Hair_Type, self.Q6_Hair_Color,
            self.Q7_Eye_Size, self.Q8_Eye_Color, self.Q9_Teeth_Size,
            self.Q10_Appetite, self.Q11_Digestion, self.Q12_Bowel_Movement,
            self.Q13_Sweat, self.Q14_Sleep_Pattern, self.Q15_Sleep_Duration,
            self.Q16_Dream_Type, self.Q17_Memory, self.Q18_Speech,
            self.Q19_Mind_Nature, self.Q20_Stress_Response,
            self.Q21_Emotional_Tendency, self.Q22_Decision_Making,
            self.Q23_Work_Style, self.Q24_Financial_Tendency,
            self.Q25_Social_Preference, self.Q26_Weather_Preference,
            self.Q27_Exercise_Capacity, self.Q28_Disease_Tendency,
            self.Q29_Pulse_Nature, self.Q30_Voice_Quality,
            self.Q31_Walk_Style, self.Q32_Hand_Nature, self.Q33_Nail_Type,
            self.Q34_Tongue_Coating, self.Q35_Prakriti_Self_Assessment,
        ]


class DoshaScore(BaseModel):
    dosha: str
    score: float = Field(..., description="Probability 0.0–1.0")


class PrakritiResult(BaseModel):
    predicted_prakriti: str   = Field(..., description="Predicted Prakriti type")
    confidence:         float = Field(..., description="Model confidence 0.0–1.0")
    all_scores:         list[DoshaScore] = Field(..., description="Probability for every dosha type")
    is_dummy_model:     bool  = Field(..., description="True if model trained on synthetic data")


class ModelInfo(BaseModel):
    accuracy:          float
    n_train_samples:   int
    n_features:        int
    classes:           list[str]
    top_features:      list[str]
    trained_on_dummy:  bool

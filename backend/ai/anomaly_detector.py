from sklearn.ensemble import IsolationForest
import numpy as np

class AnomalyDetector:

    def __init__(self):

        self.model = IsolationForest(
            contamination=0.02,
            random_state=42
        )

        train_data = np.random.rand(500, 5)

        self.model.fit(train_data)

    def predict(self, features):

        prediction = self.model.predict([features])[0]

        score = float(
            self.model.decision_function([features])[0]
        )

        return {
            "prediction":
                "anomaly"
                if prediction == -1
                else "normal",

            "score": round(score, 4)
        }

detector = AnomalyDetector()
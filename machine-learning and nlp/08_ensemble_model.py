"""
SACA ML Project - Ensemble Model (Combine RF + XGB + NN)
"""

import os
import joblib
import numpy as np
import xgboost as xgb
import tensorflow as tf

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, "models")


def load_models():
    rf = joblib.load(os.path.join(MODELS_DIR, "saca_triage_model_rf.pkl"))

    xgb_model = xgb.XGBClassifier()
    xgb_model.load_model(os.path.join(MODELS_DIR, "saca_triage_model_xgb.json"))

    nn = tf.keras.models.load_model(
        os.path.join(MODELS_DIR, "saca_triage_model_nn.h5")
    )

    return rf, xgb_model, nn


def ensemble_predict(rf, xgb_model, nn, X):
    rf_probs = rf.predict_proba(X)
    xgb_probs = xgb_model.predict_proba(X)
    nn_probs = nn.predict(X, verbose=0)

    # Average probabilities
    final_probs = (rf_probs + xgb_probs + nn_probs) / 3

    final_pred = np.argmax(final_probs, axis=1)

    return final_pred, final_probs


def main():
    print("=" * 60)
    print("ENSEMBLE MODEL (RF + XGB + NN)")
    print("=" * 60)

    X_test = np.load(os.path.join(MODELS_DIR, "X_test.npy"))
    y_test = np.load(os.path.join(MODELS_DIR, "y_test.npy"))

    rf, xgb_model, nn = load_models()

    preds, probs = ensemble_predict(rf, xgb_model, nn, X_test)

    from sklearn.metrics import accuracy_score, f1_score

    acc = accuracy_score(y_test, preds)
    f1 = f1_score(y_test, preds, average="macro")

    print(f"\nEnsemble Accuracy: {acc:.4f}")
    print(f"Ensemble F1 Score: {f1:.4f}")


if __name__ == "__main__":
    main()
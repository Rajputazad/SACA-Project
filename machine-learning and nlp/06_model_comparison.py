"""
SACA ML Project - Part 6: Compare All Models
"""

import os
import joblib
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, classification_report

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, "models")
OUTPUT_DIR = os.path.join(BASE_DIR, "outputs")
FIG_DIR = os.path.join(OUTPUT_DIR, "figures")

os.makedirs(FIG_DIR, exist_ok=True)

def main():
    print("=" * 60)
    print("PART 6: MODEL COMPARISON")
    print("=" * 60)

    X_test = np.load(os.path.join(MODELS_DIR, "X_test.npy"))
    y_test = np.load(os.path.join(MODELS_DIR, "y_test.npy"))

    results = {}

    rf = joblib.load(os.path.join(MODELS_DIR, "saca_triage_model_rf.pkl"))
    y_pred_rf = rf.predict(X_test)
    results["Random Forest"] = {
        "Accuracy": accuracy_score(y_test, y_pred_rf),
        "Precision": precision_score(y_test, y_pred_rf, average="macro"),
        "Recall": recall_score(y_test, y_pred_rf, average="macro"),
        "F1-Score": f1_score(y_test, y_pred_rf, average="macro"),
    }

    import xgboost as xgb
    xgb_model = xgb.XGBClassifier()
    xgb_model.load_model(os.path.join(MODELS_DIR, "saca_triage_model_xgb.json"))
    y_pred_xgb = xgb_model.predict(X_test)
    results["XGBoost"] = {
        "Accuracy": accuracy_score(y_test, y_pred_xgb),
        "Precision": precision_score(y_test, y_pred_xgb, average="macro"),
        "Recall": recall_score(y_test, y_pred_xgb, average="macro"),
        "F1-Score": f1_score(y_test, y_pred_xgb, average="macro"),
    }

    try:
        import tensorflow as tf
        nn = tf.keras.models.load_model(os.path.join(MODELS_DIR, "saca_triage_model_nn.h5"))
        y_pred_nn = np.argmax(nn.predict(X_test, verbose=0), axis=1)
        results["Neural Network"] = {
            "Accuracy": accuracy_score(y_test, y_pred_nn),
            "Precision": precision_score(y_test, y_pred_nn, average="macro"),
            "Recall": recall_score(y_test, y_pred_nn, average="macro"),
            "F1-Score": f1_score(y_test, y_pred_nn, average="macro"),
        }
    except Exception as e:
        print(f"[WARNING] Neural Network not available: {e}")

    results_df = pd.DataFrame(results).T
    print(results_df.round(4))

    results_df.to_csv(os.path.join(OUTPUT_DIR, "model_comparison_results.csv"))

    best_model = results_df["F1-Score"].idxmax()
    with open(os.path.join(MODELS_DIR, "best_model_name.txt"), "w", encoding="utf-8") as f:
        f.write(best_model)

    if best_model == "Random Forest":
        best_pred = y_pred_rf
    elif best_model == "XGBoost":
        best_pred = y_pred_xgb
    else:
        best_pred = y_pred_nn

    with open(os.path.join(OUTPUT_DIR, "classification_report.txt"), "w", encoding="utf-8") as f:
        f.write(f"Best Model: {best_model}\n\n")
        f.write(classification_report(y_test, best_pred, target_names=["Mild", "Moderate", "Severe"]))

    ax = results_df.plot(kind="bar", figsize=(10, 6))
    ax.set_title("Model Performance Comparison")
    ax.set_ylabel("Score")
    ax.set_ylim(0, 1)
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(os.path.join(FIG_DIR, "model_comparison.png"), dpi=120)
    plt.close()

    print(f"\n[OK] Best model: {best_model}")

if __name__ == "__main__":
    main()
"""
Train Random Forest and an MLP neural network for comparison only.

This script does not replace the app's current XGBoost model. It saves
comparison-only artifacts and a labelled graph under outputs/.
"""

from pathlib import Path
import json

import joblib
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import xgboost as xgb
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler


ROOT = Path(__file__).resolve().parents[1]
MODELS_DIR = ROOT / "models"
OUTPUTS_DIR = ROOT / "outputs"
FIGURES_DIR = OUTPUTS_DIR / "figures"


def evaluate(name, model, X_test, y_test):
    predictions = model.predict(X_test)
    return {
        "Model": name,
        "Accuracy": accuracy_score(y_test, predictions),
        "Precision": precision_score(y_test, predictions, average="macro", zero_division=0),
        "Recall": recall_score(y_test, predictions, average="macro", zero_division=0),
        "F1-Score": f1_score(y_test, predictions, average="macro", zero_division=0),
    }


def add_labels(ax, bars):
    for bar in bars:
        height = bar.get_height()
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            height + 0.015,
            f"{height:.4f}",
            ha="center",
            va="bottom",
            fontsize=9,
            rotation=90,
        )


def save_graph(results_df):
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    metrics = ["Accuracy", "Precision", "Recall", "F1-Score"]
    colors = ["#2563eb", "#f59e0b", "#16a34a", "#dc2626"]

    fig, ax = plt.subplots(figsize=(13, 7))
    x = np.arange(len(results_df.index))
    width = 0.18

    for i, metric in enumerate(metrics):
        bars = ax.bar(
            x + (i - 1.5) * width,
            results_df[metric],
            width,
            label=metric,
            color=colors[i],
        )
        add_labels(ax, bars)

    ax.set_title("Model Comparison", fontsize=18, weight="bold", pad=18)
    ax.set_ylabel("Score")
    ax.set_ylim(0, 1.12)
    ax.set_xticks(x)
    ax.set_xticklabels(results_df.index, rotation=15, ha="right")
    ax.grid(axis="y", alpha=0.25)
    ax.legend(loc="lower right")
    # ax.text(
    #     0.5,
    #     -0.18,
    #     "Comparison uses the current symptom-risk triage labels. XGBoost remains the production API model.",
    #     transform=ax.transAxes,
    #     ha="center",
    #     fontsize=10,
    #     color="#444444",
    # )
    fig.tight_layout(rect=[0, 0.06, 1, 1])
    fig.savefig(FIGURES_DIR / "current_model_comparison_with_values.png", dpi=180)
    plt.close(fig)


def main():
    X = np.load(MODELS_DIR / "X_processed.npy")
    y = np.load(MODELS_DIR / "y_processed.npy")

    X_train, X_temp, y_train, y_temp = train_test_split(
        X, y, test_size=0.3, random_state=42, stratify=y
    )
    _, X_test, _, y_test = train_test_split(
        X_temp, y_temp, test_size=0.5, random_state=42, stratify=y_temp
    )

    xgb_model = xgb.XGBClassifier()
    xgb_model.load_model(MODELS_DIR / "saca_triage_model_xgb.json")

    rf_model = RandomForestClassifier(
        n_estimators=300,
        max_depth=None,
        min_samples_leaf=1,
        class_weight="balanced",
        random_state=42,
        n_jobs=-1,
    )
    rf_model.fit(X_train, y_train)
    joblib.dump(rf_model, MODELS_DIR / "comparison_random_forest.pkl")

    nn_model = make_pipeline(
        StandardScaler(),
        MLPClassifier(
            hidden_layer_sizes=(96, 48),
            activation="relu",
            solver="adam",
            alpha=0.0005,
            learning_rate_init=0.001,
            max_iter=350,
            early_stopping=True,
            random_state=42,
        ),
    )
    nn_model.fit(X_train, y_train)
    joblib.dump(nn_model, MODELS_DIR / "comparison_neural_network_mlp.pkl")

    results = [
        evaluate("XGBoost", xgb_model, X_test, y_test),
        evaluate("Random Forest", rf_model, X_test, y_test),
        evaluate("Neural Network (MLP)", nn_model, X_test, y_test),
    ]

    results_df = pd.DataFrame(results).set_index("Model")
    OUTPUTS_DIR.mkdir(exist_ok=True)
    results_df.to_csv(OUTPUTS_DIR / "current_model_comparison_with_values.csv")
    save_graph(results_df)

    best_model = results_df["F1-Score"].idxmax()
    summary = {
        "best_model_by_macro_f1": best_model,
        "results": results_df.to_dict(orient="index"),
        "note": "XGBoost remains the production API model; Random Forest and MLP are comparison-only.",
    }
    (OUTPUTS_DIR / "current_model_comparison_with_values.json").write_text(
        json.dumps(summary, indent=2),
        encoding="utf-8",
    )

    print(results_df.round(4))
    print(f"\nBest by Macro F1: {best_model}")
    print(f"Graph: {FIGURES_DIR / 'current_model_comparison_with_values.png'}")


if __name__ == "__main__":
    main()

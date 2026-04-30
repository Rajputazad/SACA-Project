"""
SACA ML Project - Part 4: Train XGBoost Model
"""

import os
import numpy as np
from imblearn.over_sampling import SMOTE
from sklearn.metrics import accuracy_score, f1_score
from sklearn.model_selection import GridSearchCV, train_test_split
from xgboost import XGBClassifier

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, "models")

def main():
    print("=" * 60)
    print("PART 4: TRAINING XGBOOST MODEL")
    print("=" * 60)

    X = np.load(os.path.join(MODELS_DIR, "X_processed.npy"))
    y = np.load(os.path.join(MODELS_DIR, "y_processed.npy"))

    X_temp, X_test, y_temp, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp, test_size=0.1875, random_state=42, stratify=y_temp
    )

    smote = SMOTE(random_state=42)
    X_train_bal, y_train_bal = smote.fit_resample(X_train, y_train)

    param_grid = {
        "n_estimators": [100, 200],
        "max_depth": [6, 8, 10],
        "learning_rate": [0.01, 0.05, 0.1],
        "subsample": [0.8, 1.0],
    }

    model = XGBClassifier(
        random_state=42,
        eval_metric="mlogloss",
        n_jobs=-1,
    )

    grid = GridSearchCV(
        model,
        param_grid,
        cv=3,
        scoring="f1_macro",
        n_jobs=-1,
        verbose=1,
    )
    grid.fit(X_train_bal, y_train_bal)

    best_model = grid.best_estimator_
    y_val_pred = best_model.predict(X_val)

    print(f"\nBest parameters: {grid.best_params_}")
    print(f"Validation accuracy: {accuracy_score(y_val, y_val_pred):.4f}")
    print(f"Validation macro F1: {f1_score(y_val, y_val_pred, average='macro'):.4f}")

    best_model.save_model(os.path.join(MODELS_DIR, "saca_triage_model_xgb.json"))
    print("[OK] XGBoost model saved.")

if __name__ == "__main__":
    main()
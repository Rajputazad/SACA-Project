"""
SACA ML Project - Part 3: Train Random Forest Model
"""

import os
import joblib
import numpy as np
from imblearn.over_sampling import SMOTE
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score
from sklearn.model_selection import GridSearchCV, train_test_split

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, "models")

def main():
    print("=" * 60)
    print("PART 3: TRAINING RANDOM FOREST MODEL")
    print("=" * 60)

    X = np.load(os.path.join(MODELS_DIR, "X_processed.npy"))
    y = np.load(os.path.join(MODELS_DIR, "y_processed.npy"))
    print(f"\nLoaded data: X={X.shape}, y={y.shape}")

    X_temp, X_test, y_temp, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp, test_size=0.1875, random_state=42, stratify=y_temp
    )

    print("\nData split:")
    print(f"Training: {X_train.shape[0]}")
    print(f"Validation: {X_val.shape[0]}")
    print(f"Test: {X_test.shape[0]}")

    smote = SMOTE(random_state=42)
    X_train_bal, y_train_bal = smote.fit_resample(X_train, y_train)
    print(f"\nAfter SMOTE: {X_train_bal.shape[0]} samples")

    param_grid = {
        "n_estimators": [100, 200],
        "max_depth": [10, 20, None],
        "min_samples_split": [2, 5],
        "min_samples_leaf": [1, 2],
    }

    model = RandomForestClassifier(random_state=42, n_jobs=-1)

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

    joblib.dump(best_model, os.path.join(MODELS_DIR, "saca_triage_model_rf.pkl"))
    np.save(os.path.join(MODELS_DIR, "X_test.npy"), X_test)
    np.save(os.path.join(MODELS_DIR, "y_test.npy"), y_test)
    np.save(os.path.join(MODELS_DIR, "X_val.npy"), X_val)
    np.save(os.path.join(MODELS_DIR, "y_val.npy"), y_val)

    print("\n[OK] Random Forest model saved.")
    print("[OK] Saved X_test.npy, y_test.npy, X_val.npy, y_val.npy")

if __name__ == "__main__":
    main()
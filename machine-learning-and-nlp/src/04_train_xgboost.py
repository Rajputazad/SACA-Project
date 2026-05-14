"""
SACA ML Project - Part 4: Train XGBoost Model
"""

import numpy as np
import joblib
from sklearn.model_selection import train_test_split, GridSearchCV
from xgboost import XGBClassifier
from sklearn.metrics import accuracy_score, f1_score
from imblearn.over_sampling import SMOTE
import warnings
warnings.filterwarnings('ignore')

def main():
    print("="*60)
    print("PART 4: TRAINING XGBOOST MODEL")
    print("="*60)
    
    # Load data
    X = np.load('../models/X_processed.npy')
    y = np.load('../models/y_processed.npy')
    
    # Split data
    X_temp, X_test, y_temp, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp, test_size=0.1875, random_state=42, stratify=y_temp
    )
    
    # Apply SMOTE
    smote = SMOTE(random_state=42)
    X_train_balanced, y_train_balanced = smote.fit_resample(X_train, y_train)
    print(f"\nTraining set size after SMOTE: {X_train_balanced.shape[0]}")
    
    # Hyperparameter tuning
    print("\nPerforming hyperparameter tuning...")
    param_grid = {
        'n_estimators': [100, 200],
        'max_depth': [6, 8, 10],
        'learning_rate': [0.01, 0.05, 0.1],
        'subsample': [0.8, 1.0]
    }
    
    xgb_base = XGBClassifier(random_state=42, use_label_encoder=False, eval_metric='mlogloss')
    grid_search = GridSearchCV(
        xgb_base, param_grid, cv=3, scoring='f1_macro', 
        n_jobs=-1, verbose=1
    )
    grid_search.fit(X_train_balanced, y_train_balanced)
    
    print(f"\n[OK] Best parameters: {grid_search.best_params_}")
    print(f"[OK] Best CV score: {grid_search.best_score_:.4f}")
    
    xgb_best = grid_search.best_estimator_
    
    # Evaluate
    y_val_pred = xgb_best.predict(X_val)
    val_f1 = f1_score(y_val, y_val_pred, average='macro')
    val_acc = accuracy_score(y_val, y_val_pred)
    
    print(f"\nValidation performance:")
    print(f"  Accuracy: {val_acc:.4f}")
    print(f"  F1-Score: {val_f1:.4f}")
    
    # Save
    xgb_best.save_model('../models/saca_triage_model_xgb.json')
    print("\n[OK] Saved model to 'models/saca_triage_model_xgb.json'")
    
    return xgb_best

if __name__ == "__main__":
    main()
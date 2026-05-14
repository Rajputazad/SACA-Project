"""
SACA ML Project - Part 3: Train Random Forest Model
"""

import numpy as np
import joblib
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score
from imblearn.over_sampling import SMOTE
import warnings
warnings.filterwarnings('ignore')

def main():
    print("="*60)
    print("PART 3: TRAINING RANDOM FOREST MODEL")
    print("="*60)
    
    # Load data
    X = np.load('../models/X_processed.npy')
    y = np.load('../models/y_processed.npy')
    print(f"\nLoaded data: {X.shape}, {y.shape}")
    
    # Split data
    X_temp, X_test, y_temp, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp, test_size=0.1875, random_state=42, stratify=y_temp
    )
    
    print(f"\nData split:")
    print(f"  Training: {X_train.shape[0]}")
    print(f"  Validation: {X_val.shape[0]}")
    print(f"  Test: {X_test.shape[0]}")
    
    # Apply SMOTE
    print("\nApplying SMOTE for class balancing...")
    smote = SMOTE(random_state=42)
    X_train_balanced, y_train_balanced = smote.fit_resample(X_train, y_train)
    print(f"  After SMOTE: {X_train_balanced.shape[0]} samples")
    
    # Hyperparameter tuning
    print("\nPerforming hyperparameter tuning...")
    param_grid = {
        'n_estimators': [100, 200],
        'max_depth': [10, 20, None],
        'min_samples_split': [2, 5],
        'min_samples_leaf': [1, 2]
    }
    
    rf_base = RandomForestClassifier(random_state=42, n_jobs=-1)
    grid_search = GridSearchCV(
        rf_base, param_grid, cv=3, scoring='f1_macro', 
        n_jobs=-1, verbose=1
    )
    grid_search.fit(X_train_balanced, y_train_balanced)
    
    print(f"\n[OK] Best parameters: {grid_search.best_params_}")
    print(f"[OK] Best CV score: {grid_search.best_score_:.4f}")
    
    rf_best = grid_search.best_estimator_
    
    # Evaluate
    y_val_pred = rf_best.predict(X_val)
    val_f1 = f1_score(y_val, y_val_pred, average='macro')
    val_acc = accuracy_score(y_val, y_val_pred)
    
    print(f"\nValidation performance:")
    print(f"  Accuracy: {val_acc:.4f}")
    print(f"  F1-Score: {val_f1:.4f}")
    
    # Save
    joblib.dump(rf_best, '../models/saca_triage_model_rf.pkl')
    print("\n[OK] Saved model to 'models/saca_triage_model_rf.pkl'")
    
    # Save test sets
    np.save('../models/X_test.npy', X_test)
    np.save('../models/y_test.npy', y_test)
    np.save('../models/X_val.npy', X_val)
    np.save('../models/y_val.npy', y_val)
    
    return rf_best

if __name__ == "__main__":
    main()
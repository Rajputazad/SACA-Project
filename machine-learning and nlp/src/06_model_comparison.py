"""
SACA ML Project - Part 6: Compare All Models
"""

import numpy as np
import pandas as pd
import joblib
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, classification_report
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import os

os.makedirs('../outputs/figures', exist_ok=True)

def main():
    print("="*60)
    print("PART 6: MODEL COMPARISON")
    print("="*60)
    
    # Load test data
    X_test = np.load('../models/X_test.npy')
    y_test = np.load('../models/y_test.npy')
    print(f"\nTest set size: {len(y_test)} samples")
    
    results = {}
    
    # Random Forest
    print("\n[DATA] Evaluating Random Forest...")
    rf = joblib.load('../models/saca_triage_model_rf.pkl')
    y_pred_rf = rf.predict(X_test)
    results['Random Forest'] = {
        'Accuracy': accuracy_score(y_test, y_pred_rf),
        'Precision': precision_score(y_test, y_pred_rf, average='macro'),
        'Recall': recall_score(y_test, y_pred_rf, average='macro'),
        'F1-Score': f1_score(y_test, y_pred_rf, average='macro')
    }
    print(f"  F1-Score: {results['Random Forest']['F1-Score']:.4f}")
    
    # XGBoost
    print("\n[DATA] Evaluating XGBoost...")
    import xgboost as xgb
    xgb_model = xgb.XGBClassifier()
    xgb_model.load_model('../models/saca_triage_model_xgb.json')
    y_pred_xgb = xgb_model.predict(X_test)
    results['XGBoost'] = {
        'Accuracy': accuracy_score(y_test, y_pred_xgb),
        'Precision': precision_score(y_test, y_pred_xgb, average='macro'),
        'Recall': recall_score(y_test, y_pred_xgb, average='macro'),
        'F1-Score': f1_score(y_test, y_pred_xgb, average='macro')
    }
    print(f"  F1-Score: {results['XGBoost']['F1-Score']:.4f}")
    
    # Neural Network (if exists)
    try:
        print("\n[DATA] Evaluating Neural Network...")
        import tensorflow as tf
        nn = tf.keras.models.load_model('../models/saca_triage_model_nn.h5')
        y_pred_nn = np.argmax(nn.predict(X_test), axis=1)
        results['Neural Network'] = {
            'Accuracy': accuracy_score(y_test, y_pred_nn),
            'Precision': precision_score(y_test, y_pred_nn, average='macro'),
            'Recall': recall_score(y_test, y_pred_nn, average='macro'),
            'F1-Score': f1_score(y_test, y_pred_nn, average='macro')
        }
        print(f"  F1-Score: {results['Neural Network']['F1-Score']:.4f}")
    except:
        print("  Neural Network model not found, skipping...")
    
    # Create comparison dataframe
    results_df = pd.DataFrame(results).T
    print("\n" + "="*60)
    print("MODEL COMPARISON RESULTS")
    print("="*60)
    print(results_df.round(4))
    
    # Save
    results_df.to_csv('../outputs/model_comparison_results.csv')
    print("\n[OK] Saved to 'outputs/model_comparison_results.csv'")
    
    # Best model
    best_model = results_df['F1-Score'].idxmax()
    print(f"\n[BEST] Best model: {best_model}")
    
    # Detailed report for best model
    if best_model == 'Random Forest':
        best_pred = y_pred_rf
    elif best_model == 'XGBoost':
        best_pred = y_pred_xgb
    else:
        best_pred = y_pred_nn
    
    print("\n" + "="*60)
    print(f"DETAILED REPORT - {best_model}")
    print("="*60)
    print(classification_report(y_test, best_pred, 
                                target_names=['Mild (1)', 'Moderate (2)', 'Severe (3)']))
    
    # Save report
    with open('../outputs/classification_report.txt', 'w') as f:
        f.write(f"Best Model: {best_model}\n\n")
        f.write(classification_report(y_test, best_pred, 
                                      target_names=['Mild', 'Moderate', 'Severe']))
    
    # Save best model name
    with open('../models/best_model_name.txt', 'w') as f:
        f.write(best_model)
    
    # Plot comparison
    fig, ax = plt.subplots(figsize=(10, 6))
    results_df.plot(kind='bar', ax=ax)
    ax.set_title('Model Performance Comparison')
    ax.set_ylabel('Score')
    ax.set_ylim([0, 1])
    ax.legend(loc='lower right')
    ax.grid(True, alpha=0.3)
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig('../outputs/figures/model_comparison.png')
    plt.close()
    print("[OK] Saved comparison plot")
    
    return best_model

if __name__ == "__main__":
    main()
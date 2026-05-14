"""
SACA ML Project - Master Script
Run this to execute the entire pipeline
"""

import subprocess
import sys
import os

def safe_makedirs(path):
    """Create directory safely without error"""
    try:
        os.makedirs(path, exist_ok=True)
        return True
    except FileExistsError:
        return True
    except Exception as e:
        print(f"Warning: Could not create {path}: {e}")
        return False

def run_script(script_name, step_num, required=True):
    print("\n" + "="*70)
    print(f"STEP {step_num}: Running {script_name}")
    print("="*70)
    
    result = subprocess.run([sys.executable, script_name], cwd='src')
    
    if result.returncode != 0:
        if required:
            print(f"\n[ERROR] Error in {script_name}. Stopping pipeline.")
            return False
        else:
            print(f"\n[WARNING] {script_name} failed but continuing...")
            return True
    else:
        print(f"\n[OK] Completed {script_name}")
        return True

def main():
    print("="*70)
    print("SACA ML PROJECT - FULL PIPELINE")
    print("="*70)
    
    # Create directories safely
    safe_makedirs('outputs')
    safe_makedirs('outputs/figures')
    safe_makedirs('models')
    safe_makedirs('app_integration')
    
    print("\nThis script will run all parts of the ML pipeline.")
    print("Make sure you have:")
    print("  1. Run: python setup.py (to install libraries)")
    print("  2. Downloaded Healthcare.csv to data/ folder")
    
    # Check for data
    if not os.path.exists('data/Healthcare.csv'):
        print("\n[ERROR] Healthcare.csv not found in data/ folder!")
        print("   Please download from Kaggle and place it in D:\\Health_Project\\data\\")
        return
    
    print("\n[OK] Found Healthcare.csv")
    input("\nPress Enter to continue...")
    
    # Run scripts
    scripts = [
        ('01_load_and_explore.py', '1/7', True),
        ('02_preprocess_and_features.py', '2/7', True),
        ('03_train_random_forest.py', '3/7', True),
        ('04_train_xgboost.py', '4/7', True),
        ('05_train_neural_network.py', '5/7', False),  # Optional
        ('06_model_comparison.py', '6/7', True),
        ('07_inference_module.py', '7/7', True),
    ]
    
    for script, step, required in scripts:
        if not run_script(script, step, required):
            return
    
    print("\n" + "="*70)
    print("[DONE] PIPELINE COMPLETE!")
    print("="*70)
    print("\nOutput files:")
    print("  [FOLDER] models/ - Trained models")
    print("  [FOLDER] outputs/ - Results and figures")
    print("  [FOLDER] app_integration/ - Ready for app team")
    print("\nShare the 'app_integration' folder with your friend!")

if __name__ == "__main__":
    main()
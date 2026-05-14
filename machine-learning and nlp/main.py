"""
SACA ML Project - Master Script
Run the entire pipeline
"""

import os
import sys
import subprocess

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def run_script(script_name):
    print("\n" + "=" * 70)
    print(f"Running {script_name}")
    print("=" * 70)

    script_path = os.path.join(BASE_DIR, script_name)
    result = subprocess.run([sys.executable, script_path])

    if result.returncode != 0:
        raise RuntimeError(f"{script_name} failed.")

def main():
    print("=" * 70)
    print("SACA ML PROJECT - FULL PIPELINE")
    print("=" * 70)

    os.makedirs(os.path.join(BASE_DIR, "outputs", "figures"), exist_ok=True)
    os.makedirs(os.path.join(BASE_DIR, "models"), exist_ok=True)
    os.makedirs(os.path.join(BASE_DIR, "app_integration"), exist_ok=True)

    dataset_path = os.path.join(BASE_DIR, "data", "Healthcare.csv")
    if not os.path.exists(dataset_path):
        raise FileNotFoundError(f"Dataset not found: {dataset_path}")

    scripts = [
        "01_load_and_explore.py",
        "02_preprocess_and_features.py",
        "03_train_random_forest.py",
        "04_train_xgboost.py",
        "05_train_neural_network.py",
        "06_model_comparison.py",
        "07_inference_module.py",
    ]

    for script in scripts:
        run_script(script)

    print("\n" + "=" * 70)
    print("[OK] PIPELINE COMPLETE")
    print("=" * 70)
    print("Check these folders:")
    print("- models/")
    print("- outputs/")
    print("- app_integration/")

if __name__ == "__main__":
    main()
import subprocess
import sys

def install_requirements():
    print("=" * 60)
    print("Installing required libraries for SACA ML Project")
    print("=" * 60)

    packages = [
        "pandas",
        "numpy",
        "matplotlib",
        "seaborn",
        "scikit-learn",
        "xgboost",
        "imbalanced-learn",
        "joblib",
        "tensorflow",
    ]

    for package in packages:
        print(f"Installing {package}...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])

    print("\n[OK] All packages installed successfully.")

if __name__ == "__main__":
    install_requirements()
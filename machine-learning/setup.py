# setup.py - Install all required packages
import subprocess
import sys

print("="*60)
print("Installing Required Libraries for SACA ML Project")
print("="*60)

packages = [
    'pandas',
    'numpy',
    'matplotlib',
    'seaborn',
    'scikit-learn',
    'xgboost',
    'imbalanced-learn',
    'joblib',
]

print("\nInstalling core packages...")
for package in packages:
    print(f"  Installing {package}...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

print("\nInstalling TensorFlow (may take a few minutes)...")
try:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "tensorflow"])
except:
    print("TensorFlow installation failed. You can still use Random Forest and XGBoost.")

print("\n" + "="*60)
print("[OK] Setup complete!")
print("="*60)
print("\nNext steps:")
print("  1. Download Healthcare.csv from Kaggle")
print("  2. Place it in the 'data' folder")
print("  3. Run: python main.py")
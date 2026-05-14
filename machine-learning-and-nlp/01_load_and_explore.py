"""
SACA ML Project - Part 1: Load and Explore Dataset
"""

import os
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(BASE_DIR, "data", "Healthcare.csv")
OUTPUT_DIR = os.path.join(BASE_DIR, "outputs")
FIG_DIR = os.path.join(OUTPUT_DIR, "figures")

os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(FIG_DIR, exist_ok=True)

def load_and_explore():
    print("=" * 60)
    print("PART 1: LOADING AND EXPLORING DATASET")
    print("=" * 60)

    if not os.path.exists(DATA_PATH):
        raise FileNotFoundError(f"Dataset not found at: {DATA_PATH}")

    file_size = os.path.getsize(DATA_PATH)
    print(f"\nDataset path: {DATA_PATH}")
    print(f"File size: {file_size} bytes")

    if file_size == 0:
        raise ValueError("Healthcare.csv is empty. Please replace it with the real dataset.")

    try:
        df = pd.read_csv(DATA_PATH)
    except pd.errors.EmptyDataError:
        raise ValueError("Healthcare.csv has no readable columns/data. Please check the file contents.")

    if df.empty:
        raise ValueError("Healthcare.csv loaded, but it contains no rows.")

    print(f"\n[OK] Dataset loaded successfully")
    print(f"Shape: {df.shape}")
    print(f"Columns: {df.columns.tolist()}")

    print("\nFirst 5 rows:")
    print(df.head())

    print("\nDataset info:")
    df.info()

    print("\nMissing values:")
    print(df.isnull().sum())

    print("\nStatistical summary:")
    print(df.describe(include="all"))

    if "Disease" in df.columns:
        print("\nTop disease counts:")
        print(df["Disease"].value_counts().head(10))

    with open(os.path.join(OUTPUT_DIR, "dataset_info.txt"), "w", encoding="utf-8") as f:
        f.write(f"Dataset Shape: {df.shape}\n")
        f.write(f"Columns: {df.columns.tolist()}\n\n")
        f.write("Missing Values:\n")
        f.write(str(df.isnull().sum()))
        f.write("\n\nDisease Distribution:\n")
        if "Disease" in df.columns:
            f.write(str(df["Disease"].value_counts()))

    try:
        fig, axes = plt.subplots(1, 2, figsize=(12, 5))

        if "Disease" in df.columns:
            df["Disease"].value_counts().head(15).plot(kind="bar", ax=axes[0])
            axes[0].set_title("Top 15 Diseases")
            axes[0].set_xlabel("Disease")
            axes[0].set_ylabel("Count")
            axes[0].tick_params(axis="x", rotation=45)

        if "Age" in df.columns:
            axes[1].hist(df["Age"], bins=30, edgecolor="black", alpha=0.7)
            axes[1].set_title("Age Distribution")
            axes[1].set_xlabel("Age")
            axes[1].set_ylabel("Frequency")

        plt.tight_layout()
        plt.savefig(os.path.join(FIG_DIR, "dataset_overview.png"), dpi=120)
        plt.close()
        print("\n[OK] Saved dataset overview figure.")
    except Exception as e:
        print(f"[WARNING] Could not create figure: {e}")

    print("\n[OK] Exploration complete.")
    return df

if __name__ == "__main__":
    load_and_explore()
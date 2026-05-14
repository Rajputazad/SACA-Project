"""
SACA ML Project - Part 1: Load and Explore Dataset
"""

import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import os
import sys

# Create directories safely
os.makedirs('../outputs/figures', exist_ok=True)
os.makedirs('../models', exist_ok=True)

def load_and_explore():
    print("="*60)
    print("PART 1: LOADING AND EXPLORING DATASET")
    print("="*60)
    
    # Load dataset
    try:
        df = pd.read_csv('../data/Healthcare.csv')
        print(f"\n[OK] Dataset loaded successfully!")
        print(f"   Shape: {df.shape}")
        print(f"   Columns: {df.columns.tolist()}")
    except FileNotFoundError:
        print("\n[ERROR] Healthcare.csv not found in '../data/' folder")
        print("   Please place the file at: D:\\Health_Project\\data\\Healthcare.csv")
        return None
    except Exception as e:
        print(f"\n[ERROR] Error loading dataset: {e}")
        return None
    
    # Basic info
    print("\n[DATA] First 5 rows:")
    print(df.head())
    
    print("\n[DATA] Dataset Info:")
    print(df.info())
    
    print("\n[INFO] Missing Values:")
    print(df.isnull().sum())
    
    print("\n[STATS] Statistical Summary:")
    print(df.describe())
    
    print("\n[DISEASE] Disease Distribution (Top 10):")
    print(df['Disease'].value_counts().head(10))
    
    # Save info to file
    with open('../outputs/dataset_info.txt', 'w') as f:
        f.write(f"Dataset Shape: {df.shape}\n")
        f.write(f"Columns: {df.columns.tolist()}\n")
        f.write(f"\nDisease Distribution:\n{df['Disease'].value_counts()}\n")
    
    # Create visualization
    try:
        fig, axes = plt.subplots(1, 2, figsize=(12, 5))
        
        # Disease distribution (top 15)
        df['Disease'].value_counts().head(15).plot(kind='bar', ax=axes[0])
        axes[0].set_title('Top 15 Diseases')
        axes[0].set_xlabel('Disease')
        axes[0].set_ylabel('Count')
        axes[0].tick_params(axis='x', rotation=45)
        
        # Age distribution
        axes[1].hist(df['Age'], bins=30, edgecolor='black', alpha=0.7)
        axes[1].set_title('Age Distribution of Patients')
        axes[1].set_xlabel('Age')
        axes[1].set_ylabel('Frequency')
        
        plt.tight_layout()
        plt.savefig('../outputs/figures/dataset_overview.png', dpi=100)
        plt.close()
        print("\n[OK] Saved visualization to 'outputs/figures/dataset_overview.png'")
    except Exception as e:
        print(f"\n[WARNING] Could not create visualization: {e}")
    
    print("\n[OK] Exploration complete!")
    return df

if __name__ == "__main__":
    df = load_and_explore()
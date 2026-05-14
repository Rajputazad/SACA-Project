"""
SACA ML Project - Part 5: Train Neural Network (Optional)
"""

import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, Sequential
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score
from imblearn.over_sampling import SMOTE
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os

os.makedirs('../outputs/figures', exist_ok=True)
os.makedirs('../models', exist_ok=True)

def create_model(input_shape):
    model = Sequential([
        layers.Input(shape=(input_shape,)),
        layers.Dense(256, activation='relu'),
        layers.BatchNormalization(),
        layers.Dropout(0.3),
        layers.Dense(128, activation='relu'),
        layers.BatchNormalization(),
        layers.Dropout(0.3),
        layers.Dense(64, activation='relu'),
        layers.BatchNormalization(),
        layers.Dropout(0.2),
        layers.Dense(32, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(3, activation='softmax')
    ])
    return model

def main():
    print("="*60)
    print("PART 5: TRAINING NEURAL NETWORK")
    print("="*60)
    
    try:
        X = np.load('../models/X_processed.npy')
        y = np.load('../models/y_processed.npy')
    except:
        print("[ERROR] Data not found. Run parts 1-2 first.")
        return None
    
    # Split data
    X_temp, X_test, y_temp, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp, test_size=0.1875, random_state=42, stratify=y_temp
    )
    
    # SMOTE
    smote = SMOTE(random_state=42)
    X_train_balanced, y_train_balanced = smote.fit_resample(X_train, y_train)
    print(f"Training size after SMOTE: {X_train_balanced.shape[0]}")
    
    # Convert to categorical
    y_train_cat = keras.utils.to_categorical(y_train_balanced, num_classes=3)
    y_val_cat = keras.utils.to_categorical(y_val, num_classes=3)
    
    # Create and train model
    model = create_model(X_train_balanced.shape[1])
    model.compile(optimizer=keras.optimizers.Adam(0.001),
                  loss='categorical_crossentropy', metrics=['accuracy'])
    
    callbacks = [
        EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True),
        ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5)
    ]
    
    print("\nTraining...")
    history = model.fit(X_train_balanced, y_train_cat,
                        validation_data=(X_val, y_val_cat),
                        epochs=50, batch_size=64, callbacks=callbacks, verbose=1)
    
    # Evaluate
    y_val_pred = np.argmax(model.predict(X_val), axis=1)
    print(f"\nValidation Accuracy: {accuracy_score(y_val, y_val_pred):.4f}")
    print(f"Validation F1-Score: {f1_score(y_val, y_val_pred, average='macro'):.4f}")
    
    # Save
    model.save('../models/saca_triage_model_nn.h5')
    print("\n[OK] Saved model to 'models/saca_triage_model_nn.h5'")
    
    return model

if __name__ == "__main__":
    main()
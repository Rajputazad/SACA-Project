"""
SACA ML Project - Part 5: Train Neural Network
"""

import os
import warnings
import joblib
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, Sequential
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.metrics import accuracy_score, f1_score, classification_report, confusion_matrix
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.utils.class_weight import compute_class_weight

warnings.filterwarnings("ignore")
os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(BASE_DIR, "models")
OUTPUT_DIR = os.path.join(BASE_DIR, "outputs")
FIG_DIR = os.path.join(OUTPUT_DIR, "figures")

os.makedirs(FIG_DIR, exist_ok=True)

def create_model(input_shape):
    model = Sequential([
        layers.Input(shape=(input_shape,)),
        layers.Dense(256, activation="relu"),
        layers.BatchNormalization(),
        layers.Dropout(0.3),
        layers.Dense(128, activation="relu"),
        layers.BatchNormalization(),
        layers.Dropout(0.3),
        layers.Dense(64, activation="relu"),
        layers.Dropout(0.2),
        layers.Dense(3, activation="softmax"),
    ])
    return model

def plot_history(history):
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

    ax1.plot(history.history["loss"], label="Train Loss")
    ax1.plot(history.history["val_loss"], label="Val Loss")
    ax1.legend()
    ax1.set_title("Loss")

    ax2.plot(history.history["accuracy"], label="Train Accuracy")
    ax2.plot(history.history["val_accuracy"], label="Val Accuracy")
    ax2.legend()
    ax2.set_title("Accuracy")

    plt.tight_layout()
    plt.savefig(os.path.join(FIG_DIR, "nn_training_history.png"), dpi=150)
    plt.close()

def main():
    print("=" * 60)
    print("PART 5: TRAINING NEURAL NETWORK")
    print("=" * 60)

    X = np.load(os.path.join(MODELS_DIR, "X_processed.npy"))
    y = np.load(os.path.join(MODELS_DIR, "y_processed.npy"))

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    X_temp, X_test, y_temp, y_test = train_test_split(
        X_scaled, y, test_size=0.2, random_state=42, stratify=y
    )
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp, test_size=0.25, random_state=42, stratify=y_temp
    )

    classes = np.unique(y_train)
    class_weights = compute_class_weight("balanced", classes=classes, y=y_train)
    class_weight_dict = {int(c): float(w) for c, w in zip(classes, class_weights)}

    y_train_cat = keras.utils.to_categorical(y_train, num_classes=3)
    y_val_cat = keras.utils.to_categorical(y_val, num_classes=3)

    model = create_model(X_train.shape[1])
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=0.001),
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )

    callbacks = [
        EarlyStopping(monitor="val_loss", patience=10, restore_best_weights=True, verbose=1),
        ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=5, verbose=1),
    ]

    history = model.fit(
        X_train,
        y_train_cat,
        validation_data=(X_val, y_val_cat),
        epochs=100,
        batch_size=64,
        class_weight=class_weight_dict,
        callbacks=callbacks,
        verbose=1,
    )

    y_val_pred = np.argmax(model.predict(X_val, verbose=0), axis=1)
    y_test_pred = np.argmax(model.predict(X_test, verbose=0), axis=1)

    print(f"\nValidation accuracy: {accuracy_score(y_val, y_val_pred):.4f}")
    print(f"Validation macro F1: {f1_score(y_val, y_val_pred, average='macro'):.4f}")
    print(f"Test accuracy: {accuracy_score(y_test, y_test_pred):.4f}")
    print(f"Test macro F1: {f1_score(y_test, y_test_pred, average='macro'):.4f}")

    print("\nClassification report:")
    print(classification_report(y_test, y_test_pred))

    print("\nConfusion matrix:")
    print(confusion_matrix(y_test, y_test_pred))

    model.save(os.path.join(MODELS_DIR, "saca_triage_model_nn.h5"))
    joblib.dump(scaler, os.path.join(MODELS_DIR, "scaler_v3.pkl"))
    plot_history(history)

    print("[OK] Neural Network model saved.")

if __name__ == "__main__":
    main()
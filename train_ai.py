import pandas as pd
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import os

# Create directory if it doesn't exist
os.makedirs('assets/models', exist_ok=True)

print("Step 1: Loading synthetic data...")
data = pd.read_csv('growth_training_data.csv')

# Separate Inputs (X) and Output (y)
# Input features mapping:
# 0: Energy Level
# 1: Total Missions
# 2: Easy Missions
# 3: Medium Missions
# 4: Hard Missions
# 5: Current Streak
X = data[['energy_level', 'total_missions', 'easy_count', 'medium_count', 'hard_count', 'current_streak']]
y = data['target_growth']

print("Step 2: Building Neural Network architecture...")
model = keras.Sequential([
    layers.Dense(16, activation='relu', input_shape=[6]),
    layers.Dense(8, activation='relu'),
    layers.Dense(1) # Final output is a single number (growth percentage)
])

model.compile(optimizer='adam', loss='mse', metrics=['mae'])

print("Step 3: Training the AI (this takes a few seconds)...")
model.fit(X, y, epochs=100, verbose=0) # Epochs=100 for better accuracy

print("Step 4: Converting model to TFLite format for Flutter...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

print("Step 5: Saving model to assets/models/leafloop_model.tflite...")
with open('assets/models/leafloop_model.tflite', 'wb') as f:
    f.write(tflite_model)

print("\nDONE! Your LeafLoop AI is now fully trained and ready for mobile deployment.")
print("Path: assets/models/leafloop_model.tflite")

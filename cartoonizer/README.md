# Cartoonizer

Cartoonizer is a simple On-Edge image style transfer mobile application. The Application use TFlite models to change the style of inputted image to cartoon-like style.

## Model

- Model Name : CartoonGAN
- Source : https://www.kaggle.com/models/spsayakpaul/cartoongan/tfLite/dr/1?tfhub-redirect=true

## Implementation

Using flutter TFlite package to load and run the TFlite model file. TFLite loads the model by mapping the .tflite binary file into a specialized Interpreter that manages the neural network’s graph and memory. To run it, the app pre-processes an image into a normalized 4D array (Tensor) that matches the model's required input shape, passes this numerical data into the Interpreter for inference, and then extracts the processed values from the output tensor to be reconstructed back into a visible image.

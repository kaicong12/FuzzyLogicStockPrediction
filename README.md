# Fuzzy Inference System for Stock Prediction

This project aims to create a Fuzzy Inference System (FIS) for stock prediction using various technical indicators and price-based features. The system is implemented in MATLAB, leveraging the Fuzzy Logic Toolbox. The FIS is constructed using a hierarchical structure to simplify the rule base and enhance the system's performance.

## Project Structure

The project is organized into the following sections:

### Preprocessing Scripts

1. `FeatureEngineering.m` - This script processes the raw stock data, calculates technical indicators, and prepares the dataset for input into the FIS.
2. `FuzzyCMeans.m` - This script applies the Fuzzy C-Means clustering algorithm to the preprocessed data, identifying relevant patterns and trends to be used as input for the FIS.

### Fuzzy Inference System Scripts

1. `FuzzyStockPrediction.m` - This script constructs the single level FIS tree structure
2. `TreeTuning.m` - This script constructs the aggregated FIS tree structure, with the inputs and outputs groupde in based on their context relevance. This script also provides code to fine-tunes the FIS parameters, such as membership function parameters, scaling factors, and fuzzification and defuzzification methods, to further enhance the system's performance.
3. `TreeWithCustomMF.m` - This script constructs the aggregated FIS tree structure, with custom membership functions using centroids returned from `FuzzyCMeans.m`.

## Getting Started

To run the project, follow these steps:

1. Ensure that MATLAB and the Fuzzy Logic Toolbox are installed on your system.
2. Clone the repository or download the project files.
3. Run the preprocessing scripts (`FeatureEngineering.m` and `FuzzyCMeans.m`) to generate the preprocessed dataset.
4. Execute the FIS tree construction script (`FISTreeConstruction.m`) to create the hierarchical FIS structure.
5. Fine-tune the FIS parameters using the `FineTuning.m` script.

After completing these steps, the optimized FIS will be ready for use in stock prediction tasks.

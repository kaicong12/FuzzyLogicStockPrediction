% Define Membership function names for the input variables
mfLow = ["Low", "Medium", "High"];
mfHigh = ["Low", "Medium", "High"];
mfOpen = ["Low", "Medium", "High"];
mfClose = ["Low", "Medium", "High"];
mfAdjClose = ["Low", "Medium", "High"];
mfVolume = ["Low", "Medium", "High"];
mfShortTermMA = ["Low", "Medium", "High"];
mfLongTermMA = ["Low", "Medium", "High"];
mfROC = ["Negative", "Neutral", "Positive"];
mfRSI = ["Oversold", "Neutral", "Overbought"];

mfPriceDiff = ["Decrease", "Increase"];


% Calculate peak value for each membership function to fuzzify each input and output variables
centroidLow = [294.36291288282, 368.043546190034, 530.127173670273];
centroidHigh = [305.97613853487, 380.118538776387, 544.942631931941];
centroidOpen = [300.541816214232, 374.638504643315, 537.944063403367];
centroidClose = [331.431147416266, 500.634848888628, 614.623692387707]; 
centroidAdjClose = [300.669915445882, 374.632716878575, 537.699242079863]; 
centroidVolume = [4390464.556951, 10100047.8927449, 20134352.2268096];
centroidLongTermMA = [332.470597415641, 504.695175832823, 620.418782176359];
centroidShortTermMA = [300.810143569319, 373.753019355581, 536.707635077308];
centroidROC = [-3.54774437662486, -0.139319774241064, 3.07918413834715];
centroidRSI = [33.0083198478724, 52.3009593447125, 71.7217757978516];
centroidPriceDiff = [-6.8757, 7.2477];


% Calculate the range of values which each feature spans across
rangeOpen = [233.9200, 692.350];
rangeHigh = [250.650, 700.9900];
rangeLow = [231.230, 686.090];
rangeClose = [233.880, 691.690];
rangeAdjClose = [233.880, 691.690];
rangeVolume = [1144000, 58904300];
rangeShortTermMA = [249.118, 684.610];
rangeLongTermMA = [263.970, 672.127];
rangeROC = [-21.7905, 16.8543];
rangeRSI = [2.5409, 96.2045];
rangePriceDiff = [-110.7500, 84.57];


% Create first FIS.
fis1 = mamfis('Name','PriceBasedFeatures','NumInputs', 5, 'NumOutputs',1, ...
    'NumInputMFs', 3, 'NumOutputMFs',2);

% Configure input and output variables.
fis1 = updateInput(fis1, 1, 'Low', rangeLow, centroidLow, mfLow);
fis1 = updateInput(fis1, 2, 'High', rangeHigh, centroidHigh, mfHigh);
fis1 = updateInput(fis1, 3, 'Open', rangeOpen, centroidOpen, mfOpen);
fis1 = updateInput(fis1, 4, 'Close', rangeClose, centroidClose, mfClose);
fis1 = updateInput(fis1, 5, 'AdjClose', rangeAdjClose, centroidAdjClose, mfAdjClose);
fis1 = updateOutput(fis1, 1, 'Level1PriceDiff', rangePriceDiff, centroidPriceDiff);


% Create second FIS
fis2 = mamfis('Name','TechnicalIndicators','NumInputs', 4, 'NumOutputs',1, ...
    'NumInputMFs', 3, 'NumOutputMFs',2);

% Connect Fis1 to Fis2
fis2.Inputs(1).Name = 'Level1PriceDiff';
fis2.Inputs(1).Range = rangePriceDiff;
fis2 = addMF(fis2, 'Level1PriceDiff', 'trimf', [centroidPriceDiff(1) - (centroidPriceDiff(2) - centroidPriceDiff(1)), centroidPriceDiff(1), centroidPriceDiff(2)], 'Name', 'Decrease');
fis2 = addMF(fis2, 'Level1PriceDiff', 'trimf', [centroidPriceDiff(1), centroidPriceDiff(2), centroidPriceDiff(2) + (centroidPriceDiff(2) - centroidPriceDiff(1))], 'Name', 'Increase');

fis2 = updateInput(fis2, 2, 'Volume', rangeVolume, centroidVolume, mfVolume);
fis2 = updateInput(fis2, 3, 'Rate of Change (ROC)', rangeROC, centroidROC, mfROC);
fis2 = updateInput(fis2, 4, 'Relative Strength Index (RSI)', rangeRSI, centroidRSI, mfRSI);
fis2 = updateOutput(fis2, 1, 'Level2PriceDiff', rangePriceDiff, centroidPriceDiff);


% Create third FIS
fis3 = mamfis('Name','MovingAverage','NumInputs', 3, 'NumOutputs',1, ...
    'NumInputMFs', 3, 'NumOutputMFs',2);

% Connect Fis2 to Fis3
fis3.Inputs(1).Name = 'Level2PriceDiff';
fis3.Inputs(1).Range = rangePriceDiff;
fis3 = addMF(fis3, 'Level2PriceDiff', 'trimf', [centroidPriceDiff(1) - (centroidPriceDiff(2) - centroidPriceDiff(1)), centroidPriceDiff(1), centroidPriceDiff(2)], 'Name', 'Decrease');
fis3 = addMF(fis3, 'Level2PriceDiff', 'trimf', [centroidPriceDiff(1), centroidPriceDiff(2), centroidPriceDiff(2) + (centroidPriceDiff(2) - centroidPriceDiff(1))], 'Name', 'Increase');

fis3 = updateInput(fis3, 2, 'Long Term MA', rangeLongTermMA, centroidLongTermMA, mfLongTermMA);
fis3 = updateInput(fis3, 3, 'Short Term MA', rangeShortTermMA, centroidShortTermMA, mfShortTermMA);
fis3 = updateOutput(fis3, 1, 'PriceDiff', rangePriceDiff, centroidPriceDiff);


% Connect the FIS together
con1 = [fis1.Name + "/" + fis1.Outputs(1).Name ...
    fis2.Name + "/" + fis2.Inputs(1).Name];
con2 = [fis2.Name + "/" + fis2.Outputs(1).Name ...
    fis3.Name + "/" + fis3.Inputs(1).Name];

fisTInit = fistree([fis1 fis2 fis3], [con1; con2]);


[in,out,rule] = getTunableSettings(fisTInit);
for rId = 1:numel(rule)
    rule(rId).Antecedent.Free = false;    
end

options = tunefisOptions;
options.MethodOptions.MaxGenerations = 3;
options.MethodOptions.PopulationSize = 100;


% Get Data to tune the system
data = readtable('preprocessed_data.csv');

% Perform a random train-test split
rng('default'); % Set random seed for reproducibility
cv = cvpartition(height(data), 'HoldOut', 0.2); % 80% training data, 20% testing data

% Extract the train and test data
trainData = data(cv.training, :);
testData = data(cv.test, :);

% Extract the input (X) and target (price_diff) data
X_train = trainData{:, 2:end-1}; % All columns except the first and last (price_diff)
y_train = trainData{:, 'price_diff'}; % Target: price_diff column
X_test = testData{:, 2:end-1}; % All columns except the first and last (price_diff)
y_test = testData{:, 'price_diff'}; % Target: price_diff column

[trainedFis, trainError] = tunefis(fisTInit, rule, X_train, y_train, options);
disp(['Optimal RMSE: ', num2str(trainError)]);



function fis = updateInput(fis, id, name, range, centroids, mfNames)
    fis.Inputs(id).Name = name;
    fis.Inputs(id).Range = range;
    
    for mfId = 1:length(mfNames)
        fis.Inputs(id).MembershipFunctions(mfId).Name = mfNames(mfId);
        
        % low membership function
        if mfId == 1
            parameters = [centroids(1) - (centroids(2) - centroids(1)), centroids(1), centroids(2)];
        elseif mfId == 2
            % medium membership function
            parameters = centroids;
        else
            % high membership function
            parameters = [centroids(2), centroids(3), centroids(3) + (centroids(3) - centroids(2))];
        end
    
        fis.Inputs(id).MembershipFunctions(mfId).Parameters = parameters;
    end

end

function fis = updateOutput(fis, id, name, range, centroids)    
    fis.Outputs(id).Name = name;
    
    % MF names - Increase, Decrease
    mfPriceDiff = ["Decrease", "Increase"];
    
    for mfId = 1:length(mfPriceDiff)
        fis.Outputs(id).MembershipFunctions(mfId).Name = mfPriceDiff(mfId);
    
        if mfId == 1
            parameters = [centroids(1) - (centroids(2) - centroids(1)), centroids(1), centroids(2)];
        else
            parameters = [centroids(1), centroids(2), centroids(2) + (centroids(2) - centroids(1))];
        end
        fis.Outputs(id).MembershipFunctions(mfId).Parameters = parameters;
    end
    
    fis.Outputs(id).Range = range;

end

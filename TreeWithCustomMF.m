% Get Data to tune the system
data = readtable('preprocessed_data.csv');
data = table2array(data(:, 2:end));
dataRange = [min(data)' max(data)'];

% Original Column Order
% 1. Open
% 2. High
% 3. Low
% 4. Close
% 5. AdjClose
% 6. Volume
% 7. ShortTermMA
% 8. LongTermMA
% 9. ROC
% 10. RSI

X = data(:,1:10);
Y = data(:,11);
inputOrder = [3 2 1 4 5 6 9 10 8 7];
orderedData = X(:, inputOrder);


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


% Create first FIS.
fis1 = mamfis('Name','PriceBasedFeatures');
fis1 = updateInput(fis1, 1, 'Low', dataRange(3,:), centroidLow, mfLow);
fis1 = updateInput(fis1, 2, 'High', dataRange(2,:), centroidHigh, mfHigh);
fis1 = updateInput(fis1, 3, 'Open', dataRange(1,:), centroidOpen, mfOpen);
fis1 = updateInput(fis1, 4, 'Close', dataRange(4,:), centroidClose, mfClose);
fis1 = updateInput(fis1, 5, 'AdjClose', dataRange(5,:), centroidAdjClose, mfAdjClose);
fis1 = updateOutput(fis1, 1, 'Level1PriceDiff', dataRange(11,:), centroidPriceDiff);


% Create second FIS
fis2 = mamfis('Name','TechnicalIndicators');
fis2 = updateInput(fis2, 1, 'Volume', dataRange(6,:), centroidVolume, mfVolume);
fis2 = updateInput(fis2, 2, 'Rate of Change (ROC)', dataRange(9,:), centroidROC, mfROC);
fis2 = updateInput(fis2, 3, 'Relative Strength Index (RSI)', dataRange(10,:), centroidRSI, mfRSI);
fis2 = updateOutput(fis2, 1, 'Level2PriceDiff', dataRange(11,:), centroidPriceDiff);


% Create third FIS
fis3 = mamfis('Name','MovingAverage');
fis3 = updateInput(fis3, 1, 'Long Term MA', dataRange(8,:), centroidLongTermMA, mfLongTermMA);
fis3 = updateInput(fis3, 2, 'Short Term MA', dataRange(7,:), centroidShortTermMA, mfShortTermMA);
fis3 = updateOutput(fis3, 1, 'Level3PriceDiff', dataRange(11,:), centroidPriceDiff);


% Create 4th FIS
fis4 = mamfis('Name', 'fis4');
fis4 = addInput(fis4, dataRange(11,:),'NumMFs',2);
fis4 = addInput(fis4, dataRange(11,:),'NumMFs',2);
fis4 = addOutput(fis4, dataRange(11,:),'NumMFs',2);


% Create 5th FIS
fis5 = fis4;
fis5.Name = 'fis5';
fis5.Outputs(1).Name = "price_diff";


% Connect the FIS together
con1 = [ ...
    "PriceBasedFeatures/Level1PriceDiff" "fis4/input1"; ...
    "TechnicalIndicators/Level2PriceDiff" "fis4/input2"; ...
    "MovingAverage/Level3PriceDiff" "fis5/input2"; ...
    "fis4/output1" "fis5/input1"
];
fisTInit = fistree([fis1 fis2 fis3 fis4 fis5], con1);

% figure
% plot(fisTInit)

options = tunefisOptions('OptimizationType','learning');
rng('default');
trainedFis = tunefis(fisTInit, [], orderedData, Y, options);


% After learning the new rules, tune the parameters of the learned rules
% [in,out,rule] = getTunableSettings(fisTout1);
% options.OptimizationType = 'tuning';
% trainedFis2 = tunefis(trainedFis, rule, orderedData, Y, options);


% Evaluate the FIS
outputTuned = evalfis(trainedFis, orderedData);
plot([Y, outputTuned])
legend("Expected Output","Tuned Output","Location","southeast")
xlabel("Data Index")
ylabel("Price Difference")


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
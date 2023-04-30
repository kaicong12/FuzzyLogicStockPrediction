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
fis1 = mamfis('Name','fis1','NumInputs',9 ,'NumOutputs',1, ...
    'NumInputMFs',3,'NumOutputMFs',2);

% Configure input and output variables.
fis1 = updateInput(fis1, 1, 'Low', rangeLow, centroidLow, mfLow);
fis1 = updateInput(fis1, 2, 'High', rangeHigh, centroidHigh, mfHigh);
fis1 = updateInput(fis1, 3, 'Open', rangeOpen, centroidOpen, mfOpen);
fis1 = updateInput(fis1, 4, 'Close', rangeClose, centroidClose, mfClose);
% fis1 = updateInput(fis1, 5, 'AdjClose', rangeAdjClose, centroidAdjClose, mfAdjClose);
fis1 = updateInput(fis1, 5, 'Volume', rangeVolume, centroidVolume, mfVolume);
fis1 = updateInput(fis1, 6, 'Long Term MA', rangeLongTermMA, centroidLongTermMA, mfLongTermMA);
fis1 = updateInput(fis1, 7, 'Short Term MA', rangeShortTermMA, centroidShortTermMA, mfShortTermMA);
fis1 = updateInput(fis1, 8, 'Rate of Change (ROC)', rangeROC, centroidROC, mfROC);
fis1 = updateInput(fis1, 9, 'Relative Strength Index (RSI)', rangeRSI, centroidRSI, mfRSI);

fis1 = updateOutput(fis1, 1, 'Next Day Price Diff', rangePriceDiff, centroidPriceDiff);


figure
plotfis(fis1)



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
    mfPriceDiff = ["Increase", "Decrease"];
    
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

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



% Create first FIS.
fis1 = mamfis('Name','PriceBasedFeatures');
fis1 = addInput(fis1, dataRange(3,:),'NumMFs', 3, 'Name', "Low");
fis1 = addInput(fis1, dataRange(2,:),'NumMFs', 3, 'Name', "High");
fis1 = addInput(fis1, dataRange(1,:),'NumMFs', 3, 'Name', "Open");
fis1 = addInput(fis1, dataRange(4,:),'NumMFs', 3, 'Name', "Close");
fis1 = addInput(fis1, dataRange(5,:),'NumMFs', 3, 'Name', "AdjClose");
fis1 = addOutput(fis1, dataRange(11,:),'NumMFs',2);


% Create second FIS
fis2 = mamfis('Name','TechnicalIndicators');
fis2 = addInput(fis2, dataRange(6,:),'NumMFs', 3, 'Name', "Volume");
fis2 = addInput(fis2, dataRange(9,:),'NumMFs', 3, 'Name', 'Rate of Change (ROC)');
fis2 = addInput(fis2, dataRange(10,:),'NumMFs', 3, 'Name', 'Relative Strength Index (RSI)');
fis2 = addOutput(fis2, dataRange(11,:),'NumMFs', 2);


% Create third FIS
fis3 = mamfis('Name','MovingAverage');
fis3 = addInput(fis3, dataRange(8,:),'NumMFs', 3, 'Name', "Long Term MA");
fis3 = addInput(fis3, dataRange(7,:),'NumMFs', 3, 'Name', 'Short Term MA');
fis3 = addOutput(fis3, dataRange(11,:),'NumMFs', 2);


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
    "PriceBasedFeatures/output1" "fis4/input1"; ...
    "TechnicalIndicators/output1" "fis4/input2"; ...
    "MovingAverage/output1" "fis5/input2"; ...
    "fis4/output1" "fis5/input1"
];
fisTInit = fistree([fis1 fis2 fis3 fis4 fis5], con1);


% Tuning is performed in two steps.
% 
% 1. Learn the rule base while keeping the input and output MF parameters constant.
% 2. Tune the parameters of the input/output MFs and rules.

% options = tunefisOptions('OptimizationType','learning');
options = tunefisOptions('Method','particleswarm',...
    'OptimizationType','learning');
options.MethodOptions.MaxIterations = 20;
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
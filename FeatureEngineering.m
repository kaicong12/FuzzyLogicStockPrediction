% Load the CSV file
filename = 'NFLX.csv';
data = readtable(filename);

% Extract relevant columns
open_prices = data.Open;
high_prices = data.High;
low_prices = data.Low;
close_prices = data.Close;
volume = data.Volume;

% Calculate moving averages
short_term_MA = movmean(close_prices, 5);
long_term_MA = movmean(close_prices, 20);

% Calculate rate of change (ROC)
roc = (close_prices(2:end) - close_prices(1:end-1)) ./ close_prices(1:end-1) * 100;

% Calculate relative strength index (RSI)
n = 14; % RSI period
delta = diff(close_prices);
gain = max(delta, 0);
loss = -min(delta, 0);
avg_gain = movmean(gain, n);
avg_loss = movmean(loss, n);
rs = avg_gain ./ avg_loss;
rsi = 100 - (100 ./ (1 + rs));

% Calculate price difference (output variable)
price_difference = close_prices(2:end) - close_prices(1:end-1);

% Combine the features into a new table
feature_data = data(1:end-1, :); % Skip the last row due to the next-day price difference
feature_data.ShortTermMA = short_term_MA(1:end-1);
feature_data.LongTermMA = long_term_MA(1:end-1);
feature_data.ROC = roc;
feature_data.RSI = rsi;
feature_data.price_diff = price_difference;

% Output the preprocessed data
output_filename = 'preprocessed_data.csv';
writetable(feature_data, output_filename);
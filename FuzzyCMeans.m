% Load the CSV file
filename = 'preprocessed_data.csv';
data = readtable(filename);

num_clusters = 3;

% Initialize a structure to store centroids
centroids = struct();

% Loop through the variables in the dataset
variable_names = data.Properties.VariableNames;
for i = 2:length(variable_names)
    % Start from 2 to skip the "date" variable

    var_name = variable_names{i};
    var_data = data.(var_name);
    [centers, membership_degree] = fcm(var_data, num_clusters);
    
    sorted_centroids = sort(centers);
    centroids.(var_name) = sorted_centroids;
end

% Get the min and max of each features, excluding the date column
data_array = table2array(data(:, 2:end));

% Find the minimum and maximum values for each variable
min_values = min(data_array);
max_values = max(data_array);
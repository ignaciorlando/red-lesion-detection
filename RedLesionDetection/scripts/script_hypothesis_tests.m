
config_hypothesis_tests

% Retrieve a list of evenly spaced reference FPI values
fpi_reference_values = logspace(log10(min_reference_value), log10(max_reference_value), number_of_samples);           
           
% Initialize the matrix of reference sensitivity values
reference_se_vals_to_compare = zeros(length(fpi_reference_values), length(curves_path) + 1);

% Concatenate the comparison curve so we have it always in the first
% coordinate
curves_path = cat(1, comparison_curve, curves_path);

% For each curve
for i = 1 : length(curves_path)
           
    % Load current curve
    load(curves_path{i});
    
    % Plot current FROC curve
    plot_froc(per_lesion_sensitivity, fpi);
    hold on
   
    % Get reference se values
    [reference_se_vals_to_compare(:,i)] = get_reference_sensitivities(fpi_reference_values, per_lesion_sensitivity, fpi);
    
    plot(fpi_reference_values, reference_se_vals_to_compare(:,i), 'Marker', 'o');
    
end

% Initialize the p values matrix
p_values = zeros(length(curves_path) - 1, 1);
h_values = zeros(length(curves_path) - 1, 1);

% Perform a series of Wilcoxon sign rank tests to analyze the statistical
% significance of the improvements
for i = 2 : length(curves_path)
    [p_values(i-1), h_values(i-1)] = signrank(reference_se_vals_to_compare(:,1), reference_se_vals_to_compare(:,i), 'tail','right','alpha',alpha);
end
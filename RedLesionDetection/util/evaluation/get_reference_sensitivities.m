
function [reference_se_vals] = get_reference_sensitivities(fpi_reference_values, per_lesion_sensitivity, fpi)

    % Sort FPI values
    [sorted_fpi, sorting] = sort(fpi);
    sorted_per_lesion_sensitivity = per_lesion_sensitivity(sorting);

    % Retrieve unique FPIs
    [u_sorted_fpi,index] = unique(sorted_fpi,'first');
    u_sorted_per_lesion_sensitivity = sorted_per_lesion_sensitivity(index);
    % Remove zeros from FPI and their corresponding sensitivities        
    non_zero_idxs = (u_sorted_fpi~=0);
    u_sorted_fpi = u_sorted_fpi(non_zero_idxs);
    u_sorted_per_lesion_sensitivity = u_sorted_per_lesion_sensitivity(non_zero_idxs);
    % Improve the arrays
    values_to_complete = fpi_reference_values(logical(ones(1, length(fpi_reference_values)) - (min(u_sorted_fpi) < fpi_reference_values)));
    u_sorted_fpi = cat(2, values_to_complete, u_sorted_fpi); 
    u_sorted_per_lesion_sensitivity = cat(2, zeros(size(values_to_complete)), u_sorted_per_lesion_sensitivity);

    % Interpolate values
    reference_se_vals = interp1(u_sorted_fpi, u_sorted_per_lesion_sensitivity, fpi_reference_values, 'spline') ;
    reference_se_vals(reference_se_vals<0) = 0;
    
    % Transpose to get a nice column vector
    reference_se_vals = reference_se_vals';

end
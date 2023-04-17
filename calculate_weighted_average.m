function [weighted_average, left_index, right_index] = calculate_weighted_average(spectrum, derivative_spectrum)
    % Find the maximum peak of the derivative spectrum
    [max_derivative, max_index] = max(derivative_spectrum);
    
    % Find the half-height width of the peak
    half_height = max_derivative / 2;
    left_index = find(derivative_spectrum(1:max_index) <= half_height, 1, 'last');
    right_index = find(derivative_spectrum(max_index:end) <= half_height, 1, 'first') + max_index - 1;
    
    % Perform the weighted average of the wavelength
    weighted_sum = sum(spectrum(left_index:right_index, 1) .* derivative_spectrum(left_index:right_index));
    total_intensity = sum(derivative_spectrum(left_index:right_index));
    weighted_average = weighted_sum / total_intensity;
    
    % Display the weighted average wavelength
    fprintf('Weighted average optical gap: %.2f\n', weighted_average);
end


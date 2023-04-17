function area_J = calculate_J(stitched_spectrum, other_spectrum)
    % Interpolate the stitched spectrum over the overlap range
    overlap_indices = (other_spectrum(:, 1) >= min(stitched_spectrum(:, 1))) & (other_spectrum(:, 1) <= max(stitched_spectrum(:, 1)));
    overlap_wavelengths = other_spectrum(overlap_indices, 1);
    interpolated_stitched_spectrum = interp1(stitched_spectrum(:, 1), stitched_spectrum(:, 2), overlap_wavelengths, 'linear');
    
    % Multiply the spectra
    product_spectrum = other_spectrum(overlap_indices, 2) .* interpolated_stitched_spectrum/100;
    
    % Calculate the area
    area_J = trapz(overlap_wavelengths, product_spectrum)*1.602E-19/10;
end

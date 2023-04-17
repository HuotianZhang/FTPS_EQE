function [stitched_spectrum, stitching_point] = stitch(spectrum1, spectrum2, axes_handle)
    % Find the overlap range
    overlap_range = find_overlap_range(spectrum1, spectrum2);
    
    % Get the stitching point from the user
    stitching_point = get_stitching_point(axes_handle, overlap_range);
    
    % Stitch the spectra
    index1 = find(spectrum1(:, 1) <= stitching_point, 1, 'last');
    index2 = find(spectrum2(:, 1) >= stitching_point, 1, 'first');
    
    % Interpolate intensities near the stitching point
    intensity1 = interp1(spectrum1(:, 1), spectrum1(:, 2), stitching_point, 'linear', 'extrap');
    intensity2 = interp1(spectrum2(:, 1), spectrum2(:, 2), stitching_point, 'linear', 'extrap');
    
    scale_factor = intensity2 / intensity1;
    spectrum1_scaled = spectrum1;
    spectrum1_scaled(:, 2) = spectrum1(:, 2) * scale_factor;
    
    stitched_spectrum = [spectrum1_scaled(1:index1, :); spectrum2(index2:end, :)];
end

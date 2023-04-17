function plot_gap_analysis(gui)
    stitched_spectrum = gui.stitched_spectrum;
    % Plot the stitched spectrum
    plot(gui.axes1, stitched_spectrum(:, 1), stitched_spectrum(:, 2));
    
    % Smooth the stitched spectrum
    smoothed_spectrum = smoothdata(stitched_spectrum(:, 2), 'gaussian');
    
    % Calculate the derivative of the smoothed spectrum
    derivative_spectrum = gradient(smoothed_spectrum) ./ gradient(stitched_spectrum(:, 1));
    
    % Plot the derivative of the smoothed spectrum
    plot(gui.axes2, stitched_spectrum(:, 1), derivative_spectrum);

    % Calculate the weighted average wavelength
    [weighted_average, left_index, right_index] = calculate_weighted_average(stitched_spectrum, derivative_spectrum);
    
    % Plot the weighted average wavelength on the spectrum
    hold(gui.axes1, 'on');
    plot(gui.axes1, [weighted_average, weighted_average], gui.axes1.YLim, 'r--');
    hold(gui.axes1, 'off');
    
    % Plot the weighted average wavelength on the derivative spectrum
    hold(gui.axes2, 'on');
    
    % Shade the averaged area
    x = [stitched_spectrum(left_index:right_index, 1); flipud(stitched_spectrum(left_index:right_index, 1))];
    y = [zeros(right_index - left_index + 1, 1); flipud(derivative_spectrum(left_index:right_index))];
    fill(gui.axes2, x, y, [0.9, 0.9, 0.9], 'EdgeColor', 'none');
   
    plot(gui.axes2, [weighted_average, weighted_average], gui.axes2.YLim, 'r--');

    hold(gui.axes2, 'off');

    [J0, JSC, Vocrad] = calculate_J0_JSC_VOC(gui.stitched_spectrum);

    gui.gap = weighted_average;
    gui.vocsq = calculate_vocsq(weighted_average);
    gui.vocrad = Vocrad;

    fprintf('Area of the product of BB.txt and stitched spectrum: %.2f\n', J0);
    fprintf('Area of the product of AM15G and stitched spectrum: %.2f\n', JSC);
    fprintf('Voc,rad of stitched spectrum: %.2f\n', Vocrad);
    fprintf('Voc,sq of stitched spectrum: %.2f\n', gui.vocsq);


    gui.window.UserData = gui;
end

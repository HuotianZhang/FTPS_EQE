function vocsq = calculate_vocsq(opticalgap)
    % Define the range of wavelengths to plot (in microns)
    energy_min = opticalgap;
    energy_max = 5;
    energy = linspace(energy_min, energy_max, 1000);
    
    % Define the intensity at each wavelength (all 100)
    intensity = 100 * ones(size(energy));
    ideal_spectrum = [energy; intensity];
    ideal_spectrum = transpose(ideal_spectrum);
    [~, ~, vocsq] = calculate_J0_JSC_VOC(ideal_spectrum);
end
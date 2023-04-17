function spectrum = load_spectrum(file)
    data = load(file);
    spectrum = data(:, [1, 2]);
    spectrum = sortrows(spectrum, 1);%sort
end
function overlap_range = find_overlap_range(spectrum1, spectrum2)
    min1 = min(spectrum1(:, 1));
    max1 = max(spectrum1(:, 1));
    min2 = min(spectrum2(:, 1));
    max2 = max(spectrum2(:, 1));
    
    overlap_range = [max(min1, min2), min(max1, max2)];
end


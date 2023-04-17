function stitching_point = get_stitching_point(axes_handle, overlap_range)
    stitching_point = [];
    while isempty(stitching_point)
        [x, ~] = ginput(1);
        if x >= overlap_range(1) && x <= overlap_range(2)
            stitching_point = x;
        else
            warndlg('Please select a point within the overlap range.', 'Invalid Stitching Point');
        end
    end
end


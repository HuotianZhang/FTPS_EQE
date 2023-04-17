function stitch_spectra_GUI
    % Create the GUI window
    gui = create_GUI();
    
    % Wait for user to load spectra and stitch them
    uiwait(gui.window);
end

function gui = create_GUI
    gui.window = figure('Name', 'Spectra Stitching', 'NumberTitle', 'off', ...
                        'Position', [100, 100, 600, 400], ...
                        'CloseRequestFcn', @close_GUI);

    gui.load_spectrum1_button = uicontrol('Parent', gui.window, 'Style', 'pushbutton', ...
                                          'String', 'Load Spectrum 1', ...
                                          'Position', [50, 350, 150, 40], ...
                                          'Callback', @load_spectrum1_button_callback);

    gui.load_spectrum2_button = uicontrol('Parent', gui.window, 'Style', 'pushbutton', ...
                                          'String', 'Load Spectrum 2', ...
                                          'Position', [400, 350, 150, 40], ...
                                          'Callback', @load_spectrum2_button_callback);

    gui.stitch_button = uicontrol('Parent', gui.window, 'Style', 'pushbutton', ...
                                  'String', 'Stitch Spectra', ...
                                  'Position', [250, 100, 100, 40], ...
                                  'Callback', @stitch_button_callback, ...
                                  'Enable', 'off');
    
    gui.axes = axes(gui.window, 'Units', 'pixels', 'Position', [75, 125, 450, 200]);
    xlabel(gui.axes, 'Wavelength');
    ylabel(gui.axes, 'Intensity');
    title(gui.axes, 'Spectra Overlap');

    gui.spectrum1 = [];
    gui.spectrum2 = [];
end

function close_GUI(~, ~)
    delete(gcf);
end

function load_spectrum1_button_callback(hObject, ~)
    [filename, pathname] = uigetfile({'*.txt'}, 'Select Spectrum 1 Data File');
    if filename
        hObject.Parent.UserData.spectrum1 = load_spectrum(fullfile(pathname, filename));
        plot_spectra(hObject.Parent.UserData);
    end
end

function load_spectrum2_button_callback(hObject, ~)
    [filename, pathname] = uigetfile({'*.txt'}, 'Select Spectrum 2 Data File');
    if filename
        hObject.Parent.UserData.spectrum2 = load_spectrum(fullfile(pathname, filename));
        plot_spectra(hObject.Parent.UserData);
    end
end

function stitch_button_callback(hObject, ~)
    gui = hObject.Parent.UserData;
    [stitched_spectrum, stitching_point] = stitch(gui.spectrum1, gui.spectrum2, gui.axes);
    plot(gui.axes, stitched_spectrum(:, 1), stitched_spectrum(:, 2), 'k', 'LineWidth', 2);
    legend(gui.axes, 'Stitched Spectrum');
    title(gui.axes, ['Stitched Spectrum at Wavelength ', num2str(stitching_point)]);
    
    % Save the stitched spectrum
    [filename, pathname] = uiputfile({'*.txt'}, 'Save Stitched Spectrum As');
    if filename
        save_spectrum(stitched_spectrum, fullfile(pathname, filename));
    end
end

function spectrum = load_spectrum(file)
    data = load(file);
    spectrum = data(:, [1, 2]);
end

function plot_spectra(gui)
    if ~isempty(gui.spectrum1) && ~isempty(gui.spectrum2)
        plot(gui.axes, gui.spectrum1(:, 1), gui.spectrum1(:, 2), 'b', gui.spectrum2(:, 1), gui.spectrum2(:, 2), 'r');
        xlabel(gui.axes, 'Wavelength');
        ylabel(gui.axes, 'Intensity');
        title(gui.axes, 'Spectra Overlap');
        legend(gui.axes, 'Spectrum 1', 'Spectrum 2');
    
        gui.stitch_button.Enable = 'on';
    end
end

function [stitched_spectrum, stitching_point] = stitch(spectrum1, spectrum2, axes_handle)
% Find the overlap range
    overlap_range = find_overlap_range(spectrum1, spectrum2);
    % Get the stitching point from the user
    stitching_point = get_stitching_point(axes_handle, overlap_range);
    
    % Stitch the spectra
    index1 = find(spectrum1(:, 1) <= stitching_point, 1, 'last');
    index2 = find(spectrum2(:, 1) >= stitching_point, 1, 'first');
    
    intensity1 = spectrum1(index1, 2);
    intensity2 = spectrum2(index2, 2);
    
    scale_factor = intensity1 / intensity2;
    spectrum2_scaled = spectrum2;
    spectrum2_scaled(:, 2) = spectrum2(:, 2) * scale_factor;
    
    stitched_spectrum = [spectrum1(1:index1, :); spectrum2_scaled(index2:end, :)];
end

function overlap_range = find_overlap_range(spectrum1, spectrum2)
    min1 = min(spectrum1(:, 1));
    max1 = max(spectrum1(:, 1));
    min2 = min(spectrum2(:, 1));
    max2 = max(spectrum2(:, 1));
    overlap_range = [max(min1, min2), min(max1, max2)];

end

function stitching_point = get_stitching_point(axes_handle, overlap_range)
    dcm = datacursormode(ancestor(axes_handle, 'figure'));
    dcm.Enable = 'on';
    dcm.SnapToDataVertex = 'off';
    title(axes_handle, 'Click on the desired stitching point within the overlap range');
    % Wait for user to click on a point
    waitfor(axes_handle, 'CurrentPoint');
    cursor_info = dcm.getCursorInfo();
    stitching_point = cursor_info.Position(1);
    
    dcm.Enable = 'off';
    if stitching_point < overlap_range(1) || stitching_point > overlap_range(2)
        error('Selected point is outside of the overlap range. Please try again.');
    end
end

function save_spectrum(spectrum, file)
    save(file, 'spectrum', '-ascii', '-double');
end


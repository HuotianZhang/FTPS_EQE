%----------------------
% --- Copyrights (C) ---
% ----------------------
%
% stitch_spectra_GUI -- for the connection of two spectra
% Copyright (C)  Huotian Zhang
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.
%
% Last Modified 14-Apr-2023

function stitch_spectra_GUI
    % Create the GUI window
    gui_main = create_GUI();
    
    % Wait for user to load spectra and stitch them
    uiwait(gui_main.window);
end

function gui_main = create_GUI
    gui_main.window = figure('Name', 'Spectra Stitching', 'NumberTitle', 'off', ...
                        'Position', [100, 100, 600, 400], ...
                        'CloseRequestFcn', @close_GUI);

    gui_main.load_spectrum1_button = uicontrol('Parent', gui_main.window, 'Style', 'pushbutton', ...
                                          'String', 'Load Spectrum 1 (FTPS)', ...
                                          'Position', [50, 350, 150, 40], ...
                                          'Callback', @load_spectrum1_button_callback);

    gui_main.load_spectrum2_button = uicontrol('Parent', gui_main.window, 'Style', 'pushbutton', ...
                                          'String', 'Load Spectrum 2 (EQE)', ...
                                          'Position', [400, 350, 150, 40], ...
                                          'Callback', @load_spectrum2_button_callback);

    gui_main.stitch_button = uicontrol('Parent', gui_main.window, 'Style', 'pushbutton', ...
                                  'String', 'Stitch Spectra', ...
                                  'Position', [250, 100, 100, 40], ...
                                  'Callback', @stitch_button_callback, ...
                                  'Enable', 'off');
    
    gui_main.loss_analysis_button = uicontrol('Parent', gui_main.window, 'Style', 'pushbutton', ...
                                         'String', 'Loss Analysis', ...
                                         'Position', [450, 20, 100, 40], ...
                                         'Callback', @loss_analysis_button_callback, ...
                                         'Enable', 'off');

    gui_main.load_stitched_spectrum_button = uicontrol('Parent', gui_main.window, 'Style', 'pushbutton', ...
                                                  'String', 'Load Stitched Spectrum', ...
                                                  'Position', [50, 20, 150, 40], ...
                                                  'Callback', @load_stitched_spectrum_button_callback);


    % add a switch control to the figure
    gui_main.save_switch_button = uicontrol('Style', 'togglebutton', 'String', 'Not Saving', ...
    'Position', [300 20 80 40], 'Parent', gui_main.window, ...
    'Callback', @save_switch_button_callback);

    gui_main.axes = axes(gui_main.window, 'Units', 'pixels', 'Position', [75, 125, 450, 200]);
    xlabel(gui_main.axes, 'Wavelength');
    ylabel(gui_main.axes, 'Intensity');
    title(gui_main.axes, 'Spectra Overlap');

    gui_main.spectrum1 = [];
    gui_main.spectrum2 = [];
    gui_main.spectrum = [];
    gui_main.window.UserData = gui_main;
end

function save_switch_button_callback(source, ~)
    if get(source, 'value')
        set(source, 'string', 'Saving');
        %disp(get(source, 'value'));
    else
        set(source, 'string', 'Not Saving');
        %disp(get(source, 'value'));
    end
end

function load_spectrum1_button_callback(hObject, ~)
    gui = hObject.Parent.UserData;
    [filename, pathname] = uigetfile({'*.txt'}, 'Select Spectrum 1 Data File');
    if filename
        gui.spectrum1 = load_spectrum(fullfile(pathname, filename));
        hObject.Parent.UserData = gui;
        plot_spectra_main(gui);
    end
end

function load_spectrum2_button_callback(hObject, ~)
    gui = hObject.Parent.UserData;
    [filename, pathname] = uigetfile({'*.txt'}, 'Select Spectrum 2 Data File');
    if filename
        gui.spectrum2 = load_spectrum(fullfile(pathname, filename));
        hObject.Parent.UserData = gui;
        plot_spectra_main(gui);
    end
end



function stitch_button_callback(hObject, ~)
    gui = hObject.Parent.UserData;
    [stitched_spectrum, stitching_point] = stitch(gui.spectrum1, gui.spectrum2, gui.axes);

%load stitched into gui
    gui.spectrum = stitched_spectrum;
    semilogy(gui.axes, stitched_spectrum(:, 1), stitched_spectrum(:, 2), 'k', 'LineWidth', 2);
    legend(gui.axes, 'Stitched Spectrum');
    title(gui.axes, ['Stitched Spectrum at Wavelength ', num2str(stitching_point)]);
    
    % Save the stitched spectrum
    if get(gui.save_switch_button, 'value')
        [filename, pathname] = uiputfile({'*.txt'}, 'Save Stitched Spectrum As');
    else
        filename = 0;
    end
    if filename
        save_spectrum(stitched_spectrum, fullfile(pathname, filename));
    end
    gui.loss_analysis_button.Enable = 'on';

end

function load_stitched_spectrum_button_callback(hObject, ~)
    gui = hObject.Parent.UserData;
    
    [filename, pathname] = uigetfile({'*.txt'}, 'Select Stitched Spectrum');
    if filename
        gui.spectrum = load_spectrum(fullfile(pathname, filename));
        hObject.Parent.UserData = gui;
        gui.loss_analysis_button.Enable = 'on';
    end
end

function loss_analysis_button_callback(hObject, ~)
    gui = hObject.Parent.UserData;
    % if isfield(gui, 'stitched_spectrum')
    gui_loss = loss_analysis_GUI();
    gui_loss.stitched_spectrum = gui.spectrum;
    gui_loss.window.UserData = gui_loss;
    plot_gap_analysis(gui_loss)
    % Wait for user to load spectra and stitch them
    uiwait(gui_loss.window);
    % end
end



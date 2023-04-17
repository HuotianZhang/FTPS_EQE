function gui_loss = loss_analysis_GUI()
    gui_loss.window = figure('Name', 'Loss Analysis', 'NumberTitle', 'off', ...
                    'Position', [100, 100, 800, 1000], ...
                    'CloseRequestFcn', @close_GUI);

    %Table to displayed calculated VOC loss
    gui_loss.data_table = uitable(gui_loss.window, ...
                             'Position', [50, 800, 700, 200], ...
                             'ColumnName', {'Gap', 'Voc,sq', 'Voc,rad', 'Voc'}, ...
                             'ColumnWidth', {'auto'}, ...
                             'ColumnEditable', [false, false, false, false], ...
                             'Data', []);
    
    gui_loss.axes1 = axes(gui_loss.window, 'Units', 'pixels', 'Position', [50, 520, 700, 250]);
    xlabel(gui_loss.axes1, 'Wavelength');
    ylabel(gui_loss.axes1, 'Intensity');
    title(gui_loss.axes1, 'Stitched Spectrum');

    gui_loss.axes2 = axes(gui_loss.window, 'Units', 'pixels', 'Position', [50, 200, 700, 250]);
    xlabel(gui_loss.axes2, 'Wavelength');
    ylabel(gui_loss.axes2, 'Intensity Derivative');
    title(gui_loss.axes2, 'Loss Analysis (Intensity Derivative)');

    gui_loss.load_spectrum_button = uicontrol('Parent', gui_loss.window, 'Style', 'pushbutton', ...
                                                  'String', 'Load Stitched Spectrum', ...
                                                  'Position', [50, 80, 150, 30], ...
                                                  'Callback', @load_spectrum_button_callback);


    gui_loss.plot_gap_analysis_button = uicontrol('Parent', gui_loss.window, 'Style', 'pushbutton', ...
                                                  'String', 'Plot Gap Analysis', ...
                                                  'Position', [250, 80, 150, 30], ...
                                                  'Callback', @plot_gap_analysis_button_callback, ...
                                                  'Enable', 'off');

    % gui_loss.Cal_J0_button = uicontrol('Parent', gui_loss.window, 'Style', 'pushbutton', ...
    %                                'String', 'Calculate J0', ...
    %                                'Position', [450, 100, 100, 40], ...
    %                                'Callback', @Cal_J0_button_callback);
    
    gui_loss.Cal_VOC_button = uicontrol('Parent', gui_loss.window, 'Style', 'pushbutton', ...
                                      'String', 'Cal Voc', ...
                                      'Position', [600, 80, 100, 30], ...
                                      'Callback', @Cal_VOC_button_callback);

    % Create the text description
    uicontrol('Style', 'text', 'String', 'EQE_EL', 'Position', [450 110 100 30]);
    % Create the editbox for EQE_EL
    gui_loss.EQE_EL_Edit = uicontrol('Parent', gui_loss.window, 'Style', 'edit', 'String', '1', 'Position', [450 80 100 30], ...
    'Callback', @EQE_EL_editBox_Callback);

    gui_loss.stitched_spectrum = [];
    gui_loss.gap = [];
    gui_loss.vocsq = [];
    gui_loss.vocrad = [];
    gui_loss.voc = [];
    gui_loss.eqeel = 1;
    gui_loss.window.UserData = gui_loss;

end

function load_spectrum_button_callback(hObject, ~)
    gui = hObject.Parent.UserData;
    
    [filename, pathname] = uigetfile({'*.txt'}, 'Select Stitched Spectrum');
    if filename
        gui.stitched_spectrum = load_spectrum(fullfile(pathname, filename));
        hObject.Parent.UserData = gui;
        gui.plot_gap_analysis_button.Enable = 'on';
    end
end


function plot_gap_analysis_button_callback(hObject, ~)
    gui = hObject.Parent.UserData;
    plot_gap_analysis(gui);
end

% function Cal_J0_button_callback(hObject, ~)
%     gui = hObject.Parent.UserData; 
%     if isfield(gui, 'stitched_spectrum')
%         [J0, JSC, Vocrad] = calculate_J0_JSC_VOC(gui.stitched_spectrum);
%         % spectrum_BB = load_spectrum('BB.txt');
%         % J0 = calculate_J(gui.stitched_spectrum, spectrum_BB);
%         % % Update the data table
%         % update_data_table(gui.data_table, 'BB.txt', J0);
%         fprintf('Area of the product of BB.txt and stitched spectrum: %.2f\n', J0);
%         % spectrum_AM15G = load_spectrum('AM15G.txt');
%         % JSC = calculate_J(gui.stitched_spectrum, spectrum_AM15G);
%         % % Update the data table
%         % update_data_table(gui.data_table, 'AM15G', JSC);
%         fprintf('Area of the product of AM15G and stitched spectrum: %.2f\n', JSC);
%         % %Calculate Voc,rad
%         % Vocrad = calculate_voc(JSC,J0);
%         fprintf('Voc,rad of stitched spectrum: %.2f\n', Vocrad);
% 
%     else
%         warning('Stitched spectrum not available. Please stitch or load a stitched spectrum first.');
%     end
% end

function Cal_VOC_button_callback(hObject, ~)
    gui = hObject.Parent.UserData;

    if gui.vocrad
        gui.voc = gui.vocrad + 0.0259*log(gui.eqeel);
        gui.window.UserData = gui;
    else

        % There is no Voc,rad. Define the warning message
        warningMsg = 'No Voc,rad. Please enter a numerical value:';
        
        % Create the input dialog box
        answer = inputdlg(warningMsg, 'Warning', [1 50], {'1'});
        
        % Check if the user clicked the Cancel button
        if isempty(answer)
            disp('User clicked Cancel');
        else
            % Convert the input value to a number
            inputValue = str2double(answer{1});
            
            % Check if the input value is a number
            if isnan(inputValue)
                disp('Invalid input value');
            else
                % Make sure the input value (Voc,rad) reasonable 
                if inputValue<=0 %|| inputValue>1 
                    disp('Invalid input value');
                else
                    gui.voc = inputValue + 0.0259*log(gui.eqeel);
                    gui.window.UserData = gui;

                    %disp(['Input value is: ' num2str(inputValue)]);
                end
            end
        end
        fprintf('Voc from Voc,rad and EQE_EL: %.2f\n', gui.voc);
        % warning('Stitched spectrum not available. Please stitch or load a stitched spectrum first.');
    end
    % Update the data table
    update_data_table(gui.data_table, gui.gap, gui.vocsq, gui.vocrad, gui.voc);

end

% Callback function to limit input to numerical values and less than 1
function EQE_EL_editBox_Callback(hObject, ~)
    % Get the input value
    inputValue = get(hObject, 'String');
    
    % Clear any non-numeric characters
    numericValue = str2double(inputValue);
    if isnan(numericValue)
        set(hObject, 'String', '');
        return
    end
    
    % Limit the input to be less than 1
    if (numericValue > 1) || (numericValue < 0)
        set(hObject, 'String', '1');
        numericValue = 1;
    end

    gui = hObject.Parent.UserData;
    gui.eqeel = numericValue;
    gui.window.UserData = gui;
end
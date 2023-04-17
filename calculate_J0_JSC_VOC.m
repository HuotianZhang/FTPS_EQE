function [J0, JSC, VOC] = calculate_J0_JSC_VOC(spectrum)
    spectrum_BB = load_spectrum('BB.txt');
    J0 = calculate_J(spectrum, spectrum_BB);
    % Update the data table
    % update_data_table(gui.data_table, 'BB.txt', J0);
    % fprintf('Area of the product of BB.txt and stitched spectrum: %.2f\n', J0);
    spectrum_AM15G = load_spectrum('AM15G.txt');
    JSC = calculate_J(spectrum, spectrum_AM15G);
    % Update the data table
    % update_data_table(gui.data_table, 'AM15G', JSC);
    % fprintf('Area of the product of AM15G and stitched spectrum: %.2f\n', JSC);
    %Calculate Voc,rad
    VOC = calculate_voc(JSC,J0);
    % fprintf('Voc,rad of the spectrum: %.2f\n', VOC);

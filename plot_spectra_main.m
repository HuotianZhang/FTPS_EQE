function plot_spectra_main(gui)
    if ~isempty(gui.spectrum1) && ~isempty(gui.spectrum2)
        semilogy(gui.axes, gui.spectrum1(:, 1), gui.spectrum1(:, 2), 'b', ...
             gui.spectrum2(:, 1), gui.spectrum2(:, 2), 'r');
        xlabel(gui.axes, 'Wavelength');
        ylabel(gui.axes, 'Intensity');
        title(gui.axes, 'Spectra Overlap');
        legend(gui.axes, 'Spectrum 1', 'Spectrum 2');
        
        gui.stitch_button.Enable = 'on';
    end
end

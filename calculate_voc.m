function voc = calculate_voc(JSC, J0)
    voc = 300*8.6e-5*log(JSC/J0+1);
end
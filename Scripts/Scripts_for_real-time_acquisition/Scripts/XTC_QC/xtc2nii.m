function xtc2nii(xtcDir, niiOutDir, template_hdr_file, ExpCode, volume, nSlices)  
    [DATA INFO]=loadPARREC([xtcDir '/Dump-' sprintf('%04d',(volume-1)) '.par']);
    for slice=1:nSlices
        PAR(:,:,slice) = fliplr(DATA(:,:,slice,1,1,1)');
    end
    infoVol = spm_vol(template_hdr_file);
    infoVol.fname=[niiOutDir '\Volume' sprintf('%03d',volume) '.nii'];
    infoVol=rmfield(infoVol,'pinfo'); spm_write_vol(infoVol,PAR);
    % 2ADD store timing data and print at the end of the sequence
return

function template_hdr=step5_rt_QC(xtcDir,dcmDir,niixDir,ExpCode,SubCode,nVolumes,nSlices)

% author: Stavros Skouras
% dependencies dcm2niix (MRIcroGL), spm & readPARREC.m 

% TO ENSURE QUALITY, THIS PROCEDURE MUST BE RAN FOR EVERY EXPERIMENT/SEQUENCE SCHEDULED FOR rt-fMRI

copyfile([dcmDir '/*'], ['D:\NPAD\' ExpCode '/DATA/' SubCode '/realtime_localizer/'])

if ~exist([niixDir '\rtfMRI_' ExpCode '_template_hdr_file.nii'],'file')

    % Step 2: Check the correspondence between the online (par/rec) format and offline (dicom) versions of the same sequence acquisition.
    % report_file = cmp_PAR2NII(xtc_dir, nii_folder_with_exactly_same_data, your_experiment_name);

        % create single-volume files for whole sequence with identical values to par/rec versions
        pwDir=pwd; cd D:\NPAD\Resources\Software\MRIcroGL\mricrogl
        command = ['dcm2niix -o ' [niixDir] ' ' dcmDir] ; system(command); cd(pwDir);
        %fnii4D=ls([niixDir '\*']); flist = spm_file_split([niixDir '\' fnii4D(3,:)]); 
        fnii4D=ls([niixDir '\*.nii']); flist = spm_file_split([niixDir '\' fnii4D(1,:)]); 

        % Check data
        for volume = 1:nVolumes;
            Vol=num2str(volume)
            ParRecVol=num2str(volume-1);
            % load reference data
            inpFile=flist(volume).fname; infoVol = spm_vol(inpFile); imgVol  = spm_read_vols(infoVol);
            % load Par/Rec data while fixing orientation
            [DATA INFO]=loadPARREC([xtcDir '/Dump-' sprintf('%04d',(volume-1)) '.par']);
            for slice=1:nSlices
                PAR(:,:,slice) = fliplr(DATA(:,:,slice,1,1,1)');
            end
            % compare data, allowing for % variation & display/report any inconsistencies
            if nnz(abs(imgVol(:)-PAR(:))>0.02)>0; % how do I find this 0.02 threshold?
                    display(['PROBLEM WITH SLICE ' num2str(slice) ' IN VOLUME ' num2str(volume)]); 
            end
        end

    % % Step 3: Obtain a hdr template for the specific sequence you are going to be using in the realtime paradigm.
    % template_hdr_file = get_template_hdr(nii_folder_with_exactly_same_data)
    infoVol.fname=[niixDir '\rtfMRI_' ExpCode '_template_hdr_file.nii'];
    template_hdr=[niixDir '\rtfMRI_' ExpCode '_template_hdr_file.nii'];
    infoVol=rmfield(infoVol,'pinfo'); spm_write_vol(infoVol,PAR);

end

% Step 4: Insert the online conversion function "xtc2nii(xtc_folder, nii_folder, template_hdr_file)" into your pipeline.

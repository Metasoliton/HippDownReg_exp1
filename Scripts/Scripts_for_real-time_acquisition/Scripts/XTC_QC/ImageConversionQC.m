% author: Stavros Skouras
% dependencies dcm2niix (MRIcroGL), spm & readPARREC.m 

% TO ENSURE QUALITY, THIS PROCEDURE MUST BE RAN FOR EVERY EXPERIMENT/SEQUENCE SCHEDULED FOR rt-fMRI
 
% Step 1: SET YOUR PATHS AND PARAMETERS
xtcDir='C:\xtc_output\0008'    % the path to the folder where the test Par/Rec data are stored; e.g. xtcDir='C:\xtc_output\0008'
dcmDir='D:\NPAD\Pilot1_Audiovisual_Stimulation\DATA\Pilot1\xtcQC\dcm\DICOMDIR' % the path to the folder where the exact same data are stored in dicom format; e.g. 'D:\NPAD\Pilot1_Audiovisual_Stimulation\DATA\Pilot1\xtcQC\dcm\DICOMDIR'
workingDir='D:\NPAD\Pilot1_Audiovisual_Stimulation\DATA\Pilot1\xtcQC\dcm2niix' % the path to the folder where some files are going to be created during the QC test; e.g. workingDir='D:\NPAD\Pilot1_Audiovisual_Stimulation\DATA\Pilot1\xtcQC\dcm2niix'
your_experiment_name='QCtest1'           % give a name to the experiment/sequence
numOfVols=500                      % number of volumes in your acquisition sequence
numOfSlices=46                    % number of slices in your acquisition sequence

if ~exist([workingDir '\rtfMRI_' ExpCode '_template_hdr_file.nii'],'file')

    % Step 2: Check the correspondence between the online (par/rec) format and offline (dicom) versions of the same sequence acquisition.
    % report_file = cmp_PAR2NII(xtc_dir, nii_folder_with_exactly_same_data, your_experiment_name);

        % create single-volume files for whole sequence with identical values to par/rec versions
        pwDir=pwd; cd D:\NPAD\Resources\Software\MRIcroGL\mricrogl
        command = ['dcm2niix -o ' [workingDir] ' ' dcmDir] ; system(command); cd(pwDir);
        fnii4D=ls([workingDir '\*']); flist = spm_file_split([workingDir '\' fnii4D(3,:)]); 

        % Check data
        for volume = 1:numOfVols;
            Vol=num2str(volume);
            ParRecVol=num2str(volume-1);
            % load reference data
            inpFile=flist(volume).fname; infoVol = spm_vol(inpFile); imgVol  = spm_read_vols(infoVol);
            % load Par/Rec data while fixing orientation
            [DATA INFO]=loadPARREC([xtcDir '/Dump-' sprintf('%04d',(volume-1)) '.par']);
            for slice=1:numOfSlices
                PAR(:,:,slice) = fliplr(DATA(:,:,slice,1,1,1)');
            end
            % compare data, allowing for % variation & display/report any inconsistencies
            if nnz(abs(imgVol(:)-PAR(:))>0.02)>0; % how do I find this 0.02 threshold?
                    display(['PROBLEM WITH SLICE ' num2str(slice) ' IN VOLUME ' num2str(count-1)]); 
            end
        end

    % % Step 3: Obtain a hdr template for the specific sequence you are going to be using in the realtime paradigm.
    % template_hdr_file = get_template_hdr(nii_folder_with_exactly_same_data)
    infoVol.fname=[workingDir '\rtfMRI_' ExpCode '_template_hdr_file.nii'];
    infoVol=rmfield(infoVol,'pinfo'); spm_write_vol(infoVol,PAR);

end

% Step 4: Insert the online conversion function "xtc2nii(xtc_folder, nii_folder, template_hdr_file)" into your pipeline.

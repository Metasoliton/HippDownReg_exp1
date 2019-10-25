function GUI = startupfunc_firsttest(GUI)
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Set plots and axes properties
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      GUI.plotXlim = [1 GUI.experiment.nrfeedback];
      GUI.plotYlim = [-4.0 4.0];     

      set(GUI.axesReg,'colororder',GUI.colortemp,'XLim',[1 GUI.plotXtotLim]);
      set(GUI.axesDisp,'colororder',GUI.colortemp,'XLim',GUI.plotXlim);
      
      set(GUI.axesClass,'colororder',GUI.colortemp,'XLim',GUI.plotXlim,'YLim',GUI.plotYlim);
      axes(GUI.axesClass);
      blockplot(GUI.experiment.feedbackinstr, GUI.plotYlim);
      hold on;
      GUI.ctrlsgnlplot = plot(1:GUI.experiment.nrfeedback,...
          NaN(1,GUI.experiment.nrfeedback),...
          'LineWidth',2);
      
      %prepare Application
      GUI.tic = tic;
%       GUI.experiment.application.connect([GUI.experiment.prefeedbackinstr;GUI.experiment.feedbackinstr],...
%           GUI.tic, GUI.logfp);
      
      %add tic to collector for logging
      GUI.experiment.collector.GUI_tic = GUI.tic;
      GUI.experiment.collector.logfp = GUI.logfp;
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % files and folders
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      epi_folder = '.\LocalizerData\';
      ROI_file = '.\ROIs\JLF\CA1_mask.nii';
      instruction = 'instructions_localizer.txt';
      
%       templfile = 'D:\NPAD\RETIF_test1\Software\Stavros\firsttest_Experiment\LocalizerData\20170126_154936WIPfMRIQC1SENSEs401a1004_00001.nii'
%        collector.input{1}='D:\NPAD\RETIF_test1\Software\Stavros\firsttest_Experiment\realtimedata\'
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % create brainmask from template
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      Ds = smooth3(GUI.experiment.template);
      brain_back_thresh = 0.16*max(Ds(:));
      GUI.brainmask = Ds>brain_back_thresh;
      labels = bwlabeln(GUI.brainmask);
      stats = regionprops(labels,'Area');
      [temp,idx]=max([stats.Area]);
      GUI.brainmask = ismember(labels,idx);
      GUI.brainmask = imfill(GUI.brainmask,'holes');
      %exclude the two lowest slices
      GUI.brainmask(:,:,1:2) = false;
      sze_data = size(GUI.brainmask);
      
      axes(GUI.axes3D);
      hiso = patch(isosurface(Ds,brain_back_thresh),'FaceColor',[1,.75,.65],'EdgeColor','none','FaceAlpha',0.5);
      lightangle(-90,50);
      view(-90,0);
      %daspect([1,1,1.0823]);
      hold on;
      axis off;
      
      GUI.experiment.data.applymask(GUI.brainmask);

      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % read ROIs
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      nii = load_untouch_nii(ROI_file);
      ROI = logical(nii.img);
      ROI = ROI(GUI.brainmask);

      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % read instructions
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      instr = dlmread(instruction);
      labels_train = instr(:,1);
      select_train = logical(instr(:,3));
      select_estim = logical(instr(:,2));
      GUI.experiment.classifier.trainsel = select_train;
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % read localizer data
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
      files = dir([epi_folder,'V*.nii']);
      nrvols = length(files);
      D = RT_Data(size(ROI), nrvols, select_estim, GUI.brainmask);
      for n = 1:nrvols
          nii = load_untouch_nii([epi_folder,files(n).name]);
          temp = single(nii.img);
          D = add_data(D,temp,n);
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % train classifier
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       GUI.experiment.classifier.train(ROI, D, nrvols);
      

      
classdef RT_Classifier_NPADv1 < RT_Classifier
    
    properties
        threshold % 
        ROI % 
        meanD
        stdD
        trainsel
        scale
        shift
    end
    
    methods
    
        %Constructor
        function C = RT_Classifier_NPADv1(input,selector)
            C.trainsel = selector;
            C.shift = 0;
        end
        
        % train classifier  
        function C = train(C,ROI,data,latest_dynnr)
            C.ROI = ROI;
            C.meanD = zeros(size(ROI));
            C.stdD = zeros(size(ROI));
                 
            %extract data inside ROI
            D = data.D(ROI,1:latest_dynnr);
            
            %detrend over ROI voxels
            D = RT_detrend_SP(double(D), 1, 200);
            data.Dfilt = D(:,end);
            
            %compute mean
            C.meanD(ROI) = mean(D(:,data.selector),2);
            
            %compute standard deviation
            C.stdD(ROI) = std(D(:,data.selector),0,2);

            CS = mean( (D-repmat(C.meanD(C.ROI),1,size(D,2)) )./repmat(C.stdD(C.ROI),1,size(D,2)));
            %CS = mean( (D-repmat(C.meanD(C.ROI),1,size(D,2)) ));
            %CS = mean(D);
            
            C.scale = 3/max(CS); % CS = control signal 
             C.scale = 1; % CS = control signal ##STAV
            
        end
        
        % test data GETS CALLED WITH VOLUME STAV
        function prediction = test(C,data,latest_dynnr)
            
            %detrend test sample
            D = RT_detrend_SP(data.D(C.ROI,1:latest_dynnr), 0, 200); % filtering - not linear trend
            %D = data.D(C.ROI, latest_dynnr);
            data.Dfilt = D;
            
            %normalize test sample and compute averages inside ROI
%#STAV            prediction = C.scale*mean( (D-C.meanD(C.ROI) )./C.stdD(C.ROI)) + C.shift;  % this is the value on display ##STAV
            %prediction = C.scale*mean( (D-C.meanD(C.ROI) ));
            %prediction = mean(D);
            
            
            
            
            
            
            
        %%%%%% ###### STAV
            global BSL NF_signal NFB_signal robot ExpCode SubCode
            % adaptive_BSL_4_test_function      
            curTrial=nnz(latest_dynnr>[40:30:460]); % because I have 40 prefeedback volumes and then I update the baseline every 30 volumes for 12 NFB trials.

            if curTrial==1;
                BSL(1).mean = C.meanD(C.ROI); % i.e. using the prefeedback data
                BSL(1).std  = C.stdD(C.ROI);
                prediction = C.scale*   mean(         (  D - BSL(1).mean )./BSL(1).std) + C.shift; %i.e  same as before, in the original test function
                % i.e. prediction  ~    mean_of_ROI (  (CurData - BSLmean) ./ BSLstd  )

%             elseif curTrial==2;
%                 prev_start=41; % first volume of previous trial
%                 prev_end=70;   % last volume of previous trial
% 
%                 % set new (adaptive) baseline mean
%                 if mean(mean(data.D(C.ROI, prev_start:prev_end),2)) > mean(C.meanD(C.ROI)); % i.e. if trial one was "GOOD"     %%%%% NOTE QUESTION: SHOULD THIS BE CHANGED TO A Z-SCORE COMPARISON?
% 
%                     BSL(2).mean = BSL(1).mean + 0.5 * (mean(data.D(C.ROI, prev_start:prev_end),2) - C.meanD(C.ROI)); % i.e. mean(prefeedback) + 0.5*(mean(NFB_trial_1) - mean(prefeedback))
%                     VR=1; % go one step faster
% 
%                 elseif mean(mean(data.D(C.ROI, prev_start:prev_end),2)) == mean(C.meanD(C.ROI)); % i.e. if trial one was the same as baseline
% 
%                     BSL(2).mean = BSL(1).mean; % i.e. prevBSL
%                     VR=0;  % same speed
% 
%                 elseif mean(mean(data.D(C.ROI, prev_start:prev_end),2)) < mean(C.meanD(C.ROI)); % i.e. if trial one was "BAD"
%                     BSL(2).mean = BSL(1).mean - 0.5 * ( C.meanD(C.ROI) - mean(data.D(C.ROI, prev_start:prev_end),2) ); % i.e. mean(prefeedback) - 1.5*(mean(prefeedback) - mean(NFB_trial_1))
%                     VR = -1; % go one step slower
%                 end    
% 
%                 % set new baseline std
%                 BSL(2).std  = std(data.D(C.ROI, prev_start:prev_end)')'; % i.e. std(NFB_trial_1)
% 
%                 % compute neurofeedback value
%                 prediction = C.scale *   mean( (  D - BSL(2).mean )./BSL(2).std) + C.shift; 
% 
% 
%             elseif curTrial>2;
%                 prev_start = 41 + ((curTrial-1)*30); % first volume of previous trial
%                 prev_end   = 70 + ((curTrial-1)*30); % last volume of previous trial
% 
%                 % set new (adaptive) baseline mean
%                 if mean(mean(data.D(C.ROI, prev_start:prev_end),2)) > mean(BSL(curTrial-1).mean); % i.e. if previous trial was "GOOD"   
%                     BSL(curTrial).mean = BSL(curTrial-1).mean + 0.5 * (mean(data.D(C.ROI, prev_start:prev_end),2) - BSL(curTrial-1).mean); % i.e. prevBSL + 0.5*(mean(prevTrial) - mean(prevBSL))
% 
%                 elseif mean(mean(data.D(C.ROI, prev_start:prev_end),2)) == mean(BSL(curTrial-1).mean); % i.e. if previous trial was the same as baseline
%                     BSL(curTrial).mean = BSL(curTrial-1).mean;  % i.e. prevBSL
% 
%                 elseif mean(mean(data.D(C.ROI, prev_start:prev_end),2)) < mean(BSL(curTrial-1).mean); % i.e. if trial one was "BAD"
%                     BSL(curTrial).mean = BSL(curTrial-1).mean - 0.5 * ( BSL(curTrial-1).mean - mean(data.D(C.ROI, prev_start:prev_end),2) ); % i.e. prevBSL - 1.5*(prevBSL - mean(prevTrial))
%                 end    
% 
%                 % set new baseline std
%                 BSL(curTrial).std  = std(data.D(C.ROI, prev_start:prev_end)')'; % i.e. std(prevTrial)
% 
%                % compute neurofeedback value
%                 prediction = C.scale *   mean( (  D - BSL(curTrial).mean )./BSL(curTrial).std) + C.shift; 
% 
%             end    
            else
                    % AIM: HIPP DOWN-REGULATION!
                        prediction = C.scale *   mean( (  D - BSL(1).mean )./BSL(1).std) + C.shift;
            end

            NFB_signal(latest_dynnr)=prediction;  

            if  NFB_signal(latest_dynnr) > mean(NFB_signal(1:(latest_dynnr-1))); 
            NF_signal(latest_dynnr)=-1

            elseif NFB_signal(latest_dynnr)< mean(NFB_signal(1:(latest_dynnr-1)));
            NF_signal(latest_dynnr)=1

            else NF_signal(latest_dynnr)=0
            end
            
            if  exist(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/NF_signal.txt'],'file')==0;
                 fid=fopen(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/NF_signal.txt'],'wt'); 
                 try
                 fprintf(fid, '%s\n', '0'); fprintf(fid, '%s\n', '0'); 
                 fclose(fid); 
                 catch
                 ['MISSED ONE']
                 robot=robot+1
                 end
                 
             else
                 fid=fopen(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/NF_signal.txt'],'r'); 
                 try
                     NF_previous=str2num(fgetl(fid)); 
                     state=str2num(fgetl(fid)); 
                 fclose(fid);
                 catch
                 ['MISSED ONE']
                 robot=robot+1
                 end

                 fid=fopen(['\\NI_DATA\Projects\MRI_Console\MRI_2_Stavros/NF_signal.txt'],'wt'); 
                 try
                     fprintf(fid, '%s\n', num2str(NF_signal(latest_dynnr))); 
                     fprintf(fid, '%s\n', num2str(abs(state-1))); 
                 fclose(fid);
                 catch
                 ['MISSED ONE']
                 robot=robot+1
                 end

            end
             
        end
        
        
        %%%%%% ###### STAV
        
        % shift baseline down
        function shiftUp(C)  
        
            C.shift = C.shift + 0.2;
            
        end
        
        % shift baseline up
        function shiftDown(C)  
            C.shift = C.shift - 0.2;
        end
        
    end
    
end
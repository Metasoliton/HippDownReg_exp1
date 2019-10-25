classdef RT_Classifier_NPADv2 < RT_Classifier
    
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
        function C = RT_Classifier_NPADv2(input,selector)
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
            curTrial=nnz(latest_dynnr>[40:30:600]); % because I have 100 prefeedback volumes and then I update the baseline every 30 volumes for 12 NFB trials.

            if curTrial==1;
                BSL(1).mean = C.meanD(C.ROI); % i.e. using the prefeedback data
                BSL(1).std  = C.stdD(C.ROI);
                prediction = C.scale*   mean(         (  D - BSL(1).mean )./BSL(1).std) + C.shift; %i.e  same as before, in the original test function
                % i.e. prediction  ~    mean_of_ROI (  (CurData - BSLmean) ./ BSLstd  )

                
            else
                prev_start = latest_dynnr - 31;
                prev_end   = latest_dynnr - 1;

                BSL(curTrial).mean = mean(data.D(C.ROI, prev_start:prev_end),2);

                % set new baseline std
                BSL(curTrial).std  = std(data.D(C.ROI, prev_start:prev_end)')'; 

               % compute neurofeedback value
                prediction = C.scale *   mean( (  D - BSL(curTrial).mean )./BSL(curTrial).std) + C.shift; 
            end
            
                NFB_signal(latest_dynnr)=prediction;
                        
            if  NFB_signal(latest_dynnr) < mean(NFB_signal((latest_dynnr-31):(latest_dynnr-1))); 
            NF_signal(latest_dynnr)=-1

            elseif NFB_signal(latest_dynnr)> mean(NFB_signal((latest_dynnr-31):(latest_dynnr-1)));
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
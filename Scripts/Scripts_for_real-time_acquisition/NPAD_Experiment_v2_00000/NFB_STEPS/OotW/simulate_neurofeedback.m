%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESCRIPTION:
% These functions simulate the output of the real-time neurofeeback analysis.
%
% Every 3 seconds they update a random variable that should control the VR speed.
%
% The current value of the variable is also displayed in the Matlab command window.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INSTRUCTIONS:
%
% To START the simulation type: 
%                               >> NF_simulation = simulate_neurofeedback(output_mode); 
%    
% When output_mode = 1, the simulated neurofeedback signal performs virtual keyboard presses
% When output_mode = 2, the simulated neurofeedback signal is stored in text file "NF_signal.txt"
% When output_mode = 3, the simulated neurofeedback signal is stored in Matlab variable "NF_signal"
% When output_mode = 4, the simulated neurofeedback signal is stored in MS-DOS variable "NF_signal"
% See comments below for more details.
%
%
% The simulation continues running indefinitely. 
% To STOP the simulation, type:
%                               >> stop(NF_simulation);  
%
%                            OR >> delete(timerfindall);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NOTES: 
% a) Please use Matlab version 2013b on Windows 7 to ensure compatibility with the neuroimaging analysis.
% b) It is a known Windows limitation that some applications need to be restarted to see updated MS-DOS variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR: Stavros Skouras; Barcelonabeta Brain Research Center; 17/02/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LICENSE: GPLv3 limited to educational and research use / please cite the author
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WARNING: Use at your own risk!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize timer
function simNF = simulate_neurofeedback(output_mode)
simNF = timer('ExecutionMode','fixedRate','Period',3,'TimerFcn',{@simulate_rtNF,output_mode}); 
start(simNF);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function simulate_rtNF(obj,evt,output_mode)
    
    NF_signal = randi(3)-2;     
    display(['NF_signal = ' num2str(NF_signal)]);  

    % When output_mode = 1, the simulated neurofeedback signal performs virtual keyboard presses: 
    %                             UP arrow ~ increase VR speed
    %                             DOWN arrow ~ decrease VR speed
    %                             LEFT arrow ~ keep same VR speed

    % NOTE: If you want to specify different buttons, see here: 
    % https://docs.oracle.com/javase/7/docs/api/java/awt/event/KeyEvent.html
    
    if output_mode==1;
        robot = java.awt.Robot; % initialize button-pressing robot
        if      NF_signal ==  1;    display( 'UP ~ 1');
            for i=1:2 % this presses the button twice - adapt if you need more button presses
            robot.keyPress (java.awt.event.KeyEvent.VK_UP); 
            robot.keyRelease (java.awt.event.KeyEvent.VK_UP);
            end
        elseif  NF_signal == -1;    display( 'DOWN ~ -1 ');
            for i=1:2 % this presses the button twice - adapt if you need more button presses
            robot.keyPress (java.awt.event.KeyEvent.VK_DOWN); 
            robot.keyRelease (java.awt.event.KeyEvent.VK_DOWN);
            end
        elseif  NF_signal ==  0;    display( 'LEFT ~ 0');
            for i=1:2 % this presses the button twice - adapt if you need more button presses
            robot.keyPress (java.awt.event.KeyEvent.VK_LEFT); 
            robot.keyRelease (java.awt.event.KeyEvent.VK_LEFT);
            end
        end
                
    % When output_mode = 2, the simulated neurofeedback signal is stored in text file "NF_signal.txt"
    %                             a value of  1 ~ increase VR speed
    %                             a value of -1 ~ decrease VR speed
    %                             a value of  0 ~ keep same VR speed
    elseif output_mode==2;
         if  ~exist('NF_signal.txt'); 
             fid=fopen('NF_signal.txt','wt'); fprintf(fid, '%s\n', '0'); fprintf(fid, '%s\n', '0'); 
             fclose(fid); 
         else
             fid=fopen('NF_signal.txt','r'); 
                 NF_previous=str2num(fgetl(fid)); 
                 state=str2num(fgetl(fid)); 
             fclose(fid);

             fid=fopen('NF_signal.txt','wt'); 
                 fprintf(fid, '%s\n', num2str(NF_signal)); 
                 fprintf(fid, '%s\n', num2str(abs(state-1))); 
             fclose(fid);
         end
         
         
    % When output_mode = 3, the simulated neurofeedback signal is stored in
    % Matlab variables "NF_signal" and NF_signal.mat
    %                             a value of  1 ~ increase VR speed
    %                             a value of -1 ~ decrease VR speed
    %                             a value of  0 ~ keep same VR speed
    elseif output_mode==3; 
        save('NF_signal.mat', 'NF_signal');
        
    % When output_mode = 4, the simulated neurofeedback signal is stored in MS-DOS variable "NF_signal"
    %                             a value of  1 ~ increase VR speed
    %                             a value of -1 ~ decrease VR speed
    %                             a value of  0 ~ keep same VR speed
    elseif output_mode==4;
    command=['setx NF_signal ' num2str(NF_signal)]; system(command) ;   

    else
        display('Please specify a valid output mode: 1 ~ keyboard button press; 2 ~ text file; 3 ~ Matlab variable; 4 ~ MS-DOS variable; ')

    end
    
    display(' ') % leave some space between reports
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
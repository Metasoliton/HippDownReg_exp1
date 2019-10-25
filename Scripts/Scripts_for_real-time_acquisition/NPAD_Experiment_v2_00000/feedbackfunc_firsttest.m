function GUI = feedbackfunc_firsttest(GUI)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pick up new data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    newdata = GUI.experiment.collector.data;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Motion Correction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if GUI.experiment.regon
        %Register volume to template
        [newdata, GUI.experiment.estimated_motion(GUI.experiment.collector.latest_dynnr,:)] = ...
            boldreg(GUI.experiment.template, newdata,...
            GUI.experiment.regpar(1),...
            GUI.experiment.regpar(2),...
            GUI.experiment.regpar(3));
%         [newdata,GUI.experiment.estimated_motion(GUI.experiment.collector.latest_dynnr,:)] = ...
%             RT_spmreg(GUI.experiment.template, newdata, [3,3,3]);
        newdata(newdata<0) = 0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Add new data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    add_data(GUI.experiment.data, newdata, GUI.experiment.collector.latest_dynnr);
    clear newdata;
    
    %decode new data sample
    %data = GUI.experiment.data.D(...
    %    :,GUI.experiment.collector.latest_dynnr);
    P = GUI.experiment.classifier.test(...
        GUI.experiment.data,...
        GUI.experiment.collector.latest_dynnr);
    
    
    % P is "prediction" ## STAV
    
    
    
    %update feedback
    %GUI.experiment.application.update(P);
    %temp = toc(GUI.tic); 
    %fprintf(GUI.logfp,'Update Feedback\t\t%f\n',temp);
    
    GUI.experiment.data.prediction(...
        GUI.experiment.collector.latest_dynnr) = P;
    
    %update plot
    set(GUI.ctrlsgnlplot,'YData',...
        GUI.experiment.data.prediction(GUI.experiment.nrprefeedback+1:end));
    

end
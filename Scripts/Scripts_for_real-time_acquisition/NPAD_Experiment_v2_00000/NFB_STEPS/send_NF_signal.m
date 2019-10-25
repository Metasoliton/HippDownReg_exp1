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

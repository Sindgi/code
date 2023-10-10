commandStr = 'fileuploader.py';
 [status, commandOut] = system(commandStr);
 if status==0
     fprintf(' result is %d\n',str2num(commandOut));
 end
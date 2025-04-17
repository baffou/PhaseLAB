function [fileName, k] = createFileName(prefix, folder)
% create a filename that does not exist in the specified folder. If the
% normal filename exists, increment it.
arguments
    prefix
    folder
end

k = 1;
exst = true;
while exst 
fileName = prefix+"_"+textkkk(k)+".tif";
if exist(folder+"/"+fileName,'file')
    k = k+1;
else
    exst = false;
end
end
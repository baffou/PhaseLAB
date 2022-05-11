function importIFDDAimages(folder)
folder=convertStringsToChars(folder);

if ~strcmpi(folder(end),'/')
    folder=[folder '/'];
end


I_fileList=dir([folder 'I*.txt']);
OPD_fileList=dir([folder 'I*.txt'])






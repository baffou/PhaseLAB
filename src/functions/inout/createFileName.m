function fileName = createFileName(prefix, folder, timeStamp, crop)
% create a filename that does not exist in the specified folder. If the
% normal filename exists, increment it.
arguments
    prefix
    folder
    timeStamp = []
    crop = []
end

if isempty(timeStamp) && isempty(crop)
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

elseif ~isempty(timeStamp) && ~isempty(crop)

    RefFileList = dir(folder+"/"+prefix+"*.tif");

    Nf = numel(RefFileList);

    for ii = 1:Nf

        info = imfinfo(folder+"/"+RefFileList(ii).name);
        MakeTag = info(1).Make;
        DateTimeTag = info(1).DateTime;
        if strcmp(DateTimeTag, datetime2str(timeStamp)) && strcmp(MakeTag, ROI2str(crop))
            fileName  = RefFileList(ii).name;
            return
        end

    end

    fileName = createFileName('REF', folder);

else
    error('please specify both datetime and crop parameters, or none, but not only one parameter')
end
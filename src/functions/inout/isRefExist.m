function fileName = createRefExist(folder,timeStamp,crop)

RefFileList = dir(folder+"/"+"Ref*.tif");

Nf = numel(RefFileList);

for ii = 1:Nf

    info = imfinfo(folder+"/"+RefFileList(ii).name);
    MakeTag = info(1).Make;
    DateTimeTag = info(1).DateTime;
    if strcmp(MakeTag, datetime2str(timeStamp)) && strcmp(DateTimeTag, ROI2str(crop))
        fileName  = RefFileList(ii).name;
        return
    end
end

fileName = createFileName('REF', folder);
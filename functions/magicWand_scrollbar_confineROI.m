function magicWand_scrollbar_confineROI(hfig)

title(gca,'Limit the area to work with')

roi = drawpolygon('FaceAlpha',0,'Color','g');

if isempty(hfig.UserData.roiIN{1})
    hfig.UserData.roiIN{1} = roi; % computes a binary ROI mask from an ROI polygon
else
    Nroi = numel(hfig.UserData.roiIN);
    hfig.UserData.roiIN{Nroi+1} = roi; % computes a binary ROI mask from an ROI polygon
end

    
    
    
    
    
    
    
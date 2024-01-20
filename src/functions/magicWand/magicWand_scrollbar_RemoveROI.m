function magicWand_scrollbar_RemoveROI(hOPD)

title(gca,'Areas to be removed, if any')


roi = drawpolygon('FaceAlpha',0.1,'Color','r');

if isempty(hOPD.UserData.roiOUT)
    hOPD.UserData.roiOUT{1} = roi; % computes a binary ROI mask from an ROI polygon
else
    Nroi = numel(hOPD.UserData.roiOUT);
    hOPD.UserData.roiOUT{Nroi+1} = roi; % computes a binary ROI mask from an ROI polygon
end
ha = gca;
ha.Children

    


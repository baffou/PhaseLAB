function magicWand_scrollbar_drawROI(hfig)

title(gca,'Limit the exact area to be cropped')

roi = drawpolygon('FaceAlpha',0,'Color',[0.2 0.2 0.2]);

hfig.UserData.roiDraw = roi; % computes a binary ROI mask from an ROI polygon

hfig.UserData.processok = 1; 
    
    
    
    
    
    
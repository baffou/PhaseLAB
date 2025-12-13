function climSym

image_handle = findobj(gca, 'Type', 'image');
im = image_handle.CData;
maxVal = max(im(:));
minVal = min(im(:));
mm = max(abs([minVal,maxVal]));
clim([-mm, mm])

end










    
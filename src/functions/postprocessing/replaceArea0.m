function [imout, mask] = replaceArea0(im0,imref,opt)
% Function that replaces an area of an image by the same area of another
% image. Typically used to remove problematic areas on a interferogram, and
% replace it with the reference counterpart.
arguments
    im0 (:,:) double
    imref (:,:) double
    opt.ax = []
    opt.mask = []
end

if isempty(opt.mask)
    if isempty(opt.ax)
        fig = figure;
        opt.ax = axes('Parent', fig);
    end
    
    imagesc(opt.ax, im0);
    colormap('gray');
    colorbar;
    title('Draw a polygon on the area you want to replace');
    set(opt.ax,'DataAspectRatio',[1 1 1])
    
    % Draw polygonal ROI on the first matrix

    roi = drawpolygon();
    mask = createMask(roi);
    close(fig)
else
    mask = opt.mask;
end




% Apply the mask to replace only the selected area
imout = im0;
imout(mask) = imref(mask);


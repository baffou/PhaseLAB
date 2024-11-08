function [maskFinal, mask1, mask2] = computeSegmentationMasks(im1, im2, opt)
% computeSegmentationMasks(DWx, DWy, "type",'gradients', ...)
% computeSegmentationMasks(T, ...)
arguments
    im1
    im2 = []
    opt.threshold = 0
    opt.smoothing
    opt.cut
    opt.invert
end

if opt.threshold == 0
    maskFinal = logical (im1*0 + 1);
else

    if ~isempty(im2)    % supposed to be two gradients
        mask0x = abs(im1) < opt.threshold;
        mask0y = abs(im2) < opt.threshold;

        mask1 = mask0x&mask0y;

    else % supposed to be the initial image.

        mask1 = abs(im1-min(im1(:))) < opt.threshold; % increase by the min of the image because supposed to be an OPD image, with negative values
    end


    if opt.smoothing == 0
        mask2 = double(mask1);
    else
        mask2 = imgaussfilt(double(mask1),opt.smoothing);
    end

    if ~opt.invert
        maskFinal = mask2 < opt.cut;
    else
        maskFinal = mask2 > opt.cut;
    end

end
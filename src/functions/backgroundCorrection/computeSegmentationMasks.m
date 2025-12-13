function [maskFinal, mask1, mask2] = computeSegmentationMasks(img, opt)
% computeSegmentationMasks(DW2, "type",'gradients', ...)
% computeSegmentationMasks(T, ...)
arguments
    img
    opt.threshold = 0
    opt.smoothing
    opt.cut
    opt.invert
    opt.type char {mustBeMember(opt.type,{'OPD','T','gradients'})} = 'gradients'
end

if opt.threshold == 0
    maskFinal = logical (img*0 + 1);
    mask1 = [];
    mask2 = [];
else


    switch opt.type
        case {'OPD','gradients'}
            mask1 = abs(img-min(img(:))) < opt.threshold; % subtract the min of the image because supposed to be an OPD image, with negative values
        otherwise % 'T'
            mask1 = abs(img) < opt.threshold;
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
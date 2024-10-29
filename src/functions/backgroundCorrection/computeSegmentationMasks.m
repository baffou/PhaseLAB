function [maskFinal, mask1, mask2] = computeSegmentationMasks(Dimgx, Dimgy,...
                                     gradThresh, smoothing, cut, invert)

mask0x = abs(Dimgx) < convert_nm(gradThresh);
mask0y = abs(Dimgy) < convert_nm(gradThresh);

mask1 = mask0x&mask0y;

if smoothing == 0
    mask2 = double(mask1);
else
    mask2 = imgaussfilt(double(mask1),smoothing);
end

if ~invert
    maskFinal = mask2 < cut;
else
    maskFinal = mask2 > cut;
end

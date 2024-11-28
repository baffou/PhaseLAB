function ImOut=polarInterpolation(Im,polar)
% Function that interpolates the image of a two-color interferogram into either the green or the red image.
arguments
    Im double % image to interpolate
    polar double
end

% Check if x is a member of valid_values
if ~ismember(polar, [0 45 90 135])
    error('Input must be one of:0, 45, 90, 135');
end

switch polar
    case 0
        Im00 = Im(1:2:end,1:2:end);
        ImOut = imresize(Im00,size(Im));
    case 45
        Im45 = Im(2:2:end,1:2:end);
        ImOut = imresize(Im45,size(Im));
    case 90
        Im90 = Im(2:2:end,2:2:end);
        ImOut = imresize(Im90,size(Im));
    case 135
        Im135 = Im(1:2:end,2:2:end);
        ImOut = imresize(Im135,size(Im));
end

% 1-pixel shift to realign the 4 images ?




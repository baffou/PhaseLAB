function ImOut=polarInterpolation(Im,polar,method)
% Function that interpolates the image of a 4-polar interferogram into one of the 4 polar images.
arguments
    Im double % image to interpolate
    polar double
    method {mustBeMember(method,{'regionfill','linear'})} = 'linear'
end

% Check if x is a member of valid_values
if ~ismember(polar, [0 45 90 135])
    error('Input must be one of:0, 45, 90, 135');
end

switch polar
    case 0
        ny = 3; nx = 3;
        mask = ones(size(Im));
        mask(2:2:end,2:2:end) = 0;
    case 45
        ny = 3; nx = 2;
        mask = ones(size(Im));
        mask(2:2:end,1:2:end) = 0;
    case 90
        ny = 2; nx = 2;
        mask = ones(size(Im));
        mask(1:2:end,1:2:end) = 0;
    case 135
        ny = 2; nx = 3;
        mask = ones(size(Im));
        mask(1:2:end,2:2:end) = 0;
end

if strcmp(method,'regionfill')
    ImOut = regionfill(Im,mask);
elseif strcmp(method,'linear')
    % 0
    ImOut = Im.*(1-mask);
    ImOut(:,nx:2:end-4+nx) = (Im(:,nx-1:2:end-5+nx) + Im(:,nx+1:2:end-3+nx))/2;
    ImOut(ny:2:end-4+ny,:) = (Im(ny-1:2:end-5+ny,:) + Im(ny+1:2:end-3+ny,:))/2;

    ImOut = ImOut(3:end-2,3:end-2);
end


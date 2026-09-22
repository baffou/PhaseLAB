function [profile, xy, width, edgeIm] = edgeExtraction(img, crosscutDirection, opt)
% extract the image of the edge of a structure, projected vertically or
% horizontally
arguments
    img
    crosscutDirection {mustBeMember(crosscutDirection,{'x','y'})}
    opt.width = 100 % [px]
    opt.GaussFilter = 1
    opt.xy = []
    opt.display logical = true
    opt.clim = [-0.01 0.01]
end


Im = imgaussfilt(img,opt.GaussFilter);

if isempty(opt.xy)
    hfig = figure;
    imagegb(Im)
    clim(opt.clim)
    xy = ginput(2);
    close(hfig)
else
    xy = opt.xy;
end

x = xy(:,1);
y = xy(:,2);

a = ( y(2)-y(1) )/( x(2) - x(1) );
b = y(1) - a*x(1);

affin = @(x) a*x + b;
iaffin = @(y) (y - b)/a;

x = round([min(x), max(x)]);
y = round([min(y), max(y)]);

Nw = opt.width;

crosscutDirection = char(crosscutDirection);
try
    switch crosscutDirection
        case 'y'
            edgeIm = zeros(Nw, x(2)-1-x(1));
            for ix = 1:(x(2)-1-x(1))
                y0 = round(affin(x(1)+ix));
                edgeIm(:,ix) = Im(y0-Nw/2+1:y0+Nw/2,x(1)+ix);
            end
        case 'x'
            edgeIm = zeros(y(2)-1-y(1),Nw);
            for iy = 1:(y(2)-1-y(1))
                y0 = y(1)+iy;
                x0 = round(iaffin(y0));
                edgeIm(iy,:) = Im(y0,x0-Nw/2+1:x0+Nw/2);
            end
    end

catch
    error('the profile is too close from a boundary of the image. Redefine the clicks xy.')
end

if opt.display
    figure
    subplot(1,2,1)
    imagegb(edgeIm.')
    subplot(1,2,2)
    if strcmpi(crosscutDirection,'y')
        plot(mean(edgeIm,2) - median(mean(edgeIm,2)))
    else
        plot(mean(edgeIm,1) - median(mean(edgeIm,1)))
    end        
        drawnow
end

width = opt.width;


switch crosscutDirection
    case 'x'
        profile = mean(edgeIm,1)';
    case 'y'
        profile = mean(edgeIm,2);
end

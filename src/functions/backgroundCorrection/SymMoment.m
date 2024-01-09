function [m, xc, yc, r0] = SymMoment(im,opt)
arguments
    im (:, :) double =[]
    opt.fold (1,1) double = 4
    opt.center double = double.empty()
    opt.radius double = double.empty()
end

if isempty(opt.center)
    hfig=figure;
    imagesc(im)
    colorbar
    set(gca,'YDir','normal')
    colorMap='parula(1024)';
    colormap(gca,colorMap)
    set(gca,'dataAspectRatio',[1 1 1])
    uicontrol('Style','pushbutton','String','set ROI','Callback',{@(src,event)setROI(hfig,opt.fold)});
    zoom on

    while isempty(hfig.UserData)
        pause(0.5)
    end
    m = hfig.UserData.m;
    xc=hfig.UserData.xyc(1);
    yc=hfig.UserData.xyc(2);
    r0=hfig.UserData.r0;
else
    m = setROI(im,opt.fold,"rc",opt.center, "r0",opt.radius);
    xc=opt.center(1);
    yc=opt.center(2);
    r0=opt.radius;
end



end

function m=setROI(hfig,fold,opt)
arguments
    hfig
    fold
    opt.r0 = []
    opt.rc = []
end

if ishandle(hfig) % setROI(hfig,fold)
    figure(hfig)
    ha=gca;
    im=ha.Children.CData;
else % setROI(im,fold)
    im=hfig;
end
[Ny, Nx]=size(im);

if isempty(opt.r0) || isempty(opt.rc)
    zoom off
    title('click on the center')
    [xc, yc] = ginput(1);
    title('click to define the radius of integration')
    [x0, y0] = ginput(1);
    r0 = sqrt((x0-xc)^2+(y0-yc)^2);
else
    xc = opt.rc(1);
    yc = opt.rc(2);
    r0 = opt.r0;
end


[xx, yy] = meshgrid(1:Nx,1:Ny);
xx = xx-xc;
yy = yy-yc;
rr = sqrt(xx.^2+yy.^2);
phi = angle(xx+1i*yy);
%u1 = rr.*(r0-rr).*cos(fold*phi);
%u2 = rr.*(r0-rr).*sin(fold*phi);
u1 = cos(fold*phi);
u2 = sin(fold*phi);
u1 = u1.*(rr<=r0);
u2 = u2.*(rr<=r0);
U = u1 + 1i*u2;
%norm=pi*r0^6/60;
norm = abs(sum(conj(U(:)).*U(:)));

u1n = u1/sqrt(norm);
u2n = u2/sqrt(norm);
m = sum(im(:).*U(:))/sum(im(:).*im(:));
if ishandle(hfig)
    hfig.UserData.u1 = u1n;
    hfig.UserData.u2 = u2n;
    hfig.UserData.m = m;
    hfig.UserData.xyc = [xc, yc];
    hfig.UserData.r0 = r0;
end
end

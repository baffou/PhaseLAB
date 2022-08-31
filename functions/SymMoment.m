function m = SymMoment(im,opt)
arguments
    im (:, :) double =[]
    opt.fold (1,1) double = 4
    opt.center = []
    opt.radius = []
end

hfig=figure;
imagesc(im)
colorbar
set(gca,'YDir','normal')
colorMap='parula(1024)';
colormap(gca,colorMap)
set(gca,'dataAspectRatio',[1 1 1])
uicontrol('Style','pushbutton','String','set ROI','Callback',{@(src,event)setROI(hfig,opt.fold)});
zoom on

if isempty(opt.center)
    while isempty(hfig.UserData)
        pause(0.5)
    end
    m = hfig.UserData;
else
    m = SymMoment(im,4,'center',opt.center, 'radius',opt.radius);
end



end

function setROI(hfig,fold)
    figure(hfig)
    ha=gca;
    im=ha.Children.CData;
    [Ny, Nx]=size(im);


    zoom off
    title('click on the center')
    [xc, yc] = ginput(1);
    title('click to define the radius of integration')
    [x0, y0] = ginput(1);

    r0 = sqrt((x0-xc)^2+(y0-yc)^2);

    [xx, yy] = meshgrid(1:Nx,1:Ny);
    xx = xx-xc;
    yy = yy-yc;
    rr = sqrt(xx.^2+yy.^2);
    phi = angle(xx+1i*yy);
    u1 = rr.*(r0-rr).*cos(fold*phi);
    u2 = rr.*(r0-rr).*sin(fold*phi);
    u1 = u1.*(rr<=r0);
    u2 = u2.*(rr<=r0);
    U = u1 + 1i*u2;
    norm=pi*r0^6/60;
    hfig.UserData.u1=u1/sqrt(norm);
    hfig.UserData.u2=u2/sqrt(norm);
    hfig.UserData.m = sum(im(:).*U(:));
end

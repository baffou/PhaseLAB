function [profile,coords]=radialAverage(obj,opt)
% obj can be Interfero, ImageMethods or a simple image.
arguments
    obj
    opt.figure = []
    opt.coords =[]
end
% plots the radial average from a clicked point, usually a
% nanoparticle location.
% hfig is optional. If specified, must be the hfig of the main image panel: IM.figure.
QLSIclass = isa(obj,'ImageMethods') || isa(obj,'Interfero');

if QLSIclass
    pxSize=obj.pxSize;
else
    pxSize=1e-6;
end

if isempty(opt.figure)
    if QLSIclass
        hfig=obj.figure('px');
    else
        hfig=figure;
        imagegb(obj)
    end
else
    hfig=opt.figure;
    figure(hfig)
end

if QLSIclass
    linkaxes(hfig.UserData{7},'off');
    linkaxes(hfig.UserData{7},'x');
end

if isempty(opt.coords)
    [cx,cy]=ginput(2);
else
    cx=opt.coords(:,1);
    cy=opt.coords(:,2);
end
coords=[cx,cy];
if nargin==2
    if strcmp(hfig.UserData{2},'µm')
        factorAxis=pxSize*1e6;
    elseif strcmp(hfig.UserData{2},'px')
        factorAxis=1;
    end
else
    factorAxis=1;
end
D=sqrt((cx(1)-cx(2))^2+(cy(1)-cy(2))^2);

if isa(obj,'ImageMethods')
    profile.T  =radialAverage0(obj.T,   [cx(1)/factorAxis, cy(1)/factorAxis], round(D/factorAxis));
    profile.OPD=radialAverage0(obj.OPD, [cx(1)/factorAxis, cy(1)/factorAxis], round(D/factorAxis));
elseif isa(obj,'Interfero')
    profile.T  =radialAverage0(obj.Itf,   [cx(1)/factorAxis, cy(1)/factorAxis], round(D/factorAxis));
else
    profile.T  =radialAverage0(obj,   [cx(1)/factorAxis, cy(1)/factorAxis], round(D/factorAxis));
end
profile.coords=[cx,cy];
Np=length(profile.T);
profile.Xcoords=pxSize*1e6*(1:Np);

subplot(1,2,1)
plot((-Np+1:Np-1)*factorAxis,[flip(profile.T);profile.T(2:end)],'LineWidth',2)
if QLSIclass
    xlabel(hfig.UserData{2})
end
ylabel('normalized intensity')
hold on
ax=gca;
plot([0 0],ax.YLim,'k--','LineWidth',2);%vertical line
set(ax,'FontSize',14)
hold off
if isa(obj,'ImageMethods')
subplot(1,2,2)
plot((-Np+1:Np-1)*factorAxis,[flip(profile.OPD);profile.OPD(2:end)]*1e9,'LineWidth',2)
hold on
ax=gca;
plot([0 0],ax.YLim,'k--','LineWidth',2);%vertical line
set(ax,'FontSize',14)
hold off
if QLSIclass
    xlabel(hfig.UserData{2})
end
ylabel('Optical path difference [nm]')
end
end
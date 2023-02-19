function figure_callback_Itf(hfig,IM,unit,dx0,fft,k)
%hfig: figure handle
%IM: ImageEM or ImageQLSI object
%unit: 'px' or 'µm'
%dx: 'st' or '3D'
%mix: 'mix' or 'duo'
%[k: image number]
%[UIk: gui handle]
hand = hfig.UserData{8};

AxesColor = hfig.UserData{6}.AxesColor;
ButtonOnColor = hfig.UserData{6}.ButtonOnColor;
ButtonOffColor = hfig.UserData{6}.ButtonOffColor;

set(hand.obj,'String' ,['M = ' num2str(IM.Microscope.Mobj) 'x'])
set(hand.pxSize,'String',['px size: ' num2str(IM.pxSize*1e9) ' nm'])
set(hand.Npx,'String',[num2str(IM.Nx) 'x' num2str(IM.Ny) ' px'])


if nargin==6 %ie in the case k and UIk are specified
    set(hand.UIk,'string',num2str(k));
end

if strcmp(unit,'px')
    factorX = 1;
    factorY = 1;
    unit = 'px';  % present the µm mode with dx, mess up a bit the image, I don't know why
elseif strcmp(unit,'um') || strcmp(unit,'µm')
    factorX = IM.pxSize*1e6;
    factorY = IM.pxSize*1e6;
    unit = 'µm';
else
    error('the unit parameter must be ''px'' or ''um''')
end

set(hand.standard,'BackgroundColor',ButtonOnColor)
set(hand.threeD,'BackgroundColor',ButtonOffColor)

if strcmp(unit,'px')
    set(hand.px,'BackgroundColor',ButtonOnColor)
    set(hand.um,'BackgroundColor',ButtonOffColor)
end

if strcmp(unit,'µm')
    set(hand.px,'BackgroundColor',ButtonOffColor)
    set(hand.um,'BackgroundColor',ButtonOnColor)
end



%% 1st image

ha(1) = subplot(1,2,1);
ha(1).XColor = 'w'; 
%ha(1).Position = [0.2300    0.1100    0.3347    0.8150];
%ha(1).Position = [0.5703    0.1100    0.3347    0.8150];
xx = [0 IM.Nx*factorX];
yy = [0 IM.Ny*factorY];


imagesc(xx,yy,IM.Itf);
axis equal
colormap(gca,gray(1024))
cb.T = colorbar;
cb.T.Color = AxesColor;
    


cb.T.Label.String = 'counts';
cb.T.Label.FontSize = 14;
axis([0 IM.Nx*factorX 0 IM.Ny*factorY])
title(IM.fileName,'FontSize',12,'Interpreter','none')



xlabel(unit,'FontSize',14);
set(gca,'FontSize',14)
set(ha(1),'XColor',AxesColor);
set(ha(1),'YColor',AxesColor);
ha(1).YDir = 'normal';

%% 2nd image
ha(2) = subplot(1,2,2);

ha(1).Position(3) = ha(2).Position(3);
ha(1).Position(1) = ha(1).Position(1)*1.2;

if strcmp(fft,'ref') && ~isempty(IM.Ref)
    reference = IM.Ref.Itf;
    set(hand.ref,'BackgroundColor',ButtonOnColor)
    set(hand.fft,'BackgroundColor',ButtonOffColor)
else
    reference = log(abs(fftshift(ifft2(IM.Itf))));
    set(hand.ref,'BackgroundColor',ButtonOffColor)
    set(hand.fft,'BackgroundColor',ButtonOnColor)
end
imagesc(xx,yy,reference);

axis equal
colormap(gca,gray(1024));
cb.Ph = colorbar;
ax = gca;
ax.YDir = 'normal';
cb.Ph.Color = AxesColor;

% to avoid bright pixels distorting the colorscale
%vec = sort(IM.Ph(:));
%Nv = numel(vec);
%caxis([vec(500) vec(Nv-500) ]);

cb.Ph.Label.String = 'counts';
cb.Ph.Label.FontSize = 14;
axis([0 IM.Nx*factorX 0 IM.Ny*factorY])
title(IM.Ref.fileName,'FontSize',14,'Interpreter','none')
xlabel(unit,'FontSize',14);
set(gca,'FontSize',14);


linkaxes(ha, 'xy');      
set(ha(2),'XColor',AxesColor);
set(ha(2),'YColor',AxesColor);

%%



ha(1).Position(3)=ha(2).Position(3);


%%hfig.UserData
%1: colorbar
%2: primary unit
%3: other alternative unit
%4: 3D rendering 0, 1, or 2
%5: current image
%6: colors
%7: subplots axes

hfig.UserData{1}=cb;

hfig.UserData{2}=unit;
hfig.UserData{3}=dx0;
hfig.UserData{4}=fft;

hfig.UserData{5}=IM;
hfig.UserData{7}=ha;
hfig.UserData{8}=hand;


hfig.UserData{8}.UIk;




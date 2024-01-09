function reloadFigure(hfig,IM,unit,dx0,mix,k)

%% zoom reset
if strcmp(unit,'px')  % presents the µm mode with dx
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

set(gca,'XLim',[0 size(IM.OPD,2)*factorX])
set(gca,'YLim',[0 size(IM.OPD,1)*factorY])

% display image
figure_callback(hfig,IM,unit,dx0,mix,k)
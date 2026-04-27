function ai=imageph(A,Amin,Amax,opt)
arguments
    A
    Amin = 0
    Amax = 0
    opt.reverseColor = false
    opt.pxSize = []
    opt.ax = gca
end

[Ny, Nx] = size(A);


if ~isempty(opt.pxSize)
    if nargout
        ai=imagesc(opt.ax,opt.pxSize*(1:Nx),opt.pxSize*(1:Ny),A);
    else
           imagesc(opt.ax,opt.pxSize*(1:Nx),opt.pxSize*(1:Ny),A)
    end
else
    if nargout
        ai=imagesc(opt.ax,A);
    else
        imagesc(opt.ax,A)
    end
end

set(opt.ax,'dataAspectRatio',[1 1 1])
cb=colorbar(opt.ax);
set(opt.ax,'YDir','normal')

if opt.reverseColor
    colormap(gca,flipud(phase1024));
else
    colormap(gca,sepia);
end

if Amax~=0 && Amin==0
    clim([min(A(:)) Amax])
elseif Amax~=0 && Amin~=0
    clim([Amin Amax])
end


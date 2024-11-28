function ai=imagefl(A,Amin,Amax,opt)
arguments
    A
    Amin = 0
    Amax = 0
    opt.pxSize = []
end

[Ny, Nx] = size(A);


if ~isempty(opt.pxSize)
    if nargout
        ai=imagesc(opt.pxSize*(1:Nx),opt.pxSize*(1:Ny),A);
    else
           imagesc(opt.pxSize*(1:Nx),opt.pxSize*(1:Ny),A)
    end
else
    if nargout
        ai=imagesc(A);
    else
        imagesc(A)
    end
end

set(gca,'dataAspectRatio',[1 1 1])
colorbar;
set(gca,'YDir','normal')

colormap(invertedGreen())

if Amax~=0 && Amin==0
    clim([min(A(:)) Amax])
elseif Amax~=0 && Amin~=0
    clim([Amin Amax])
end


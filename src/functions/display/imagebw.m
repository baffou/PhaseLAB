function him = imagebw(W,opt)
arguments
    W
    opt.ax = gca
    opt.reverseColor = false
end

if nargout
    him = imagesc(opt.ax,real(W));
else
    imagesc(opt.ax,real(W))
end
set(opt.ax,'DataAspectRatio',[1 1 1])

if opt.reverseColor
    colormap(opt.ax,flipud(gray))
else
    colormap(opt.ax,'Gray')
end

set(opt.ax,'YDir','normal')
colorbar(opt.ax)



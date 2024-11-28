function him = imagebw(W,opt)
arguments
    W
    opt.ax = gca
end

if nargout
    him = imagesc(opt.ax,real(W));
else
    imagesc(opt.ax,real(W))
end
set(opt.ax,'DataAspectRatio',[1 1 1])
colormap(opt.ax,'Gray')
set(opt.ax,'YDir','normal')
colorbar(opt.ax)
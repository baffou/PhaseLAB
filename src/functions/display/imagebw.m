function imagebw(W)

imagesc(real(W))
set(gca,'DataAspectRatio',[1 1 1])
colormap(gca,'Gray')
set(gca,'YDir','normal')
colorbar
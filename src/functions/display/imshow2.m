function imshow2(matrice,colorscale)
arguments
    matrice (:,:) double
    colorscale = []
end
% generate a figure with an image that covers the whole figure.

if isempty(colorscale)
    colorscale = 'parula';
end

imagesc(matrice)
fig = gcf;

axis image
ha = gca;
set(ha,'DataAspectRatio',[1 1 1])
ha.Visible = false;
ha.Position = [0 0 1 1];

[Ny, Nx] = size(matrice);

fig.Position(1)=0;
fig.Position(2)=0;
fig.Position(3)=Nx*256/400;
fig.Position(4)=Ny*256/400;
fig.MenuBar = "none";
fig.ToolBar = "none";
colormap(colorscale)

saveas(fig,"fig.bmp")




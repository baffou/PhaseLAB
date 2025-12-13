function h=imagehsv(A,opt)
arguments
    A
    opt.ax = gca
end

if nargout % do not display ans if no output is asked by the user.
    h=imagesc(opt.ax,A);
else
    imagesc(opt.ax,A)
end
colorbar(opt.ax)
set(opt.ax,'YDir','normal')
colormap(opt.ax,"hsv")

set(opt.ax,'dataAspectRatio',[1 1 1])

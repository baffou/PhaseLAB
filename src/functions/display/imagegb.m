function h = imagegb(A,colorMap,Amin,Amax,opt)
arguments
    A
    colorMap = parula(1024)
    Amin = []
    Amax = []
    opt.ax = gca
end

if nargout % do not display ans if no output is asked by the user.
    h=imagesc(opt.ax, A);
else
    imagesc(opt.ax, A)
end
colorbar(opt.ax)
set(opt.ax,'YDir','normal')

colormap(opt.ax,colorMap)


if nargin==3
    clim([min(min(A)) Amin])
end

if nargin==4
    clim([Amin Amax])
end

set(opt.ax,'dataAspectRatio',[1 1 1])

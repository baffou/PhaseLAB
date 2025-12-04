function h=imagejet(A,Amin,Amax,opt)
arguments
    A
    Amin = []
    Amax = []
    opt.ax = gca
end


if nargout % do not display ans if no output is asked by the user.
    h=imagesc(opt.ax,A);
else
    imagesc(opt.ax,A)
end
colorbar(opt.ax)
set(gca,'YDir','normal')

colormap(opt.ax,jet(1024))


if nargin==2
    clim([min(min(A)) Amin])
end

if nargin==3
    clim([Amin Amax])
end

set(opt.ax,'dataAspectRatio',[1 1 1])

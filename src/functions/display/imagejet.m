function h=imagejet(A,Amin,Amax)


if nargout % do not display ans if no output is asked by the user.
    h=imagesc(A);
else
    imagesc(A)
end
colorbar
set(gca,'YDir','normal')

colormap(gca,jet(1024))


if nargin==2
    clim([min(min(A)) Amin])
end

if nargin==3
    clim([Amin Amax])
end

set(gca,'dataAspectRatio',[1 1 1])

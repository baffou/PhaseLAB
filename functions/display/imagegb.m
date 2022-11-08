function h=imagegb(A,colorMap,Amin,Amax)


if nargout % do not display ans if no output is asked by the user.
    h=imagesc(A);
else
    imagesc(A)
end
colorbar
set(gca,'YDir','normal')
if nargin<2
    colorMap='parula(1024)';
end
colormap(gca,colorMap)


if nargin==3
    caxis([min(min(A)) Amin])
end

if nargin==4
    caxis([Amin Amax])
end

set(gca,'dataAspectRatio',[1 1 1])

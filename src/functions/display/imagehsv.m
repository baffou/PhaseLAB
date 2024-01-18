function h=imagehsv(A)


if nargout % do not display ans if no output is asked by the user.
    h=imagesc(A);
else
    imagesc(A)
end
colorbar
set(gca,'YDir','normal')
colormap(gca,"hsv")

set(gca,'dataAspectRatio',[1 1 1])

function exportImage(A, fileName, opt)
% function that exports and eps image, without axes, without anything, so
% that it can be directly used in an eps file, with a link. This way, when
% Maltab modifies again the eps image, it is automatically updated in the
% eps file, and in the LaTeX article file.
arguments
    A
    fileName
    opt.colormap = parula
    opt.clim = []
end
%[path, fileName0, ext] = fileparts(fileName); % file name without the extension
h = figure('Position',[560   428   size(A,2)   size(A,1)]);

imagesc(A);
colormap(opt.colormap)
axis image
set(gca,'YDir','normal')
if isempty(opt.clim)
    opt.clim = [min(A(:)),max(A(:))];
end
clim(opt.clim)
ha = gca;
ha.Visible = 'off';
ha.InnerPosition = [0 0 1 1];
h.MenuBar = "none";
drawnow
exportgraphics(h,fileName,'BackgroundColor','none')
close(h)
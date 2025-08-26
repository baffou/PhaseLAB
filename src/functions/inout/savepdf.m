function savepdf(hfig,folder)
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','points','PaperSize',[pos(3), pos(4)])
drawnow
print(hfig,'-dpdf',folder)

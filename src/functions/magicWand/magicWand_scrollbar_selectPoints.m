function magicWand_scrollbar_selectPoints(hfig)
figure(hfig)
button = 0;
ni = 0;
xg = zeros(128,1);
yg = zeros(128,1);
p = zeros(128,1);

% click on the points for the magc wand process
button = 1;
while(button==1) % as long as the user clicks and does not press any other key
    ni = ni+1;
    [x1,y1,button]  =  ginput(1);
    xg(ni) = x1;
    yg(ni) = y1;
    hold on;
    p(ni) = plot(x1,y1, 'r+', 'MarkerSize', 10, 'LineWidth', 1,'Color',[0.2 0.2 0.7]);
end
xg = xg(1:ni-1);
yg = yg(1:ni-1);
p = p(1:ni-1);

for ii = 1:ni-1
    delete(p(ii))
end
hfig.UserData.ylist = round(yg);
hfig.UserData.xlist = round(xg);
hfig.UserData.processok = 1;
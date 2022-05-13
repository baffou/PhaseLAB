hh = figure;
logo = imread('/Users/gbaffou/Documents/_DATA_SIMULATIONS/200523-PhaseLAB/design/logo.png');
him = imagesc(logo);
hh.MenuBar = 'none';
hh.NumberTitle = 'off';
hh.Color = [1 1 1];
scrSz = get(0,'ScreenSize');
logoSz = size(logo);
hh.Position = [scrSz(3)/2-logoSz(2)/2 scrSz(4)/2-logoSz(1)/2  logoSz(2) logoSz(1)];
axis equal
axis off
pause(1)
close(hh)
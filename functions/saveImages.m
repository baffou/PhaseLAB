function saveImages(hfig)
hand=hfig.UserData{8};
IM=hfig.UserData{5};
folder=get(hand.folder,'string');
k=str2double(get(hand.UIk,'string'));
fileName=get(hand.file,'string');

mkdir(folder)
currFolder=pwd;
cd(folder)



figure
fullscreen
subplot(1,2,1)
axis equal
imagegb(IM.T)
colormap(gca,gray(1024))

subplot(1,2,2)
axis equal
imageph(IM.OPD)

pause(1)


warning('function to be finished')

cd(currFolder)



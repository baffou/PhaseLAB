function saveData(hfig,hc)
hand=hfig.UserData{8};
data=hfig.UserData{10};
folder=get(hand.folder,'string');
k=str2double(get(hand.UIk,'string'));
fileName=get(hand.file,'string');

mkdir(folder)
currFolder=pwd;
cd(folder)
dlmwrite([fileName '_im' textk(k) '.txt'],data);
fprintf([folder '/' fileName '_im' textk(k) '.txt\n'])
if numel(hfig.UserData)==11 % position list of the clicks
    XY = hfig.UserData{11};
    dlmwrite([fileName '_XY_im' textk(k) '.txt'],XY,' ');
    fprintf([folder '/' fileName '_XY_im' textk(k) '.txt\n'])
end

if nargin==2
    saveas(hc,[fileName '_' textk(k) '.fig'],'fig')
    saveas(hc,[fileName '_' textk(k) '.jpg'],'jpg')
    fprintf([folder '/' fileName '_' textk(k) '.fig\n'])
    fprintf([folder '/' fileName '_' textk(k) '.jpg\n'])
end


cd(currFolder)



%% Example that imports and process CGM measurements on bacteria.
clear

%% BUILDING OF THE MEDIUM -- ME=Medium(n,nS);
ME = Medium('water','glass');

%% BUILDING OF THE OBJECTIVE -- Objective(Mobj,NA,brand);
OB = Objective(60,1.3,'Olympus');

%% BUILDING OF THE MICROSCOPE -- Microscope(OBJ,tl_f,Sid4model,software)
MI = Microscope(OB,180,'sC8-830','PhaseLIVE');

%% BUILDING OF THE ILLUMINATION -- IL=Illumination(lambda, Medium);
lambda = 625e-9;
IL = Illumination(lambda,ME);

%% IMPORT THE IMAGES -- Images=importItfRef(folder,MI,nickname);
folder = 'GeobLongFilaments';

%[Im,Rf] = importItfRef(folder,MI,'remote',1,'selection',1/5);
[Im,Rf] = importItfRef(folder,MI,'remote',1,'nickname','ITF');

%% INTERFEROGRAM PROCESSING -- Im.QLSIprocess(IL);
IMlow = Im.QLSIprocess(IL,'definition','low');  % low definition
%IMhigh=Im.QLSIprocess(IL);  % high definition

%% display of the CGM images using the figure window

IMlow.figure

% In particular, you can now play with the refocusing tool in the
% processing tab of the figure window

%% flattening of the background
img1 = IMlow(1).OPD;
IMlow.flatten('Legendre','nmax',[4 4],'threshold',0,'smoothing',0,'cut',0.5,'invert',false,'type','gradients','display',false);  
img2 = IMlow(1).OPD;

figure
subplot(1,2,1)
imageph(img1)
title("before bkg flattening","FontSize",20)
subplot(1,2,2)
imageph(img2)
title("after bkg flattening","FontSize",20)
fullwidth

%% numeric refocusing
IMr = IMlow.propagation(-3e-5);

figure
subplot(1,2,1)
imageph(IMlow(1).OPD)
title("before numeric refocusing","FontSize",20)
subplot(1,2,2)
imageph(IMr(1).OPD)
title("after numeric refocusing","FontSize",20)
fullwidth


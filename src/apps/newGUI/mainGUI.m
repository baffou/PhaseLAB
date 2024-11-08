clear
close all

cd('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git')
addpath(genpath(pwd))
load("newGUI/IM.mat")

app=phaseLABgui;app.IM=IM;


%%

IM2=IM.crop(Size=[100,50]);
app.IM=IM2;



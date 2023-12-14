%% Documentation of PhaseLAB
% DESCRIPTIVE TEXT

addpath(genpath('/Users/perseus/Documents/_DATA_SIMULATIONS/190729-PhaseLAB/PhaseLAB_Git'))


% I - LUNARIS IS MEANT TO DEAL WITH QLSI IMAGES, BOTH FOR  EXPERIMENTAL IMAGE POSTPROCESSING AND IMAGE NUMERICAL SIMULATIONS.


%We shall avoid using functions with an arbitrary long series of inputs. Instead, we use the an object-oriented programming (OOP) approach.

%% 
%1- start building a microscope
% A microscope consists of 3 components (obj, TL, camera)
OB = Objective(100,1.3);

CGcam = CGcamera('Silios_mono');

MI = Microscope(OB, 180, CGcam);

%You may say the illumination is missing. Yes, we chose to consider it separately:
lambda = 600e-9;
IL = Illumination(lambda);

%% Course 2: Import your images

%I- how to import specific object and reference interferogram files
Itf = Interfero('Itf.tif',MI);
Ref = Interfero('Ref.tif',MI);

Itf.Reference(Ref);

% The interest of specifying MI while creating the Interfero object is that we know which camera was using when acquiring the interferogram : Itf.CGcam.

% other option, in 2 steps:

imItf = imread('Itf.tif');
Itf = Interferogram(imItf,MI);


%Other option. It the images were acquired using PhaseLAB, then one can use the importItfRef function that automatically import the object and reference interfero, and associate them automatically.

[Itf, Ref] = importItfRef(folderName, MI);




Course 3: process your interferograms

Lets summarize what we have seen so far:



OB = Objective(100,1.3,'Olympus');
CGcam = CGcamera('Silios_mono');
MI = Microscope(OB, 180, CGcam);

[Itf, Ref] = importItfRef(folderName, MI);



The 4th line to write is

IM = Itf.QLSIprocess(IL);



Display the results

The figure function

The figure method

The dynamicFigure function












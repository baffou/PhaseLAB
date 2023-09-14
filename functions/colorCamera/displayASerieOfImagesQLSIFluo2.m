function [aT0, aOPD0, aFLUO0, aMIX0] = displayASerieOfImagesQLSIFluo2(QLSIImages,QLSIFluo,opt)
% G. Baffou version 14 Aug 2023
% Display a stack of image controllable with key
%
% Press the  left or right arrow keyboard key to go trough the serie of images given as input.
% Special customization options can be given as arguments
%
% ARGUMENTS :
%           serieOfImage - the serie of image to be displayed, given as a 3D matrice.
%                           2 first dimension a plotted, third is used as index
% OPTIONS :
%           'Colormap'  - The colormap
%           'cAxis'     - [min max] Colorbar limits (fixed for the whole serie)
%           'Title'     - {'Title1', ..., 'TitleN'} Title corresponding to each image
%           'Step'      - i Step size of the index, to skip images
%           'YZoom'     - [Ymin Ymax] Change the Y limits of the plot
%           'XZoom'     - [Xmin Xmax] Change the X limits of the plot
%
% EXEMPLE :
%           myImages = zeros(420,420,20); %A stack of 20 images, 420x420 pixels
%           myTitles = cell(20,1); %A cell of title
%           for k=1:20
%               myImages(:,:,k) = randi(10,[420 420]); %Fill the stack of image
%               myTitles{k} = sprintf('My super title %04i',k); %Fill the cell of title
%           end
%
%           displayASerieOfImages(myImages, ...
%                               'Colormap','parula', ...
%                               'Title',myTitles, ...
%                               'cAxis',[5 8], ...
%                               'XZoom', [100 200], ...
%                               'YZoom', [400 420], ...
%                               'Step', 2);
%
%

arguments
    QLSIImages ImageQLSI
    QLSIFluo   ImageQLSI
end

arguments
    opt.Colormap = phase1024
    opt.cAxis
    opt.Title string = string.empty()
    opt.Step
    opt.YZoom
    opt.XZoom
    opt.PDCM
    opt.ScaleUm
    opt.fluoBlur
end

Nim = length(QLSIImages);

if ~isempty(opt.Title)
    seriesOfTitle = string(opt.Title);
else
    for k = 1:Nim
        try
            seriesOfTitle(k) = string(QLSIImages(k).ItfFileName);
        catch
            seriesOfTitle(k) = "none";
        end
    end
end

if isfield(opt,'fluoBlur')
    blurFunc = @(im) imgaussfilt(im, opt.fluoBlur);
else
    blurFunc = @(im) im;    % identity function
end

stepLength = 1;
jetAlphaCoeff = 1;

figHandle=figure();
TL = tiledlayout('flow');
%
% scaleX = 1:QLSIImages.Nx;
% scaleY = 1:QLSIImages.Ny;

aT = nexttile(TL);
imagesc(aT,QLSIImages(1).T);
aT.NextPlot = 'replacechildren';
colormap(aT,gray);
title(aT,'Intensity');
colorbar

aOPD = nexttile(TL);
imagesc(aOPD,QLSIImages(1).OPD);
aOPD.NextPlot = 'replacechildren';
colormap(aOPD,opt.Colormap);
title(aOPD,'OPD');
colorbar

aFLUO=nexttile;
imagesc(aFLUO,blurFunc(QLSIFluo(1).T));
colormap(aFLUO,invertedGreen("limV",0.55));
aFLUO.DataAspectRatio = [1,1,1];
title(aFLUO,'FLUO')
aFLUO.NextPlot = 'replacechildren';
colorbar

% try
%     clim([0 max(blurFunc(QLSIFluo(1).T(:)))])
% catch % if all the values of QLSIFluo are negative, don't start from O
%     clim([min(blurFunc(QLSIFluo(1).T(:))) max(blurFunc(QLSIFluo(1).T(:)))])
% end

scaledOPD=mat2gray(QLSIImages(1).OPD);
scaledFLUO0=mat2gray(blurFunc(QLSIFluo(1).T));

scaledFLUO = scaledFLUO0.*(scaledFLUO0>(max(scaledFLUO0(:))*0.5));

aMIX=nexttile();
imagesc(aMIX,scaledOPD)
aMIX.NextPlot = 'add';
imagesc(aMIX,ind2rgb(gray2ind(scaledFLUO,256),jet(256)),'AlphaData',jetAlphaCoeff*scaledFLUO)
colormap(aMIX,flipud(gray))
aMIX.DataAspectRatio = [1 1 1];
aMIX.NextPlot = 'replacechildren';

if isfield(opt,'cAxis')
    clim(aOPD,opt.cAxis)
    clim(aT,opt.cAxis)
end

if isfield(opt,'Step')
    if abs(opt.Step) >= length(QLSIImages)
        warning('The step size should be smaller than the serie value !')
    else
        stepLength = opt.Step;
    end
end

if isfield(opt,'XZoom')
    aOPD.XLim = opt.XZoom;
    aT.XLim = opt.XZoom;
end
if isfield(opt,'YZoom')
    aOPD.YLim = opt.YZoom;
    aT.YLim = opt.YZoom;
end

if isfield(opt,'PDCM')
    if size(opt.PDCM) ~= [size(QLSIImages(1).OPD,1),size(QLSIImages(1).OPD,2),length(QLSIImages)]
        warning('The PDCM must be a stack with the same size as the serie of images')
    else
        PDCM_images = opt.PDCM;
        aPDCM = nexttile(TL);
        imagesc(aPDCM,PDCM_images(:,:,k));
        aPDCM.NextPlot = 'replacechildren';
        title(aPDCM,'PDCM');
        colormap(aPDCM,colorMap_ExtendedKindlmann);
        aPDCM.DataAspectRatio = [1 1 1];
    end
end
if isfield(opt,'ScaleUm')
    scaleX = scaleX * QLSIImages(1).pxSize;
    scaleY = scaleY * QLSIImages(1).pxSize;
end

aOPD.DataAspectRatio = [1 1 1];
aT.DataAspectRatio = [1 1 1];

figHandle.UserData = 1;
figHandle.KeyPressFcn = @(~,event)updateImage(event,figHandle,aT,TL,aOPD,aFLUO,aMIX,QLSIImages,QLSIFluo,seriesOfTitle,stepLength,jetAlphaCoeff,blurFunc);
linkAxes

if nargout
    aT0=aT;
    aOPD0=aOPD;
    aFLUO0=aFLUO;
    aMIX0=aMIX;
end



end

function updateImage(event,figHandle,aT,TL,aOPD,a_FLUO,a_MIX,QLSIImages,QLSIFluo,serieOfTitle,stepLength,jetAlphaCoeff,blurFunc)
currentK = figHandle.UserData;
switch event.Key
    case 'leftarrow'
        k = currentK - stepLength;
    case 'rightarrow'
        k = currentK + stepLength;
    otherwise
        return
end

if k > length(QLSIImages)
    k = length(QLSIImages);
elseif k < 1
    k = 1;
end
figHandle.UserData = k;

imagesc(aT,QLSIImages(figHandle.UserData).T);
imagesc(aOPD,QLSIImages(figHandle.UserData).OPD);
imagesc(a_FLUO,blurFunc(QLSIFluo(figHandle.UserData).T));

scaledOPD=mat2gray(QLSIImages(figHandle.UserData).OPD);
scaledFLUO=mat2gray(QLSIFluo(figHandle.UserData).T);

imagesc(a_MIX,scaledOPD)
a_MIX.NextPlot = 'add';
imagesc(a_MIX,ind2rgb(gray2ind(scaledFLUO,256),jet(256)),'AlphaData',jetAlphaCoeff*scaledFLUO)
a_MIX.NextPlot = 'replacechildren';

TL.Parent.Name = "Image "+num2str(k)+" "+serieOfTitle(k);



end






function displayASerieOfImagesQLSIFluo2(QLSIImages,QLSIFluo,opt)
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
        QLSIFluo ImageQLSI
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
    serieOfTitle = opt.Title;
else
    serieOfTitle = cell(Nim,1);
    for k = 1:Nim
        serieOfTitle{k} = QLSIImages(k).OPDfileName;
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

a_FLUO=nexttile;
imagesc(a_FLUO,blurFunc(QLSIFluo(1).T));
colormap(a_FLUO,jet);
a_FLUO.DataAspectRatio = [1,1,1];
title(a_FLUO,'FLUO')
a_FLUO.NextPlot = 'replacechildren';
colorbar

scaledOPD=mat2gray(QLSIImages(1).OPD);
scaledFLUO=mat2gray(blurFunc(QLSIFluo(1).T));

a_MIX=nexttile();
imagesc(a_MIX,scaledOPD)
a_MIX.NextPlot = 'add';
imagesc(a_MIX,ind2rgb(gray2ind(scaledFLUO,256),jet(256)),'AlphaData',jetAlphaCoeff*scaledFLUO)
colormap(a_MIX,opt.Colormap)
a_MIX.DataAspectRatio = [1 1 1];
a_MIX.NextPlot = 'replacechildren';

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
TL.Title.String = serieOfTitle(k);

figHandle.UserData = 1;
figHandle.KeyPressFcn = @(~,event)updateImage(event,figHandle,aT,TL,aOPD,a_FLUO,a_MIX,QLSIImages,QLSIFluo,serieOfTitle,stepLength,jetAlphaCoeff,blurFunc);
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

    TL.Title.String = serieOfTitle(figHandle.UserData);
end
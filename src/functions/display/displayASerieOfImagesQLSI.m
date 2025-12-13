function displayASerieOfImagesQLSI(QLSIImages,additionalArgs,value)
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
    end

    arguments (Repeating)
        additionalArgs {mustBeMember(additionalArgs,{'Colormap','cAxis','Title','Step','YZoom','XZoom','PDCM','ScaleUm'})}
        value
    end

for k = 1:length(QLSIImages)
    serieOfTitle{k} = QLSIImages(k).OPDfileName;
end
stepLength = 1;
% PDCM_images = zeros(size(QLSIImages(1).OPD,1),size(QLSIImages(1).OPD,2),length(QLSI));
PDCM_images = [];
aPDCM = [];

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
colormap(aOPD,phase1024);
title(aOPD,'OPD');
colorbar

if ~isempty(additionalArgs)
    for k=1:length(additionalArgs)
        switch additionalArgs{k}
            case 'Colormap'
                colormap(aOPD,value{k});
            case 'cAxis'
                caxis(aOPD,value{k})
                caxis(aT,value{k})
            case 'Title'
                if length(value{k}) ~= length(QLSIImages)
                    warning('The titles must be an array of string with the same length as the serie of images')
                else
                    serieOfTitle = value{k};
                end
            case 'Step'
                if abs(value{k}) >= length(QLSIImages)
                    warning('The step size should be smaller than the serie value !')
                else
                    stepLength = value{k};
                end
            case 'XZoom'
                aOPD.XLim = value{k};
                aT.XLim = value{k};
            case 'YZoom'
                aOPD.YLim = value{k};
                aT.YLim = value{k};
            case 'PDCM'
                if size(value{k}) ~= [size(QLSIImages(1).OPD,1),size(QLSIImages(1).OPD,2),length(QLSIImages)]
                    warning('The PDCM must be a stack with the same size as the serie of images')
                else
                    PDCM_images = value{k};
                    aPDCM = nexttile(TL);
                    imagesc(aPDCM,PDCM_images(:,:,k));
                    aPDCM.NextPlot = 'replacechildren';
                    title(aPDCM,'PDCM');
                    colormap(aPDCM,colorMap_ExtendedKindlmann);
                    aPDCM.DataAspectRatio = [1 1 1];
                end
            case 'ScaleUm'
                scaleX = scaleX * QLSIImages(1).pxSize;
                scaleY = scaleY * QLSIImages(1).pxSize;
        end
    end
end

aOPD.DataAspectRatio = [1 1 1];
aT.DataAspectRatio = [1 1 1];
TL.Title.String = serieOfTitle(k);

figHandle.UserData = 1;
figHandle.KeyPressFcn = @(~,event)updateImage(event,figHandle,aT,TL,aOPD,aPDCM,QLSIImages,PDCM_images,serieOfTitle,stepLength);
end

function updateImage(event,figHandle,aT,TL,aOPD,aPDCM,QLSIImages,PDCM_images,serieOfTitle,stepLength)
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
    if ~isempty(aPDCM)
        imagesc(aPDCM,PDCM_images(:,:,figHandle.UserData));
    end

    TL.Title.String = serieOfTitle(figHandle.UserData);
end
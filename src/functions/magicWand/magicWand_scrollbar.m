%% To zoom on the particle on interest and keep the zoomed images for the following images

function  [mask,maskRemove,fail,roiIN,roiOUT,xlist,ylist] = magicWand_scrollbar(im,roiIN,roiOUT)
% This code is meant to replace magicWand_scrollbar2, and to be used with the
% new gui interface PhaseLABgui



[Ny,Nx] = size(im);


%% Define the tolerance and deltaTolerance used to start as : (OPD90 - OPD10)

[y,edge] = histcounts(im,size(im,2));
Ntot = size(im,1)*size(im,2);
m = 0;
a = 0;
ok = 0;

while ok == 0
    m = m+1;
    a  =  a + y(m);
    if a > 0.999*Ntot
        ok = 1;
    end
end

OPD90 = edge(m);

m = 0;
a = 0;
ok = 0;
while ok == 0
    m = m+1;
    a = a + y(m);
    if a > 0.001*Ntot
        ok = 1;
        
    end
end
OPD10 = edge(m);

OPDamplitude = OPD90-OPD10;
toleranceStart = OPDamplitude/20;

%% press the central pixel of the particle and apply magic wand

%press the central pixel of the particle of interest
%To allow to click on multiple part of the particle of interest

hOPD = figure;
hOPD.UserData.roiIN = roiIN;
hOPD.UserData.roiOUT = roiOUT;
hOPD.UserData.roiDraw = [];

imageph(im)
fullscreen
axis equal
uicontrol('Style','pushbutton','FontSize',14,'BackgroundColor',[0.9 0.6 0.6],...
    'Position',[410 10 150 40],'string','Remove areas',...
    'Callback',@(src,event)magicWand_scrollbar_RemoveROI(hOPD));

uicontrol('Style','pushbutton','FontSize',14,'BackgroundColor',[0.6 0.9 0.6],...
    'Position',[570 10 150 40],'string','Confine area',...
    'Callback',@(src,event)magicWand_scrollbar_confineROI(hOPD));

uicontrol('Style','pushbutton','FontSize',14,'BackgroundColor',[0.2 0.2 0.2],...
    'ForegroundColor',[1 1 1],'Position',[730 10 150 40],'string','Magic wand points','Callback',@(src,event)magicWand_scrollbar_selectPoints(hOPD));

uicontrol('Style','pushbutton','FontSize',14,'BackgroundColor',[1 1 1],      ...
    'ForegroundColor',[0.2 0.2 0.2],'Position',[950 10 150 40],'string','Draw roi (no magic)','Callback',@(src,event)magicWand_scrollbar_drawROI(hOPD));

drawnow

if ~isempty(roiIN)
    Nroi = numel(roiIN);
    for ii = 1:Nroi
        if isvalid(roiIN{ii})
            roiIN{ii}.Parent = gca;
        end
    end
end

if ~isempty(roiOUT)
    Nroi = numel(roiOUT);
    for ii = 1:Nroi
        if ~isempty(roiOUT{ii})
            if isvalid(roiOUT{ii})
                roiOUT{ii}.Parent = gca;
            end
        end
    end
end

hOPD.UserData.processok = 0;
while hOPD.UserData.processok==0
    pause(0.5);
end

if ~isempty(hOPD.UserData.roiIN)
    roiIN = cell(1,1);
    nn = 0;
    for ii = 1:numel(hOPD.UserData.roiIN)
        if isvalid(hOPD.UserData.roiIN{ii})
            nn = nn+1;
            roiIN{nn} = copy(hOPD.UserData.roiIN{ii});% copy, otherwise the handles disappear as soon as hOPD is closed
        end
    end
end

if ~isempty(hOPD.UserData.roiOUT)
    roiOUT = cell(1,1);
    nn = 0;
    for ii = 1:numel(hOPD.UserData.roiOUT)
        if ~isempty(hOPD.UserData.roiOUT{ii})
            if isvalid(hOPD.UserData.roiOUT{ii})
                nn = nn+1;
                roiOUT{nn} = copy(hOPD.UserData.roiOUT{ii});% copy, otherwise the handles disappear as soon as hOPD is closed
            end
        end
    end
end


S = size(im);


if isempty(hOPD.UserData.roiDraw) % no hand-made exact and final roi has be defined
    
    
    if isempty(hOPD.UserData.roiIN) % roiIN selection
        hOPD.UserData.maskManual = true(S(1),S(2));
    else
        hOPD.UserData.maskManual = false(S(1),S(2));
    end
    
    
    
    if ~isempty(hOPD.UserData.roiIN)
        Nroi = numel(hOPD.UserData.roiIN);
        for ii = 1:Nroi
            if isvalid(hOPD.UserData.roiIN{ii})
                Pos = hOPD.UserData.roiIN{ii}.Position; % get the coordinate of the polygon
                S = size(im);
                X = Pos(:,1);
                Y = Pos(:,2);
                hOPD.UserData.maskManual = logical(hOPD.UserData.maskManual+poly2mask(X,Y,S(1),S(2))); % computes a binary ROI mask from an ROI polygon
            end
        end
    end
    
    if ~isempty(hOPD.UserData.roiOUT)
        Nroi = numel(hOPD.UserData.roiOUT);
        for ii = 1:Nroi
            if ~isempty(hOPD.UserData.roiOUT{ii})
                if isvalid(hOPD.UserData.roiOUT{ii})
                    Pos = hOPD.UserData.roiOUT{ii}.Position; % get the coordinate of the polygon
                    S = size(im);
                    X = Pos(:,1);
                    Y = Pos(:,2);
                    hOPD.UserData.maskManual = logical(hOPD.UserData.maskManual.*~poly2mask(X,Y,S(1),S(2))); % computes a binary ROI mask from an ROI polygon
                end
            end
        end
    end
    xlist = hOPD.UserData.xlist;
    ylist = hOPD.UserData.ylist;
    maskRemove = hOPD.UserData.maskManual;
    
    bin_mask = magicWand(im, ylist, xlist, toleranceStart);
    mask = double(bin_mask.*maskRemove);
    
    
    
    hfig1 = figure;
    hfig1.UserData = hOPD.UserData;
    ha1 = gca;
    
    %% Red bin_mask superimposed on phase image to adjust magicWand mask
    A = zeros(Ny, Nx, 3);
    maxval = max(imgaussfilt(im(:),10));
    minval = min(imgaussfilt(im(:),10));
    A1 = (im-minval)/(maxval-minval);
    A2 = A1;
    A3 = A1; %To obtain a grayscale image of the phase
    
    A1(mask~=0) = 1; % pixel corresponding to the mask set to 1 in red channel
    A2(mask~=0) = 0; % pixel corresponding to the mask set to 0 in green channel
    A3(mask~=0) = 0; % pixel corresponding to the mask set to 0 in blue channel
    A(:,:,1)     = A1;
    A(:,:,2)     = A2;
    A(:,:,3)     = A3;
    imagegb(A)
    ha1.XLim = xlim;
    ha1.YLim = ylim;
    title('switch tolerance with arrows, press space when satisfied, press c to redo')
    %xlim=ha1.XLim;
    %ylim=ha1.YLim;
    hfig1.UserData.maskMW = mask;
    hfig1.UserData.tolerance = toleranceStart;
    
    %% To adapt the tolerance if the magic wand fit of the bacteria is not good
    
    uicontrol('style','slider','Position',[20 5 400 20],'Min',log10(toleranceStart)-3,'Max',log10(toleranceStart)+3,'value',log10(toleranceStart),'callback',@(src,evt)dispWandSelection(10^get(src,'value'),im, ylist, xlist ,hfig1,ha1, maxval,minval));
    uicontrol('style','pushbutton','String','validate','Position',[500 5 40 20],'callback',@(src,evt)endWandSelection(hfig1));
    uicontrol('style','pushbutton','String','reclick','Position', [450 5 40 20],'callback',@(src,evt)redoWandSelection(hfig1));
    
    hfig1.UserData.loop = 1;
    
    while hfig1.UserData.loop==1
        pause(0.1)
    end
    
    mask = hfig1.UserData.maskMW;
    fail = hfig1.UserData.fail;
    
    close(hfig1)
    close(hOPD)
    
    
else % if a direct manual segmentation has been done, without magic wand
    
    
    if ~isempty(hOPD.UserData.roiOUT) % if additionally, remove regions have been drawn
        hOPD.UserData.maskManual = true(S(1),S(2));
        Nroi = numel(hOPD.UserData.roiOUT);
        for ii = 1:Nroi
            Pos = hOPD.UserData.roiOUT{ii}.Position; % get the coordinate of the polygon
            S = size(im);
            X = Pos(:,1);
            Y = Pos(:,2);
            hOPD.UserData.maskManual = logical(hOPD.UserData.maskManual.*~poly2mask(X,Y,S(1),S(2))); % computes a binary ROI mask from an ROI polygon
        end
        maskRemove = hOPD.UserData.maskManual;
    else
        maskRemove = true(S(1),S(2));
    end
    
    Pos = hOPD.UserData.roiDraw.Position; % get the coordinate of the polygon

    S = size(im);
    X = Pos(:,1);
    Y = Pos(:,2);
    mask = logical(maskRemove.*poly2mask(X,Y,S(1),S(2))); % computes a binary ROI mask from an ROI polygon
    fail = 0;
    xlist = mean(Pos(:,1));
    ylist = mean(Pos(:,2));
    
    close(hOPD)
 end













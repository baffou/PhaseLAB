function h0 = dynamicFigure(varargin)
% dynamicFigure('ph',IM,'tf',Itf)
% dynamicFigure('gb',{IM.T},'tf',Itf)
% dynamicFigure('ph',IM,'bk',{IM.T},'tf',Itf)
% possible labels: 'ph'  display a phase-like colorscale
%                  'gb'  display a Parula colorscale
%                  'bk'  display a gray scale image
%                  'tf'  computes and display the fft2 of the image
%                  'jet' display a jet colorscale

Np2 = numel(varargin);


if mod(Np2,2)==1
    error('not the proper number of inputs')
end

Np = Np2/2; % number of panels

h = figure(WindowKeyPressFcn=@figureCallback);
h.UserData.titleList = cell(1,1);

% defining the list of display functions
notAdisplay = 0; % Number of keywords that are not a display, such a 'titles'
for ii = 1:Np
    h.UserData.ax(ii)=subplot(1,Np,ii);
    switch varargin{2*ii-1}
        case 'ph'
            h.UserData.fun{ii} = @imageph;
        case 'gb'
            h.UserData.fun{ii} = @imagegb;
        case 'tf'
            h.UserData.fun{ii} = @imagetf;
        case 'jet'
            h.UserData.fun{ii} = @imagejet;
        case {'bk','gr','bw'}
            h.UserData.fun{ii} = @imagebk;
        case {'fl'}
            h.UserData.fun{ii} = @imagefl;
        case {'hsv'}
            h.UserData.fun{ii} = @imagehsv;
        case 'titles'
            h.UserData.titleList = varargin{2*ii};
            notAdisplay = 1;
        otherwise
            error("This keyword is not recognized: "+varargin{2*ii-1})
    end
end

Np = Np - notAdisplay; % reduced Np by 1, just in case there is the 'titles' keyword

% extraction of the images from the objects
h.UserData.imageList = cell(Np,1);
if isempty(h.UserData.titleList{1})
    h.UserData.titleList = cell(Np, 1);
end

for ii = 1:Np
    switch class(varargin{2*ii})
        case 'Interfero'
            h.UserData.imageList{ii} = {varargin{2*ii}.Itf};
        case {'ImageMethods','ImageEM','ImageQLSI'}
            h.UserData.imageList{ii} = {varargin{2*ii}.OPD};
        case 'cell'
            h.UserData.imageList{ii} = varargin{2*ii};
        % case 'double' % Nx x Ny x Nim matrix
        %     for jj = 1:size(varargin{2*ii},3)
        %         h.UserData.imageList{ii}{jj} = varargin{2*ii}(:,:,jj);
        %     end
        case 'double'
            h.UserData.imageList{ii} = varargin(2*ii);
            
    end
end

h.UserData.Nim = numel(h.UserData.imageList{ii}); % # of stored images
h.UserData.nIm = 1; % # of the displayed image
h.UserData.Np = Np; % # of panels
updateImages(h)

if nargout
    h0 = h;
    h0.UserData.changeImage = @(h,step) changeImage(h,step);
end

end


%%%%%%
function figureCallback(src,event)
    if strcmp(event.Key,'rightarrow')
        step = 1;
    elseif strcmp(event.Key,'leftarrow')
        step = -1;
    else
        return
    end
    changeImage(src, step)
end

function changeImage(h,step)
    %axeList=[src.UserData.ax];
    %src.UserData.imageList
    %src
    %event
    Nim = h.UserData.Nim;
    nIm = mod(h.UserData.nIm-1+step,Nim)+1;
    h.UserData.nIm = nIm;
    updateImages(h)
    
end



%%%%%%
function updateImages(h)
    Np = h.UserData.Np;
    nIm = h.UserData.nIm;
    for ip = 1:Np
        subplot(1,Np,ip);
        h.UserData.fun{ip}(h.UserData.imageList{ip}{nIm}) % imagesc(...
        title(h.UserData.titleList{ip})
    end
    h.Name = num2str(nIm);

end

function imagebk(im)
imagegb(im)
set(gca,'colormap',gray)
end



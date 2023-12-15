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
subplot(1,Np,1)

if nargout
    h0 = h;
end

% extraction of the images from the objects
h.UserData.imageList = cell(1,Np);

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
            h.UserData.imageList{ii} = {varargin{2*ii}};
            
    end
end

% defining the list of display functions
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
    end
end

h.UserData.Nim = numel(h.UserData.imageList{ii}); % # of stored images
h.UserData.nIm = 1; % # of the displayed image
h.UserData.Np = Np; % # of panels

updateImages(h)


%linkAxes

end


%%%%%%
function figureCallback(src,event)
    %axeList=[src.UserData.ax];
    %src.UserData.imageList
    %src
    %event
    Nim = src.UserData.Nim;
    if strcmp(event.Key,'rightarrow')
        nIm = mod(src.UserData.nIm,Nim)+1;
    elseif strcmp(event.Key,'leftarrow')
        nIm = mod(src.UserData.nIm-2,Nim)+1;
    else
        return
    end
    src.UserData.nIm = nIm;
    updateImages(src)
    
end


%%%%%%
function updateImages(h)
    Np = h.UserData.Np;
    nIm = h.UserData.nIm;
    for ip = 1:Np
        subplot(1,Np,ip)
        h.UserData.fun{ip}(h.UserData.imageList{ip}{nIm}) % imagesc(...
    end
    h.Name = num2str(nIm);

end

function imagebk(im)
imagegb(im)
set(gca,'colormap',gray)
end


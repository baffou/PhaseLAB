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

Npanels = Np2/2; % number of panels

h = figure(WindowKeyPressFcn=@figureCallback);
h.UserData.titleList = cell(1,1);
h.UserData.range = cell.empty();

% defining the list of display functions
notAdisplay = 0; % Number of keywords that are not a display, such a 'titles'
h.UserData.nm = []; % n*m is the image pattern (n times m subplot images)
for ii = 1:Npanels
    switch varargin{2*ii-1}
        case 'ph'
            h.UserData.dispfun{ii} = @imageph;
        case 'gb'
            h.UserData.dispfun{ii} = @imagegb;
        case 'tf'
            h.UserData.dispfun{ii} = @imagetf;
        case 'jet'
            h.UserData.dispfun{ii} = @imagejet;
        case 'hot'
            h.UserData.dispfun{ii} = @imagehot;
        case {'bk','gr','bw'}
            h.UserData.dispfun{ii} = @imagebk;
        case {'fl'}
            h.UserData.dispfun{ii} = @imagefl;
        case {'dx'}
            h.UserData.dispfun{ii} = @opendx0;
        case {'hsv'}
            h.UserData.dispfun{ii} = @imagehsv;
        case {'Pr'} % Pradeep
            h.UserData.dispfun{ii} = @imagePr;
%        case 'dx'  % does not work
%            h.UserData.dispfun{ii} = @(x) opendx(x,"theta",0,"phi",0,"persp",1,"colorMap",jet);
        case {'titles', 'title', 'Title','Titles'}
            h.UserData.titleList = varargin{2*ii};
            notAdisplay = notAdisplay + 1;
        case {'pattern','nm'}
            h.UserData.nm = varargin{2*ii};
            notAdisplay = notAdisplay + 1;
        case {'range','zrange','clim'}
            h.UserData.range = varargin{2*ii};
            notAdisplay = notAdisplay + 1;
        case {'functions','function','Function','Functions','Func','func','Fun','fun'}
            h.UserData.function = varargin{2*ii};
            notAdisplay = notAdisplay + 1;
        otherwise
            error("This keyword is not recognized: "+varargin{2*ii-1})
    end
end

Npanels = Npanels - notAdisplay; % reduced Np by 1, just in case there is the 'titles' keyword

if isempty(h.UserData.nm)
    h.UserData.nm = [1, Npanels];  % n*m panels
end

if isnumeric(h.UserData.range)
    h.UserData.range = repmat({h.UserData.range}, Npanels, 1);
end


if ~isfield(h.UserData,'function')
    h.UserData.function = repmat({@(x) x},Npanels, 1);
elseif isa(h.UserData.function,'function_handle')
    h.UserData.function = repmat({h.UserData.function}, Npanels, 1);
elseif istext(h.UserData.function)
    h.UserData.function = str2func(varargin{2*ii});
    h.UserData.function = repmat({h.UserData.function}, Npanels, 1);
elseif iscell(h.UserData.function)
    if numel(h.UserData.function) == 1
        h.UserData.function = repmat(h.UserData.function, Npanels, 1);
    elseif numel(h.UserData.function) ~= Npanels
        error('Not the proper number of functions')
    end
    for ip = 1:Npanels
        if isa(h.UserData.function{ip},'function_handle')
            % nothing to be done
        elseif istext(h.UserData.function{ip})
            h.UserData.function{ip} = str2func(h.UserData.function{ip});
        elseif isempty(h.UserData.function{ip}) % [] means identity function
            h.UserData.function{ip} = @(x) x;
        else
            error('wrong function format')
        end
    end

end

% extraction of the images from the objects
h.UserData.imageList = cell(Npanels,1);
if isempty(h.UserData.titleList{1})
    h.UserData.titleList = cell(Npanels, 1);
end

for ii = 1:Npanels
    h.UserData.ax(ii) = subplot(1,Npanels,ii);
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

        case {'double','gpuArray'}
            %Nim = size(varargin{2*ii},3);
            %if Nim == 1  % 2D image
                h.UserData.imageList{ii} = varargin(2*ii);
            %else   % stack of 2D image
            %    h.UserData.imageList{ii} = cell(Nim,1);
            %    for im = 1:Nim
            %        h.UserData.imageList{ii}{im} = varargin{2*ii}(:,:,im);
            %    end
            %end

    end
end

h.UserData.Nim = numel(h.UserData.imageList{ii}); % # of stored images
h.UserData.nIm = 1; % # of the displayed image
h.UserData.Npanels = Npanels; % # of panels
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
    Npanels = h.UserData.Npanels;
    nIm = h.UserData.nIm;
    nx = h.UserData.nm(2);
    ny = h.UserData.nm(1);
    for ip = 1:Npanels
        h.UserData.Axes(ip) = subplot(ny,nx,ip);
        h.UserData.dispfun{ip}(h.UserData.function{ip}(h.UserData.imageList{ip}{nIm})) % imagesc(...
        title(h.UserData.titleList{ip})
        if ~isempty(h.UserData.range)
            if ~isempty(h.UserData.range{ip})
                clim(h.UserData.range{ip})
            end
        end
    end
    h.Name = num2str(nIm)+"/"+num2str(h.UserData.Nim);

end

function imagebk(im)
imagegb(im)
set(gca,'colormap',gray)
end



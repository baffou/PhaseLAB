function varargout = improfile_ax(varargin)
%IMPROFILE Pixel-value cross-sections along line segments.
%   IMPROFILE computes the intensity values along a line or a multiline path
%   in an image. IMPROFILE selects equally spaced points along the path you
%   specify, and then uses interpolation to find the intensity value for
%   each point. IMPROFILE works with grayscale intensity, RGB, and binary
%   images.
%
%   If you call IMPROFILE with one of these syntaxes, it operates
%   interactively on the image in the current axes:
%
%        C = IMPROFILE
%        C = IMPROFILE(N)
%
%   N specifies the number of points to compute intensity values for. If you
%   do not provide this argument, IMPROFILE chooses a value for N, roughly
%   equal to the number of pixels the path traverses.
%
%   You specify the line or path using the mouse, by clicking on points in
%   the image. Press <BACKSPACE> or <DELETE> to remove the previously
%   selected point. A shift-click, right-click, or double-click adds a final
%   point and ends the selection; pressing <RETURN> finishes the selection
%   without adding a point. When you finish selecting points, IMPROFILE
%   returns the interpolated data values in C. C is an N-by-1 vector if the
%   input is a grayscale intensity or binary image.  C is an N-by-1-by-3
%   array if the input image is an RGB image.
%
%   If you omit the output argument, IMPROFILE displays a plot of the
%   computed intensity values. If the specified path consists of a single
%   line segment, IMPROFILE creates a two-dimensional plot of intensity
%   values versus the distance along the line segment; if the path consists
%   of two or more line segments, IMPROFILE creates a three-dimensional plot
%   of the intensity values versus their x- and y-coordinates.
%
%   You can also specify the path noninteractively, using these syntaxes:
%
%        C = IMPROFILE(I,xi,yi)
%        C = IMPROFILE(I,xi,yi,N)
%
%   xi and yi are equal-length vectors specifying the spatial coordinates of
%   the endpoints of the line segments.
%
%   You can use these syntaxes to return additional information:
%
%        [CX,CY,C] = IMPROFILE(...)
%        [CX,CY,C,xi,yi] = IMPROFILE(...)
%
%   CX and CY are vectors of length N, containing the spatial coordinates of
%   the points at which the intensity values are computed.
%
%   To specify a nondefault spatial coordinate system for the input image,
%   use these syntaxes:
%
%        [...] = IMPROFILE(x,y,I,xi,yi)
%        [...] = IMPROFILE(x,y,I,xi,yi,N)
%
%   x and y are 2-element vectors specifying the image XData and YData.
%
%   [...] = IMPROFILE(...,METHOD) uses the specified interpolation
%   method. METHOD is a string that can have one of these values:
%
%        'nearest' (default) uses nearest neighbor interpolation
%
%        'bilinear' uses bilinear interpolation
%
%        'bicubic' uses bicubic interpolation
%
%   If you omit the METHOD argument, IMPROFILE uses the default method of
%   'nearest'.
%
%   Class Support
%   -------------
%   The input image can be uint8, uint16, int16, double, single, or logical.
%   The outputs are double.
%
%   Example
%   -------
%        I = imread('liftingbody.png');
%        x = [19 427 416 77];
%        y = [96 462 37 33];
%        improfile(I,x,y), grid on
%
%   See also IMPIXEL, INTERP2

%   Copyright 1993-2019 The MathWorks, Inc.
matlab.images.internal.errorIfgpuArray(varargin{:});
args = matlab.images.internal.stringToChar(varargin);
[ax,x,y,img,N,method,pCoordinates,getn,getprof] = parse_inputs(args{:});


isRGB = (ndims(img)==3);


% Set up the input image grid
nRows = size(img,1);
nCols = size(img,2);

xmin = min(x(:)); ymin = min(y(:));
xmax = max(x(:)); ymax = max(y(:));

xGridPoints = [];
if nCols>1
    dx          = max( (xmax-xmin)/(nCols-1), eps );  
    xGridPoints = xmin:dx:xmax;
elseif(nCols==1)
    dx = 1;
    if(strcmp(method,'nearest'))  
        % Pad data to enable interp2 to work with this degenerate grid.
        img(:,2)    = NaN;
        xGridPoints = [xmin xmin+dx];
    else
        % Rely on interp2 to issue appropriate message.
        xGridPoints = xmin;
    end

end

% g939182. In interactive mode, when an image is displayed such that the
% intrinsic coordinate system and the world coordinate system point in
% opposite directions, we must account for this when interpolating into the
% grid. We simply flip around the vector that defines the world coordinates
% tied to the intrinsic coordinates.
flippedInteractiveIntrinsicWorldOrientation = getprof && (diff(x(1:2)) < 0);
if flippedInteractiveIntrinsicWorldOrientation
    xGridPoints = fliplr(xGridPoints);
end

yGridPoints = [];
if nRows>1
    dy          = max( (ymax-ymin)/(nRows-1), eps );
    yGridPoints = ymin:dy:ymax;
elseif(nRows==1)
    dy = 1;
    if(strcmp(method,'nearest')) 
        % Pad data to enable interp2 to work with this degenerate grid.
        img(2,:)    = NaN;
        yGridPoints = [ymin ymin+dx];
    else        
        % Rely on interp2 to issue appropriate message.
        yGridPoints = ymin;        
    end
   
end

% g939182. In interactive mode, when an image is displayed such that the
% intrinsic coordinate system and the world coordinate system point in
% opposite directions, we must account for this when interpolating into the
% grid. We simply flip around the vector that defines the world coordinates
% tied to the intrinsic coordinates.
flippedInteractiveIntrinsicWorldOrientation = getprof && (diff(y(1:2)) < 0);
if flippedInteractiveIntrinsicWorldOrientation
    yGridPoints = fliplr(yGridPoints);
end

% The *method syntax of interp2 eliminates overhead associated with
% consistency checking input grids. We are already ensured that they are
% equally spaced and monotonically increasing, so this is a safe
% optimization.
method = strcat('*',method);




% If required, find the number of interpolation points required on the
% profile.
if getn
    % Update coordinates to be based on the grid spacing
    d = bsxfun(@rdivide,pCoordinates,[dx dy]);
    % Find the city-block type distance between consecutive profile points 
    d = diff(d);
    d = ceil(abs(d));
    % For each segment, consider the maximum of the two directions
    d = max(d,[],2);
    % Sum it up to get the total number of required points
    N = max(sum(d),1) + 1;
end




% Parametric distance along the segments which make up the profile
squaredDiff    = diff(pCoordinates,1,1).^2;
sumSquaredDiff = sum(squaredDiff,2);
% Obtain the cumulative distance
cdist          = [0; cumsum(sqrt(sumSquaredDiff))];

% Remove duplicate points if necessary.
killIdx = find(diff(cdist) == 0);
if (~isempty(killIdx))
    cdist(killIdx+1)          = [];
    pCoordinates(killIdx+1,:) = [];
end


% Find the coordinates to interpolate at.
if size(pCoordinates,1) == 1
    % Handle case where user specified a degenerate 1 point profile, e.g.
    % improfile(im,2.3,5.3,...)    
    xg = pCoordinates(1);
    yg = pCoordinates(2);    
    if ~getn
        % Honor the specified number of profile points by duplicating the
        % specified xi,yi. The output will consist of N identical values
        % interpolated within the source image at xi,yi.
        xg = repmat(xg,1,N);
        yg = repmat(xg,1,N);
    end
    
elseif isempty(pCoordinates)
    xg = [];
    yg = [];
    
else    
    % Treat the profile coordinates as a function of the cumulative
    % distance. Interpolate for N new profile coordinates at equally spaced
    % points along the cumulative distance.
    profi = interp1(cdist,pCoordinates,0:(max(cdist)/(N-1)):max(cdist));
    xg = profi(:,1);
    yg = profi(:,2);
end


% Interpolate 
if ~isempty(img) && ~isempty(xg)
    if isRGB
        % Image values along interpolation points - r,g,b planes separately
        % Red plane
        zr = interp2(xGridPoints,yGridPoints,img(:,:,1),xg,yg,method); 
        % Green plane
        zg = interp2(xGridPoints,yGridPoints,img(:,:,2),xg,yg,method); 
        % Blue plane
        zb = interp2(xGridPoints,yGridPoints,img(:,:,3),xg,yg,method); 
    else
        % Image values along interpolation points 
        % the g stands for Grayscale here.
        zg = interp2(xGridPoints,yGridPoints,img,xg,yg,method);
    end
    
    % Get profile points in pixel coordinates
    xg_pix = round(axes2pix(nCols, [xmin xmax], xg)); 
    yg_pix = round(axes2pix(nRows, [ymin ymax], yg));  
    
    % If the result is uint8, Promote to double and put NaN's in the places
    % where the profile went out of the image axes (these are zeros because
    % there is no NaN in UINT8 storage class)
    if ~isa(zg, 'double')     
        outside_axes = find( (xg_pix<1) | (xg_pix>nCols) | ...
                             (yg_pix<1) | (yg_pix>nRows) );                         
        if isRGB
            zr = double(zr); zg = double(zg); zb = double(zb);
            zr(outside_axes) = NaN;
            zg(outside_axes) = NaN;
            zb(outside_axes) = NaN;
        else
            zg               = double(zg);
            zg(outside_axes) = NaN;
        end                 
    end
else
    % empty profile or image data
    % initialize zr/zg/zb for RGB images; just zg for grayscale images;
    [zr, zg, zb] = deal([]);
end




% Handle output(s)
if nargout == 0 && ~isempty(zg) 
    % plot it
    if getprof,
        h   = get(0,'children');
        fig = gobjects(0);
        for i=1:length(h),
            if strcmp(get(h(i),'Tag'),'improfile')
                fig = h(i);
            end
        end
        if isempty(fig) % Create new window
            fig = figure('Name',getString(message('images:improfile:toolName')),...
                'Tag','improfile');
        end
        figure(fig)
        
    else
        gcf;
    end
    
    if length(pCoordinates)>2
        if isRGB
            plot3(xg,yg,zr,'r',...
                  xg,yg,zg,'g',...
                  xg,yg,zb,'b');
        else
            plot3(xg,yg,zg,'b');

        end
        set(gca,'ydir','reverse');
        xlabel X, ylabel Y;
        
    else
        if isRGB
            plot(sqrt((xg-xg(1)).^2+(yg-yg(1)).^2),zr,'r',...
                 sqrt((xg-xg(1)).^2+(yg-yg(1)).^2),zg,'g',...
                 sqrt((xg-xg(1)).^2+(yg-yg(1)).^2),zb,'b');            
        else
            plot(sqrt((xg-xg(1)).^2+(yg-yg(1)).^2),zg,'b');           
        end
        xlabel(getString(message('images:improfile:distanceAlongProfile')));
    end
    
else
    
    if isRGB
        zg = cat(3,zr(:),zg(:),zb(:));
    else
        zg = zg(:);
    end
    
    xi = pCoordinates(:,1);
    yi = pCoordinates(:,2);
    
    switch nargout
    case 0,  
        % If zg was [], we didn't plot and ended up here
        return
    case 1,
        varargout{1} = zg;
    case 3,
        varargout{1} = xg;
        varargout{2} = yg;
        varargout{3} = zg;
    case 5,
        varargout{1} = xg;
        varargout{2} = yg;
        varargout{3} = zg;
        varargout{4} = xi;
        varargout{5} = yi;
    otherwise
        error(message('images:improfile:invalidNumOutputArguments'))
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [ax,Xa,Ya,Img,N,Method,pCoordinates,GetN,GetProf]=parse_inputs(varargin)
% Outputs:
%     Xa           2 element vector for input image axes limits
%     Ya           2 element vector for input image axes limits
%     Img          Image Data
%     N            number of image values along the path (Xi,Yi) to return
%     Method       Interpolation method: 'nearest','bilinear', or 'bicubic'
%     pCoordinates Profile coordinates [xi(:) yi(:)]
%     GetN         Determine number of points from profile if true.
%     GetProf      Get profile from user via mouse if true also get data
%                  from image.

% Set defaults
ax        = [];
N         = [];
GetN      = true;    
GetProf   = false; 
GetCoords = true;  %     GetCoords - Determine axis coordinates if true.

% Optional first input: target axes, like plot(ax,...)
nIn = numel(varargin);
if nIn > 0 && isscalar(varargin{1}) && ...
        (isa(varargin{1},'matlab.graphics.axis.Axes') || ...
         isa(varargin{1},'matlab.ui.control.UIAxes'))
    ax = varargin{1};
    varargin = varargin(2:end);
    nIn = nIn - 1;
end

switch nIn
case 0,            % improfile
    GetProf   = true; 
    GetCoords = false;
    
case 1,            % improfile(n) or improfile('Method')
    if ischar(varargin{1})
        Method = varargin{1}; 
    else 
        N    = varargin{1}; 
        GetN = false; 
    end
    GetProf   = true; 
    GetCoords = false;
    
case 2,            % improfile(n,'method')
    Method    = varargin{2};
    N         = varargin{1}; 
    GetN      = false; 
    GetProf   = true; 
    GetCoords = false;
    
case 3,   % improfile(a,xi,yi)
    A  = varargin{1};
    Xi = varargin{2}; 
    Yi = varargin{3}; 
        
case 4,   % improfile(a,xi,yi,n) or improfile(a,xi,yi,'method')
    A  = varargin{1};
    Xi = varargin{2}; 
    Yi = varargin{3}; 
    if ischar(varargin{4}) 
        Method = varargin{4}; 
    else 
        N    = varargin{4}; 
        GetN = false; 
    end
    
case 5, % improfile(x,y,a,xi,yi) or improfile(a,xi,yi,n,'method')
    if ischar(varargin{5}), 
        A      = varargin{1};
        Xi     = varargin{2}; 
        Yi     = varargin{3}; 
        N      = varargin{4}; 
        Method = varargin{5}; 
        GetN   = false; 
    else
        GetCoords = false;
        Xa        = varargin{1}; 
        Ya        = varargin{2}; 
        A         = varargin{3};
        Xi        = varargin{4}; 
        Yi        = varargin{5}; 
    end
    
case 6, % improfile(x,y,a,xi,yi,n) or improfile(x,y,a,xi,yi,'method')
    Xa = varargin{1}; 
    Ya = varargin{2}; 
    A  = varargin{3};
    Xi = varargin{4}; 
    Yi = varargin{5}; 
    if ischar(varargin{6}), 
        Method = varargin{6}; 
    else 
        N    = varargin{6};
        GetN = false; 
    end
    GetCoords = false;
    
case 7, % improfile(x,y,a,xi,yi,n,'method')
    if ~ischar(varargin{7}) 
        error(message('images:improfile:invalidInputArrangementOrNumber'))
    end
    Xa = varargin{1}; 
    Ya = varargin{2}; 
    A  = varargin{3};
    Xi = varargin{4}; 
    Yi = varargin{5}; 
    N  = varargin{6};
    Method    = varargin{7}; 
    GetN      = false;
    GetCoords = false; 
    
otherwise
    error(message('images:improfile:invalidInputArrangementOrNumber'))
end

%error checking for Method
if exist('Method','var')
    validatestring(Method,{'nearest', 'bilinear', 'bicubic'},...
        mfilename,'METHOD',nIn);
else 
    Method = 'nearest';
end

% set Xa and Ya if unspecified
if (GetCoords && ~GetProf),
    Xa = [1 size(A,2)];
    Ya = [1 size(A,1)];
end

% error checking for N
if (~GetN)
    if (N<2 || ~isa(N, 'double'))
        error(message('images:improfile:invalidNumberOfPointsN'))
    end
end

% Get profile from user if necessary using data from image
if GetProf, 
    [Xa,Ya,A,state] = getimage;
    if ~state
        error(message('images:improfile:noImageinAxis'))
    end
    pCoordinates = getline(gca); % Get profile from user
        
else  % We already have A, Xi, and Yi
    if numel(Xi) ~= numel(Yi)
        error(message('images:improfile:invalidNumberOfPointsXiYi'))
    end
    pCoordinates = [Xi(:) Yi(:)]; % [xi yi]
end

% error checking for A
if (~isa(A,'double') && ~isa(A,'uint8') && ...
        ~isa(A, 'uint16') && ~islogical(A)) &&...
        ~isa(A,'single') && ~isa(A,'int16')
    error(message('images:improfile:invalidImage'))
end

% Promote the image to single if it is logical or if we are not using nearest.
if islogical(A) || (~isa(A,'double') && ~strcmp(Method,'nearest')) 
    Img = single(A);
else
    Img = A;
end

% error checking for Xa and  Ya
if (~isa(Xa,'double') || ~isa(Ya, 'double'))
    error(message('images:improfile:invalidClassForInput'))
end   

% error checking for Xi and Yi
if (~GetProf && (~isa(Xi,'double') || ~isa(Yi, 'double')))
    error(message('images:improfile:invalidClassForInput'))
end


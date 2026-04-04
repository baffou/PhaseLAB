function [zg,xg,yg,xi,yi] = improfile_GB(N, Xa, Ya, opt)

arguments
    N = [];
    Xa = []
    Ya = []
    opt.Image = []
    opt.Xi = []
    opt.Yi = []
    opt.Method char {mustBeMember(opt.Method,{'nearest','bilinear','bicubic'})} = 'nearest'
    opt.hax = gca
end

%% IMPROFILE Pixel-value cross-sections along line segments.
%   IMPROFILE computes the intensity values along a line or a multiline path
%   in an image. IMPROFILE selects equally spaced points along the path you
%   specify, and then uses interpolation to find the intensity value for
%   each point. IMPROFILE works with grayscale intensity, RGB, and binary
%   images.
%
%   If you call IMPROFILE with one of these syntaxes, it operates
%   interactively on the image in the current axes:
%
%        zg = IMPROFILE
%        zg = IMPROFILE(N)
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
%   returns the interpolated data values in zg. zg is an N-by-1 vector if the
%   input is a grayscale intensity or binary image.  zg is an N-by-1-by-3
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
%        zg = IMPROFILE(N,xi,yi,Image = I)
%
%   xi and yi are equal-length vectors specifying the spatial coordinates of
%   the endpoints of the line segments.
%
%   You can use these syntaxes to return additional information:
%
%        [zg, xg, yg, xi, yi] = IMPROFILE(...)
%
%   xg and yg are vectors of length N, containing the spatial coordinates of
%   the points at which the intensity values are computed.
%
%   To specify a nondefault spatial coordinate system for the input image,
%   use these syntaxes:
%
%        [...] = IMPROFILE(N,x,y,Image=I,Xi=xi,Yi=yi)
%        [...] = IMPROFILE(N,x,y,Image=I,Xi=xi,Yi=yi)
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
%        improfile_GB(I,x,y), grid on
%
%   See also IMPIXEL, INTERP2

%   Copyright 1993-2019 The MathWorks, Inc.
%matlab.images.internal.errorIfgpuArray(varargin{:});
%args = matlab.images.internal.stringToChar(varargin);
%%
[x,y,img,N,method,pCoordinates,getn,getprof] = ...
    parse_inputs(Xa,Ya,opt.Image,opt.Xi,opt.Yi,N,opt.Method,opt.hax);


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




end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [Xa,Ya,Img,N,Method,pCoordinates,GetN,GetProf]=parse_inputs(Xa,Ya,Img,Xi,Yi,N,Method,hax)
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
arguments
    Xa
    Ya
    Img
    Xi
    Yi
    N
    Method
    hax
end

if isempty(Xi)
    GetProf   = true;
else
    GetProf   = false;
end

if isempty(Xa)
    GetCoords   = true;
else
    GetCoords   = false;
end

if isempty(N)
    GetN   = true;
else
    GetN   = false;
end

% set Xa and Ya if unspecified
if (GetCoords && ~GetProf)
    Xa = [1 size(Img,2)];
    Ya = [1 size(Img,1)];
end

% error checking for N
if ~isempty(N)
    if (N<2 || ~isa(N, 'double'))
        error(message('images:improfile:invalidNumberOfPointsN'))
    end
end

% Get profile from user if necessary using data from image
if GetProf
    [Xa,Ya,Img,state] = getimage(hax);
    if ~state
        error(message('images:improfile:noImageinAxis'))
    end
    pCoordinates = getline(hax); % Get profile from user

else  % We already have Img, Xi, and Yi
    if numel(Xi) ~= numel(Yi)
        error(message('images:improfile:invalidNumberOfPointsXiYi'))
    end
    pCoordinates = [Xi(:) Yi(:)]; % [xi yi]
end

% error checking for Img
if (~isa(Img,'double') && ~isa(Img,'uint8') && ...
        ~isa(Img, 'uint16') && ~islogical(Img)) &&...
        ~isa(Img,'single') && ~isa(Img,'int16')
    error(message('images:improfile:invalidImage'))
end

% Promote the image to single if it is logical or if we are not using nearest.
if islogical(Img) || (~isa(Img,'double') && ~strcmp(Method,'nearest'))
    Img = single(Img);
else
    Img = Img;
end

% error checking for Xa and  Ya
if (~isa(Xa,'double') || ~isa(Ya, 'double'))
    error(message('images:improfile:invalidClassForInput'))
end

% error checking for Xi and Yi
if (~GetProf && (~isa(Xi,'double') || ~isa(Yi, 'double')))
    error(message('images:improfile:invalidClassForInput'))
end


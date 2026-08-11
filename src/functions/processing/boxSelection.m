function [x1, x2, y1, y2] = boxSelection(im,opt)
% im: list of Interfero or ImageMethods, or a matrix
% opt:  opt.xy1 , opt.xy2 : coordonnées de deux coins opposés du rectangle
%       opt.Center = 'Auto' or 'Manual'
%       opt.Size = 'Auto' or 'Manual'
%       opt.twoPoints true or false
%       opt.figure = [];

arguments
    im  % list of Interfero or ImageMethods, or a matrix, or a PhaseLABgui
    opt.xy1 = []
    opt.xy2 = []
    opt.Center = 'Manual' % 'Auto', 'Manual' or [x, y]
    opt.Size = 'Manual' % 'Auto', 'Manual', d or [dx, dy]
    opt.twoPoints logical = true
    opt.roi (1,:) double = []
    opt.shape char {mustBeMember(opt.shape,{'square','rectangle','Square','Rectangle'})}= 'square'
    opt.displayT logical = false
    opt.colorImage = false % if it is true, keeps the same color in pixel (1,1) after cropping, for a 2-color camera
    opt.polarImage = true % if it is true, keeps the same polar in pixel (1,1) after cropping, for a 4-polar camera
    opt.colormap = parula
    opt.params = [] % [x1, x2, y1, y2]
    opt.margin double {mustBeInteger} = 0
    opt.even = true % image dimensions must be even
    opt.hfig matlab.ui.Figure = matlab.ui.Figure.empty()
    opt.axes char {mustBeMember(opt.axes,{'Left','Right'})} = 'Left'
    %    opt.figure = []; % figure uifigure object to be considered in case the image is already open
end


if isnumeric(opt.Center) && isnumeric(opt.Size)
    displayOn = false;
elseif isempty(opt.xy1) && ...
        isempty(opt.xy2) && ...
        strcmp(opt.Center,'Auto') && ...
        strcmp(opt.Size,'Auto') && ...
        ~opt.twoPoints && ...
        isempty(opt.params)
    displayOn = false;
else
    displayOn = true;
end

isapp = 0;
if isnumeric(im)
    [Ny, Nx]= size(im);
elseif isa(im,'ImageMethods') || isa(im,'Interfero')
    Nx = im(1).Nx;
    Ny = im(1).Ny;
elseif isa(im,'matlab.apps.AppBase') % is im an app, PhaseLABgui, or PhaseLABgui_multiCanal
    isapp = 1;
    app = im;
    im = app.IMcurrent();
    Nx = im.Nx;
    Ny = im.Ny;
end

if opt.margin ~= 0
    x1 = 1  + opt.margin;
    x2 = Nx - opt.margin;
    y1 = 1  + opt.margin;
    y2 = Ny - opt.margin;
elseif ~isempty(opt.xy1) && ~isempty(opt.xy2)  % crop('xy1', [a,b], 'xy2', [a,b])
    if numel(opt.xy1)~=2
        error('First input must be a 2-vector (x,y)')
    end
    if numel(opt.xy2)~=2
        error('Second input must be a 2-vector (x,y)')
    end
    x1 = min([opt.xy1(1),opt.xy2(1)]);
    x2 = max([opt.xy1(1),opt.xy2(1)]);
    y1 = min([opt.xy1(2),opt.xy2(2)]);
    y2 = max([opt.xy1(2),opt.xy2(2)]);
elseif ~isempty(opt.roi)  % crop('roi', [x0 y0 width height])
    if numel(opt.roi)~=4
        error('First input must be a 4-vector roi = (x,y,w,h)')
    end
    x1 = round(opt.roi(1));
    x2 = round(opt.roi(1)+opt.roi(3)-1);
    y1 = round(opt.roi(2));
    y2 = round(opt.roi(2)+opt.roi(4)-1);
elseif ~isempty(opt.params)

    x1 = opt.params(1);
    x2 = opt.params(2);
    y1 = opt.params(3);
    y2 = opt.params(4);
else

    if displayOn
        if isnumeric(im)
            if isempty(opt.hfig)
                h=figure;
                imagegb(im,opt.colormap)
                h.UserData.Axes = gca;
                fullscreen
            else
                h = opt.hfig;
            end

        elseif isapp % is im an app, PhaseLABgui, or PhaseLABgui_multiCanal
            h = app.UIFigure;
            % Check Matlab version, throw error if prior to r2020b
            %assert(~verLessThan('Matlab', '9.9'), 'ginput not supported prior to Matlab r2020b.')

            % Set up figure handle visibility, run ginput, and return state
            fhv = app.UIFigure.HandleVisibility;        % Current status
            app.UIFigure.HandleVisibility = 'callback'; % Temp change (or, 'on')
            set(0, 'CurrentFigure', app.UIFigure)       % Make fig current
            h.UserData.Axes = [app.AxesLeft, app.AxesRight];
            axes(app.("Axes"+opt.axes))
        elseif isa(im,'ImageMethods')
            Np = size(im,2);
            if opt.displayT
                imS = 0;
                for ip = 1:Np
                    imS = imS+im(1,ip).T/4;
                end
            else
                imS = 0;
                for ip = 1:Np
                    imS = imS+im(1,ip).OPD/4;
                end
            end
            h=figure;imagegb(imS,opt.colormap)
            fullscreen
            h.UserData.Axes = gca;
        elseif isa(im,'Interfero')
            h=figure;imagegb(imgaussfilt(im(1).Itf,4),opt.colormap) % imgaussfilt to remove the fringe and better see
            h.UserData.Axes = gca;
            fullscreen
        end
    end


    if opt.twoPoints
        if isapp
            app.displayMessage('Draw a rectangle')
        end
        h.Visible = true;
        roi = drawrectangle;
        x1 = round(roi.Position(1)-0.5);
        x2 = round(roi.Position(1)+roi.Position(3)-0.5);
        y1 = round(roi.Position(2)-0.5);
        y2 = round(roi.Position(2)+roi.Position(4)-0.5);


        if isapp
            app.displayMessage('Wait...',"color",app.warnColor)
            if strcmp(app.scaleButton.SelectedObject.Text,'µm')
                x1=app.um2px(x1);
                y1=app.um2px(y1);
                x2=app.um2px(x2);
                y2=app.um2px(y2);
            end
        end



    else % if not twopoints
        if isnumeric(opt.Center) % crop('Center',[300, 200])
            if numel(opt.Center)==2
                xc_px=opt.Center(1);
                yc_px=opt.Center(2);
            else
                error('the Center argument must be a 2-vector [x, y], or a char array ''Manual'' or ''Auto''.')
            end
        elseif strcmpi(opt.Center,'Manual') % crop('Center','Manual')
            h.Visible = true;

            [xc_px,yc_px] = ginput(1);

            if isapp

                if strcmp(app.scaleButton.SelectedObject.Text,'µm')
                    [xc_px,yc_px]=app.um2px([xc_px, yc_px]);
                end

            end

        else
            xc_px = (Nx+1)/2;
            yc_px = (Ny+1)/2;
        end
        if strcmpi(opt.Size,'Manual') % crop('Center','Manual')
            h.Visible = true;
            h.UserData.getPoint = 0;

            rr = rectangle(h.UserData.Axes(1),'EdgeColor',[0.3 0.5 1], LineWidth=2);
            if isapp
                set (h, 'WindowButtonMotionFcn', @(src,event)drawRect(app,rr,xc_px,yc_px,opt.shape))
            else
                set (h, 'WindowButtonMotionFcn', @(src,event)drawRect(h,rr,xc_px,yc_px,opt.shape))
            end
            set (h, 'WindowButtonDownFcn', @(src,event)getPoint(h))

            % while loop
            while h.UserData.getPoint==0
                pause(0.1)
            end
            set (h, 'WindowButtonMotionFcn', char.empty())
            set (h, 'WindowButtonDownFcn', char.empty())


            Size_px = h.UserData.side_px;
            Size_units = h.UserData.side_units;
            if length(Size_px)==1
                Size_units=[Size_units, Size_units];
                Size_px=[Size_px, Size_px];
            end


        elseif isnumeric(opt.Size)
            if isapp
                if  strcmpi(app.scale,'µm')
                    Size_px = app.um2px(opt.Size);
                    Size_units = opt.Size;
                else
                    Size_px = opt.Size;
                    Size_units = opt.Size;
                end
            else
                Size_px = opt.Size;
                Size_units = opt.Size;
            end



            if length(Size_px)==1
                Size_px = [Size_px, Size_px];
                Size_units = [Size_units, Size_units];
            end
        else % opt.Size == 'Auto'
            Size_px = [Nx, Ny];
        end
        if opt.even
            for ii=1:2 % makes sure all the dimenions of the image size are even
                if mod(Size_px(ii),2)==1
                    Size_px(ii)=Size_px(ii)-1;
                    if isapp
                        if strcmpi(app.scale,'µm')
                            Size_units(ii) = app.px2um(Size_px(ii));
                        else
                            Size_units(ii) = Size_px(ii);
                        end
                    else
                        Size_units(ii) = Size_px(ii);
                    end
                end
    
            end
        end
        x1 = floor(xc_px-Size_px(1)/2+1);
        x2 = floor(xc_px-Size_px(1)/2+Size_px(1));
        y1 = floor(yc_px-Size_px(2)/2+1);
        y2 = floor(yc_px-Size_px(2)/2+Size_px(2));

        if displayOn
            if ~isapp && isempty(opt.hfig)
                pause(0.1)
                close(h)
            else
                if isempty(opt.hfig)
                    app.UIFigure.HandleVisibility = fhv;    % return original state
                end
            end
        end

        if exist('rr','var')
            delete(rr)
        end
    end
end
if opt.colorImage % shift the image by one pixel right, to make sure the bottom-left pixel keeps the same color as in the original image
    if ~isSameParity(x1,y1)
        x1=x1+1;
        x2=x2+1;
    end
end

if opt.polarImage % shift the image by one pixel right, to make sure the bottom-left pixel keeps the same color as in the original image
    if isEven(x1)
        x1=x1+1;
        if x2 == Nx
            x2 = x2-1;
        else
            x2=x2+1;
        end
    end
    if isEven(y1)
        y1=y1+1;
        if y2 == Ny
            y2 = y2-1;
        else
            y2=y2+1;
        end
    end
end




end

function drawRect(h,rr,xc_px,yc_px,shape)
arguments
    h
    rr
    xc_px
    yc_px
    shape = 'square';
end
if isa(h,'matlab.apps.AppBase')
    Pos_units = get (h.UIFigure.UserData.Axes(1), 'CurrentPoint');
    if strcmpi(h.scaleButton.SelectedObject.Text,'µm') % if µm scale is selected
        Pos_px = h.um2px(Pos_units);
        xc_unit = h.px2um(xc_px);
        yc_unit = h.px2um(yc_px);
    else
        Pos_px = Pos_units;
        xc_unit = xc_px;
        yc_unit = yc_px;
    end
else
    Pos_units = get (h.UserData.Axes(1), 'CurrentPoint');
    Pos_px= Pos_units;
    xc_unit = xc_px;
    yc_unit = yc_px;
end
if strcmpi(shape,'square')
    side_units = floor(max(abs([2*(Pos_units(1)-xc_unit), 2*(Pos_units(3)-yc_unit)])));
    side_px    = floor(max(abs([2*(Pos_px(1)   -xc_px),   2*(Pos_px(3)-   yc_px  )])));
    set(rr,'Position',[xc_unit-side_units/2 yc_unit-side_units/2 side_units side_units])
elseif strcmpi(shape,'rectangle')
    side_units = floor([abs([2*(Pos_units(1)-xc_unit), 2*(Pos_units(3)-yc_unit)])]);
    side_px = floor([abs([2*(Pos_px(1)-xc_px), 2*(Pos_px(3)-yc_px)])]);
    set(rr,'Position',[xc_unit-side_units(1)/2 yc_unit-side_units(2)/2 side_units(1) side_units(2)])
end
if isa(h,'matlab.apps.AppBase')
    h.UIFigure.UserData.side_units = side_units;
    h.UIFigure.UserData.side_px = side_px;
else
    h.UserData.side_units = side_units;
    h.UserData.side_px = side_px;
end
if isa(h,'matlab.apps.AppBase')
    h.displayMessage(sprintf('Size: %d µm, %d px\n',side_units,side_px))
else
    title(sprintf('Size: %d px\n',side_px))
end
end

function getPoint(h)
h.UserData.getPoint = 1;
end

function bool = isSameParity(val1,val2)
bool = mod(val1-val2,2)==0;
end


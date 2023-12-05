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
    opt.Center = 'Auto' % 'Auto', 'Manual' or [x, y]
    opt.Size = 'Manual' % 'Auto', 'Manual', d or [dx, dy]
    opt.twoPoints logical = true
    opt.params double = double.empty() % = [x1, x2, y1, y2]
    opt.shape char {mustBeMember(opt.shape,{'square','rectangle','Square','Rectangle'})}= 'square'
    opt.displayT logical = false
    opt.colorImage = false % if it is true, keeps the same color in pixel (1,1) after cropping
    opt.colormap = parula;
    %    opt.figure = []; % figure uifigure object to be considered in case the image is already open
end


isapp = 0;
if isnumeric(im)
    h=figure;imagegb(im,opt.colormap)
    [Ny, Nx]= size(im);
    h.UserData.Axes = gca;
elseif isa(im,'ImageMethods')
    if opt.displayT
        h=figure;imagegb(im(1).T,opt.colormap)
    else
        h=figure;imagegb(im(1).OPD,opt.colormap)
    end
    Nx = im(1).Nx;
    Ny = im(1).Ny;
    h.UserData.Axes = gca;
elseif isa(im,'Interfero')
    h=figure;imagegb(im(1).Itf,opt.colormap)
    Nx = im(1).Nx;
    Ny = im(1).Ny;
    h.UserData.Axes = gca;
elseif isa(im,'PhaseLABgui')
    isapp = 1;
    app = im;
    h = app.UIFigure;
    im = app.IMcurrent();
    Nx = im.Nx;
    Ny = im.Ny;
    % Check Matlab version, throw error if prior to r2020b
    %assert(~verLessThan('Matlab', '9.9'), 'ginput not supported prior to Matlab r2020b.')

    % Set up figure handle visibility, run ginput, and return state
    fhv = app.UIFigure.HandleVisibility;        % Current status
    app.UIFigure.HandleVisibility = 'callback'; % Temp change (or, 'on')
    set(0, 'CurrentFigure', app.UIFigure)       % Make fig current
    h.UserData.Axes = [app.AxesLeft, app.AxesRight];
    axes(app.AxesLeft)

end





if opt.twoPoints
    if isapp
        app.displayMessage('Draw a rectangle')
    end

    roi = drawrectangle;
    x1 = round(roi.Position(1));
    x2 = round(roi.Position(1)+roi.Position(3));
    y1 = round(roi.Position(2));
    y2 = round(roi.Position(2)+roi.Position(4));

    if isapp
        app.clearMessageArea()
        if strcmp(app.scaleButton.SelectedObject.Text,'µm')
            x1=app.um2px(x1);
            y1=app.um2px(y1);
            x2=app.um2px(x2);
            y2=app.um2px(y2);
        end
    end

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
else % if not twopoints
    if isnumeric(opt.Center) % crop('Center',[300, 200])
        if numel(opt.Center)==2
            xc_px=opt.Center(1);
            yc_px=opt.Center(2);
        else
            error('the Center argument must be a 2-vector [x, y], or a char array ''Manual'' or ''Auto''.')
        end
    elseif strcmpi(opt.Center,'Manual') % crop('Center','Manual')

        [xc_px,yc_px]=ginput(1);

        if isapp

            if strcmp(app.scaleButton.SelectedObject.Text,'µm')
                [xc_px,yc_px]=app.um2px([xc_px, yc_px]);
            end

        end

    else
        xc_px = Nx/2;
        yc_px = Ny/2;
    end
    if strcmpi(opt.Size,'Manual') % crop('Center','Manual')
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
        Size_px = [Ny, Nx];
    end
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
    x1 = floor(xc_px-Size_px(1)/2+1);
    x2 = floor(xc_px-Size_px(1)/2+Size_px(1));
    y1 = floor(yc_px-Size_px(2)/2+1);
    y2 = floor(yc_px-Size_px(2)/2+Size_px(2));

    if opt.colorImage % shift the image by one pixel right, to make sure the bottom-left pixel keeps the same color as in the original image
        if ~isSameParity(x1,y1)
            x1=x1+1;
            x2=x2+1;
        end
    end


    if exist('rr','var')
        delete(rr)
    end
    if ~isapp
        pause(0.5)
        close(h)
    else
        app.UIFigure.HandleVisibility = fhv;    % return original state

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
if isa(h,'PhaseLABgui')
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
if isa(h,'PhaseLABgui')
    h.UIFigure.UserData.side_units = side_units;
    h.UIFigure.UserData.side_px = side_px;
else
    h.UserData.side_units = side_units;
    h.UserData.side_px = side_px;
end
if isa(h,'PhaseLABgui')
    title(sprintf('Size: %d µm, %d px\n',side_units,side_px))
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


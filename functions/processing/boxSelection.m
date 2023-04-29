function [x1, x2, y1, y2] = boxSelection(im,opt)
% im: list of Interfero or ImageMethods, or a matrix
% opt:  opt.xy1 , opt.xy2 : coordonnées de deux coins opposés du rectangle
%       opt.Center = 'Auto' or 'Manual'
%       opt.Size = 'Auto' or 'Manual'
%       opt.twoPoints true or false
%       opt.figure = [];

if nargin == 1
    opt.twoPoints = true;
    opt.figure = [];
end

if ~isfield(opt,'imNumber') && numel(im)>1 % If no image number is specified although it is a list of objects
    opt.imNumber = 1; % ... then take the first object
end



if opt.twoPoints
    if isnumeric(im) % a simple matrix
        if isempty(opt.figure)
            figure,imagegb(im)
        else
            figure(opt.figure)
        end

        roi = drawrectangle;
        x1 = round(roi.Position(1));
        x2 = round(roi.Position(1)+roi.Position(3));
        y1 = round(roi.Position(2));
        y2 = round(roi.Position(2)+roi.Position(4));

        %        [xx,yy]=ginput(2);
    elseif isa(opt.figure,'matlab.ui.Figure')
        figure(opt.figure),imagegb(im)
        roi = drawrectangle;
        x1 = round(roi.Position(1));
        x2 = round(roi.Position(1)+roi.Position(3));
        y1 = round(roi.Position(2));
        y2 = round(roi.Position(2)+roi.Position(4));
        %        [xx,yy]=ginput(2);
    elseif isa(opt.figure,'PhaseLABgui')
        app=opt.figure;
        if isfield(opt,'imNumber')
            app.jim = opt.imNumber;
            app.updateImages
        end
        % Check Matlab version, throw error if prior to r2020b
        %assert(~verLessThan('Matlab', '9.9'), 'ginput not supported prior to Matlab r2020b.')

        % Set up figure handle visibility, run ginput, and return state
        fhv = app.UIFigure.HandleVisibility;        % Current status
        app.UIFigure.HandleVisibility = 'callback'; % Temp change (or, 'on')
        set(0, 'CurrentFigure', app.UIFigure)       % Make fig current
        axes(app.AxesLeft)
        app.displayMessage('Draw a rectangle')
        roi = drawrectangle;
        app.clearMessageArea()
        x1 = round(roi.Position(1));
        x2 = round(roi.Position(1)+roi.Position(3));
        y1 = round(roi.Position(2));
        y2 = round(roi.Position(2)+roi.Position(4));
        %        [xx,yy]=ginput(2);                          % run ginput
        if strcmp(app.scaleButton.SelectedObject.Text,'µm')
            x1=app.um2px(x1);
            y1=app.um2px(y1);
            x2=app.um2px(x2);
            y2=app.um2px(y2);
        end
        opt.app.UIFigure.HandleVisibility = fhv;    % return original state
    end
    %     x1=round(min(xx));
    %     x2=round(max(xx));
    %     y1=round(min(yy));
    %     y2=round(max(yy));
    %     x1=round(max([1;x1]));
    %     x2=round(min([Nx;x2]));
    %     y1=round(max([1;y1]));
    %     y2=round(min([Ny;y2]));
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

        if isempty(opt.figure)
            figure,imagegb(im)
            [xc_px,yc_px]=ginput(1);
        elseif isa(opt.figure,'matlab.ui.Figure')
            figure(opt.figure),imagegb(im)
            [xc_px,yc_px]=ginput(1);
        elseif isa(opt.figure,'PhaseLABgui')
            app=opt.figure;
            if isfield(opt,'imNumber')
                app.jim = opt.imNumber;
                app.updateImages
            end
            % Check Matlab version, throw error if prior to r2020b
            %assert(~verLessThan('Matlab', '9.9'), 'ginput not supported prior to Matlab r2020b.')

            % Set up figure handle visibility, run ginput, and return state
            fhv = app.UIFigure.HandleVisibility;        % Current status
            app.UIFigure.HandleVisibility = 'callback'; % Temp change (or, 'on')
            set(0, 'CurrentFigure', app.UIFigure)       % Make fig current

            [xc_units,yc_units]=ginput(1);
            if strcmp(app.scaleButton.SelectedObject.Text,'µm')
                [xc_px,yc_px]=app.um2px([xc_units, yc_units]);
            else
                xc_px=xc_units;
                yc_px=yc_units;
            end

            opt.app.UIFigure.HandleVisibility = fhv;    % return original state
        end

    else
        xc_px = im.Nx/2;
        yc_px = im.Ny/2;
    end
    if strcmpi(opt.Size,'Manual') % crop('Center','Manual')
        if isempty(opt.figure)
            h=figure;imagegb(im)
            h.UserData{12}.getPoint = 0;
        elseif isa(opt.figure,'matlab.ui.Figure')
            h=figure(opt.figure);imagegb(im)
            h.UserData{12}.getPoint = 0;
        elseif isa(opt.figure,'PhaseLABgui')
            app=opt.figure;
            if isfield(opt,'imNumber')
                app.jim = opt.imNumber;
                app.updateImages
            end
            h = app.UIFigure;
            h.UserData = cell(20);
            h.UserData{12}.getPoint=0;
            h.UserData{7}=[app.AxesRight, app.AxesLeft];
            % Check Matlab version, throw error if prior to r2020b
            %assert(~verLessThan('Matlab', '9.9'), 'ginput not supported prior to Matlab r2020b.')

            % Set up figure handle visibility, run ginput, and return state
            fhv = app.UIFigure.HandleVisibility;        % Current status
            app.UIFigure.HandleVisibility = 'callback'; % Temp change (or, 'on')
            set(0, 'CurrentFigure', app.UIFigure)       % Make fig current

        else
            error('the figure parameter is uniddentified')
        end

        rr = rectangle('EdgeColor',[0.3 0.5 1], LineWidth=2);
        set (h, 'WindowButtonMotionFcn', @(src,event)drawRect(app,rr,xc_px,yc_px,opt.shape))
        set (h, 'WindowButtonDownFcn', @(src,event)getPoint(app))

        % while loop
        while h.UserData{12}.getPoint==0
            pause(0.1)
        end
        set (h, 'WindowButtonMotionFcn', char.empty())
        set (h, 'WindowButtonDownFcn', char.empty())

        if isa(opt.figure,'PhaseLABgui')
            opt.app.UIFigure.HandleVisibility = fhv;    % return original state
        end

        Size_px = h.UserData{12}.side_px;
        Size_units = h.UserData{12}.side_units;
        if length(Size_px)==1
            Size_units=[Size_units, Size_units];
            Size_px=[Size_px, Size_px];
        end


    elseif isnumeric(opt.Size)
        if isa(opt.figure,'PhaseLABgui')
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


    end
    for ii=1:2 % makes sure all the dimenions of the image size are even
        if mod(Size_px(ii),2)==1
            Size_px(ii)=Size_px(ii)-1;
            if isa(opt.figure,'PhaseLABgui')
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

end

% if mod(x2-x1,2)==0
%     x2=x2-1;
% end
% if mod(y2-y1,2)==0
%     y2=y2-1;
% end



    function drawRect(h,rr,xc_px,yc_px,shape)
        if nargin == 4
            shape = 'square';
        end
        if isa(h,'PhaseLABgui')
            Pos_units = get (h.UIFigure.UserData{7}(2), 'CurrentPoint');
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
            Pos_units = get (h.UserData{7}(2), 'CurrentPoint');
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
            h.UIFigure.UserData{12}.side_units = side_units;
            h.UIFigure.UserData{12}.side_px = side_px;
        else
            h.UserData{12}.side_units = side_units;
            h.UserData{12}.side_px = side_px;
        end
    end

    function getPoint(h)
        if isa(h,'PhaseLABgui')
            h.UIFigure.UserData{12}.getPoint = 1;
        else
            h.UserData{12}.getPoint = 1;
        end
    end


end
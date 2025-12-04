classdef Scalebar  <  handle

    properties
        value (1,1) double % length of the scalebar in [m]
        pxSize (1,1) double % pixel size of the image in [m]
        thickness (1,1) double % thickness of the scale bar in % of the height of the image
        unit {mustBeMember(unit,{'px','µm'})} = 'px'  % unit to be displayed
        color
        fontSize
        Position
    end



    methods

        function obj = Scalebar(value, pxSize, opt)

            arguments
                value
                pxSize
                opt.thickness = 1 % [%]
                opt.unit = 'px'
                opt.color = [1 1 1]
                opt.fontSize  = 12
                opt.Position = [6 6] % [%]
            end

            obj.value = value;
            obj.pxSize = pxSize;
            obj.thickness = opt.thickness;
            obj.unit = opt.unit;
            obj.color = opt.color;
            obj.fontSize = opt.fontSize;
            obj.Position = opt.Position;
        end

        function insert(obj, hax, opt)
            arguments
                obj
                hax = gca
                opt.Position (1,2) double % [x_px, y_px]
            end

            if isa(hax,'matlab.ui.Figure')
                hax = hax.Children(1);
            elseif ~isa(hax,'matlab.graphics.axis.Axes')
                error('The hax input must be a figure or an Axes object')
            end

            switch obj.unit
                case 'px'
                    fac = 1;
                case 'µm'
                    fac = obj.pxSize*1e6;
            end

            him = findobj(hax.Children, 'Type', 'image');
            [Ny, ~] = size(him.CData);
            
            % Afficher le handle de l'image si elle existe
            if isempty(him)
                error('No Image object within the selected figure or Axes');
            end            

            if isfield(opt,'Position')
                obj.Position(1) = opt.Position(1);
                obj.Position(2) = opt.Position(2);
            end
            x0 = obj.Position(1)*Ny/100;
            y0 = obj.Position(2)*Ny/100;

            thick_px = Ny*obj.thickness/100;
            width_px = obj.value/obj.pxSize;

            if strcmp(hax.YDir,'reverse')
                y0 =  Ny-y0-thick_px;
            end


            rectangle(hax, 'Position', fac*[x0, y0, width_px, thick_px], ...
                   'FaceColor', obj.color, 'EdgeColor', 'k', 'LineWidth',1)

            displayedValue = [num2str(obj.value*1e6), ' µm'];

            text(hax, (x0 + width_px/2)*fac, y0*fac , displayedValue, 'Color', 'white', ...
                'FontSize', obj.fontSize, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');


        end

    end

    methods(Static)
        function remove(hax)
            % remove a Scale bar from a figure
            children = hax.Children;
            handle = findobj(children, 'Type', 'Text');
            delete(handle)
            handle = findobj(children, 'Type', 'Rectangle');
            delete(handle)
        end

    end


end

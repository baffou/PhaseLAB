classdef FcropParameters  %parameters of the crop in the Fourier plane
    
    properties
        x          double
        y          double
        R           double
        Nx          {mustBeInteger,mustBePositive}
        Ny          {mustBeInteger,mustBePositive}
        definition  char {mustBeMember(definition,{'high', 'low'})}    = 'high'
        FcropShape  char {mustBeMember(FcropShape,{'disc', 'square'})} = 'disc'
    end
    properties(Dependent)
        shiftx
        shifty
        angle
        zeta
    end
    
    methods
        
        function obj = FcropParameters(x,y,R,Nx,Ny,opt)
            arguments
                x = []
                y = []
                R = []
                Nx = []
                Ny = []
                opt.definition ='high'
                opt.FcropShape ='disc'
            end
            obj.Nx = Nx;
            obj.Ny = Ny;
            obj.x = x;
            obj.y = y;
            obj.R = R;
            obj.definition = opt.definition;
            obj.FcropShape = opt.FcropShape;
        end
        
        function obj = set.x(obj,x0)
            if ~isempty(x0)
                if x0 >= 0 && x0 <= obj.Nx
                    obj.x = x0;
                else
                    error(['wrong value for x, which equals ' num2str(x0) ' while Nx = ' num2str(obj.Nx) '.'])
                end
            end
        end
        
        function obj = set.y(obj,y0)
            if ~isempty(y0)
                if y0 >= 0 && y0 <= obj.Ny
                    obj.y = y0;
                else
                    error(['wrong value for y, which equals ' num2str(y0) ' while Nx = ' num2str(obj.Ny) '.'])
                end
            end
        end
        
        function val = get.shiftx(obj)
            val = round(obj.x - (obj.Nx/2+1));
        end
        
        function val = get.shifty(obj)
            val = round(obj.y - (obj.Ny/2+1));
        end
        
        function val = get.angle(obj)
            nshiftx = obj.shiftx/obj.Nx;
            nshifty = obj.shifty/obj.Ny;
            
            nshiftr = sqrt(nshiftx^2+nshifty^2);
            
            val.cos = nshiftx/nshiftr;
            val.sin = nshifty/nshiftr;
        end
        
        function obj2 = rotate90(obj)
            Nratio = obj.Ny/obj.Nx;
            x0 = obj.Nx/2+1;
            y0 = obj.Ny/2+1;
            dx = (obj.x-x0);
            dy = obj.y-y0;
            
            x0 = x0*Nratio;
            dx = dx*Nratio;
            
            x2 = x0-dy;
            y2 = y0+dx;
            
            x2 = x2/Nratio;
           
            obj2 = FcropParameters(x2, y2, obj.R, obj.Nx, obj.Ny, definition = obj.definition, FcropShape = obj.FcropShape);
        end
        
        function obj2 = rotate180(obj)
            x0 = obj.Nx/2 + 1;
            y0 = obj.Ny/2 + 1;
            dx = obj.x - x0;
            dy = obj.y - y0;
            
            x2 = x0 - dx;
            y2 = y0 - dy;
            
            obj2 = FcropParameters(x2, y2, obj.R, obj.Nx, obj.Ny, definition = obj.definition, FcropShape = obj.FcropShape);
        end

        function obj2 = zero2first(obj,theta)
            % compute the position of the first order from the data of the
            % 0 order, knowing the angle of the grating
            if obj.shiftx ~= 0 || obj.shifty ~= 0
                warning('This FcropParameters does not seem to be a zero order')
            end
            obj2 = obj;
            obj2.x = obj.x + 2*obj.R(1)*cosd(theta);
            obj2.y = obj.y + 2*obj.R(2)*sind(theta);
        end
        
        function val = get.zeta(obj)
            val=obj.Ny/sqrt( (obj.shiftx*obj.Ny/obj.Nx)^2 + (obj.shifty)^2 );

        end
    end
end

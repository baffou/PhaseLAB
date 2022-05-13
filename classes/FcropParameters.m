classdef FcropParameters  %parameters of the crop in the Fourier plane
    
    properties
        x          double
        y          double
        R           double
        Nx          {mustBeInteger,mustBePositive}
        Ny          {mustBeInteger,mustBePositive}
        resolution  char {mustBeMember(resolution,{'high', 'low'})}    = 'high'
        FcropShape  char {mustBeMember(FcropShape,{'disc', 'square'})} = 'disc'
    end
    properties(Dependent)
        shiftx
        shifty
        angle
    end
    
    methods
        
        function obj = FcropParameters(x,y,R,Nx,Ny,opt)
            arguments
                x = []
                y = []
                R = []
                Nx = []
                Ny = []
                opt.resolution ='high'
                opt.FcropShape ='disc'
            end
            obj.Nx = Nx;
            obj.Ny = Ny;
            obj.x = x;
            obj.y = y;
            obj.R = R;
            obj.resolution = opt.resolution;
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
           
            obj2 = FcropParameters(x2, y2, obj.R, obj.Nx, obj.Ny, resolution = obj.resolution, FcropShape = obj.FcropShape);
        end
        
        function obj2 = rotate180(obj)
            x0 = obj.Nx/2 + 1;
            y0 = obj.Ny/2 + 1;
            dx = obj.x - x0;
            dy = obj.y - y0;
            
            x2 = x0 - dx;
            y2 = y0 - dy;
            
            obj2 = FcropParameters(x2, y2, obj.R, obj.Nx, obj.Ny, resolution = obj.resolution, FcropShape = obj.FcropShape);
        end
        
    end
end

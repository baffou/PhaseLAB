classdef IFDDAsphere < IFDDAobject
    properties
        %        name
        %        pxSize
        %        x0
        %        y0
        %        z0
        %        n
        %        eps
    end
    properties(Dependent)
        radius
        diameter
        nxm
        nym
        nzm
    end

    properties(Hidden, Access=private)
        radius0
    end
    properties(Hidden,Dependent)
        dim (1,10) double;
    end

    methods
        function obj = IFDDAsphere(opt)
            arguments
                opt.radius double = [] % radius of the sphere
                opt.diameter double = [] % diameter of the sphere
                opt.pxSize  double = 65e-9 % lattice parameter of the mesh
                opt.n  double = [] % RI of the object
                opt.eps double = [] % permittivity of the object
                opt.z double = [] % shift in z. equals minus the radius if let empty
            end
            obj.name='sphere';
            obj.pxSize=opt.pxSize;

            if ~isempty(opt.n) && isempty(opt.eps)
                obj.n0=opt.n;
            elseif ~isempty(opt.eps)
                obj.n0=sqrt(opt.eps);
            else
                warnin('RI of the object arbitrarily set to 1.5.')
                obj.n0=1.5;
            end

            if ~isempty(opt.radius) && isempty(opt.diameter)
                obj.radius0=opt.radius;
            elseif ~isempty(opt.diameter)
                obj.radius0=opt.diameter/2;
            else
                warnin('Diameter of the sphere arbitrarily set to 100 nm.')
                obj.radius0=50e-9;
            end
            if isempty(opt.z)
                obj.z0 = -obj.radius; % Make sure it is lying on the surface
            else
                obj.z0 = opt.z;
            end
        end

    end
    methods(Access=protected)
        function propgrp = getPropertyGroups(~)
            propList={'name','radius','diameter','pxSize','n','z0'};
            propgrp=matlab.mixin.util.PropertyGroup(propList);
        end
    end

end


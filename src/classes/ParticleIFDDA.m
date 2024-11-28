classdef ParticleIFDDA < handle & matlab.mixin.Copyable & matlab.mixin.CustomDisplay
    properties(GetAccess = public, SetAccess=private)
        geom (1,:) char = 'arbitrary'
        fileName (1,:) char = 'none' % in case geom=='arbitrary'
    end
    properties
        pxSize % lattice parameter
        x0 (1,1) double = 0 % x position of the center of the object
        y0 (1,1) double = 0 % y position of the center of the object
        z0 (1,1) double = 0 % z position of the center of the object
    end
    properties(Dependent)
        radius
        diameter
        height
        size
        sizeX
        sizeY
        sizeZ
        nxm
        nym
        nzm
    end

    properties(Hidden)
        dim0  % for isotropic object, diameter of the sphere or side of the cube
        dimX  % for anisotropic object, size of an ellipsoid or cuboid along x
        dimY  % for anisotropic object, size of an ellipsoid or cuboid along y
        dimZ  % for anisotropic object, size of an ellipsoid or cuboid along z
    end
    properties(Hidden,Dependent)
        dim (1,3) double;
    end
    properties(Dependent)
        n
        eps
    end
    properties(Hidden, Access=protected)
        n0
    end

    methods

        function obj = ParticleIFDDA(geom,MI,opt)
            
            switch geom
                case 'nanoparticle'
                    bin = 6;
                    epsNP = epsRead(IL.lambda,'Au');
                    obj = IFDDAobject('sphere', "size",200e-9, "pxSize", MI.pxSize/bin, "eps",epsNP);
                    obj.moveTo("x",MI.pxSize*0.25,"y",MI.pxSize*0.25)
                case 'microbead'
                    bin = 1;
                    epsNP=1.51;
                    obj = IFDDAobject('sphere',"size",2000e-9,"pxSize",MI.pxSize/bin,"eps",epsNP);
                case 'bacteria'
                    bin=1;
                    n_obj=1.38;
                    IF.meshes.rodGenerator("L",2e-6,"D",0.5e-6,"pxSize",MI.pxSize/bin,"fileName",'rod.dat',n=n_obj)
                    obj = IFDDAobject('arbitrary',fileName='rod.dat',n=n_obj);
                case 'cell'
                    OB = Objective(100,1.3,'Olympus');
                    MI = Microscope(OB,180,CGcam);
                    MI.zo = opt.focus;
                    bin = 1;
                    n_obj = 1.4;
                    folderName = '/home/gb/Documents/if-dda-m/simus/230210_QPIcomparison';
                    IF.meshes.meshFromImage(dlmread('cellTopo.txt'),MI.pxSize,Zresize=1.4,nCell=n_obj,folder=folderName)
                    obj = IFDDAobject('arbitrary',fileName='cell3D.txt',n=n_obj);
                    %nrig=5;
                case 'graphene'
                    OB = Objective(60,1.3,'Olympus');
                    MI = Microscope(OB,180,CGcam);
                    bin = 1;
                    n_obj = 1.5;
                    IF.meshes.grapheneGenerator("shape","disc","D",4e-6,"nz",60, ...
                        "pxSize",MI.pxSize/bin,"fileName",'graphene.dat',n=n_obj)
                    obj = IFDDAobject('arbitrary',fileName='graphene.dat',n=n_obj);
            end
        end

        function obj = objGeneration(geom,opt)
            arguments
                geom (1,:) char {mustBeMember(geom,{ ...
                    'sphere', ...
                    'cube', ...
                    'cuboid', ...
                    'ellipsoid', ...
                    'spheroid', ...
                    'cylinder', ...
                    'arbitrary'})}
                opt.radius double = [] % radius of the sphere
                opt.diameter double = [] % diameter of the sphere
                opt.size double = [] % side of a square
                opt.height double = [] % height of the cylinder
                opt.pxSize  double = 65e-9 % lattice parameter of the mesh
                opt.n  double = [] % RI of the object
                opt.eps double = [] % permittivity of the object
                opt.z double = [] % shift in z. equals minus the radius if let empty
                opt.fileName char
            end

            obj.pxSize=opt.pxSize;

            if ~isempty(opt.n) && isempty(opt.eps)
                obj.n0=opt.n;
            elseif ~isempty(opt.eps)
                obj.n0=sqrt(opt.eps);
            else
                warning('RI of the object arbitrarily set to 1.5.')
                obj.n0=1.5;
            end
            if strcmp(geom,'spheroid')
                geom='ellipsoid';
            end

            obj.geom=geom;
            if strcmp(geom,'sphere')
                if ~isempty(opt.radius) && isempty(opt.diameter) && isempty(opt.size)
                    obj.dim0=2*opt.radius;
                elseif ~isempty(opt.diameter) && isempty(opt.size)
                    obj.dim0=opt.diameter;
                elseif ~isempty(opt.size)
                    if numel(opt.size)~=1
                        error('The size argument must be a scalar')
                    end
                    obj.dim0=opt.size;
                else
                    warning('Diameter of the sphere arbitrarily set to 100 nm.')
                    obj.dim0=100e-9;
                end
            elseif strcmp(geom,'cube')
                if ~isempty(opt.size)
                    if numel(opt.size)>1
                        error('The size argument must be a scalar')
                    end
                    obj.dim0=opt.size;
                else
                    warning('Side of the cube arbitrarily set to 100 nm.')
                    obj.dim0=100e-9;
                end
            elseif ismember(geom,{'ellipsoid','cuboid'}) 
                if ~isempty(opt.size)
                    obj.dimX=opt.size(1);
                    obj.dimY=opt.size(2);
                    obj.dimZ=opt.size(3);
                else
                    warning(['The ' geom ' has been considered as a ' geom(1:end-2) 'e of 100 nm in size.'])
                    obj.dim0=100e-9;
                end
            elseif strcmp(geom,'cylinder')
                if ~isempty(opt.radius) && isempty(opt.diameter) && isempty(opt.size)
                    obj.dim0=2*opt.radius;
                    obj.dimX=2*opt.radius;
                    obj.dimY=2*opt.radius;
                elseif ~isempty(opt.diameter) && isempty(opt.size)
                    obj.dim0=opt.diameter;
                    obj.dimX=opt.diameter;
                    obj.dimY=opt.diameter;
                elseif ~isempty(opt.size)
                    if numel(opt.size)~=1
                        error('The size argument must be a scalar')
                    end
                    obj.dim0=opt.size;
                    obj.dimX=opt.size;
                    obj.dimY=opt.size;
                else
                    warning('Diameter of the cylinder arbitrarily set to 100 nm.')
                    obj.dim0=100e-9;
                    obj.dimX=100e-9;
                    obj.dimY=100e-9;
                end
                if ~isempty(opt.height)
                    obj.dimZ=opt.height;
                else
                    warning('Height of the cylinder arbitrarily set to 100 nm.')
                    obj.dimZ=100e-9;
                end
            elseif strcmp(geom,'arbitrary')
                obj.fileName=opt.fileName;
            end
            if ~strcmp(geom,'arbitrary')
                if isempty(opt.z)
                    if isempty(obj.dimZ) % isotropic object
                        obj.z0 = -obj.dim0/2; % Make sure it is lying on the surface
                    else
                        obj.z0 = -obj.dimZ/2; % Make sure it is lying on the surface
                    end
                else
                    obj.z0 = opt.z;
                end
            end
        end

        function set.radius(obj,val)
            if ismember(obj.geom,{'sphere','cylinder'})
                obj.dim0=val*2;
            else
                error(['You cannot set the radius of a ' obj.geom '.'])
            end
        end
        function val = get.radius(obj)
            if ismember(obj.geom,{'sphere','cylinder'})
                val = obj.dim0/2;
            else
                warning(['you are trying to get the radius of a ' obj.geom])
                val = [];
            end
        end

        function set.diameter(obj,val)
            if ismember(obj.geom,{'sphere','cylinder'})
                obj.dim0=val;
            else
                error(['You cannot set the diameter of a ' obj.geom '.'])
            end
        end

        function val = get.diameter(obj)
            if ismember(obj.geom,{'sphere','cylinder'})
                val = obj.dim0;
            else
                warning(['you are trying to get the diameter of a ' obj.geom])
                val = [];
            end
        end
        
        function val = get.height(obj)
            val = obj.dimZ;
        end
        function set.size(obj,val)
            if ismember(obj.geom,{'sphere','cube'})
                obj.dim0=val;
            else
                error('The size property is only for isotropic objects, ie cubes and spheres')
            end                
        end
        function val = get.size(obj)
            if ~isempty(obj.dim0)
                val=obj.dim0;
            else
                val=obj.dim;
            end
        end
        function set.sizeX(obj,val)
            obj.dimX=val;
        end
        function val = get.sizeX(obj)
            val=obj.dimX;
        end
        function set.sizeY(obj,val)
            obj.dimY=val;
        end
        function val = get.sizeY(obj)
            val=obj.dimY;
        end
        function set.sizeZ(obj,val)
            obj.dimZ=val;
        end
        function val = get.sizeZ(obj)
            val=obj.dimZ;
        end

        function val = get.pxSize(obj)
            if strcmp(obj.geom,'arbitrary')
                hf=fopen(obj.fileName);
                numList=fscanf(hf,'%d');
                val=numList(4)*1e-9;
                fclose(hf);
            else
                val=obj.pxSize;
            end
        end
        function val = get.nxm(obj)
            if strcmp(obj.geom,'arbitrary')
                hf=fopen(obj.fileName);
                numList=fscanf(hf,'%d');
                val=numList(1);
                fclose(hf);
            else
                val=max( [ ceil(obj.dim(:)/obj.pxSize);ceil(obj.dim0/obj.pxSize) ]);
            end
        end
        function val = get.nym(obj)
            if strcmp(obj.geom,'arbitrary')
                hf=fopen(obj.fileName);
                numList=fscanf(hf,'%d');
                val=numList(2);
                fclose(hf);
            else
                %val=max( [ ceil(obj.dimY/obj.pxSize),ceil(obj.dim0/obj.pxSize) ])+48;
                val=max( [ ceil(obj.dim(:)/obj.pxSize);ceil(obj.dim0/obj.pxSize) ]);
            end
        end
        function val = get.nzm(obj)
            if strcmp(obj.geom,'arbitrary')
                hf=fopen(obj.fileName);
                numList=fscanf(hf,'%d');
                val=numList(3);
                fclose(hf);
            else
                val=max( [ ceil(obj.dim(:)/obj.pxSize);ceil(obj.dim0/obj.pxSize) ]);
                if ismember(obj.geom,{'cylinder','ellipsoid','cuboid'})
%                    val=ceil(obj.dimZ/obj.pxSize)+45;
                else % isotropic object
%                    val=ceil(obj.dim0/obj.pxSize);
                end
            end
        end

        function val = get.dim(obj)
            val=zeros(1,3);
            if ismember(obj.geom,{'sphere','cube'})
                val(1)=obj.dim0;
            else
                if ~isempty(obj.dimX)
                    val(1)=obj.dimX;
                end
                if ~isempty(obj.dimY)
                    val(2)=obj.dimY;
                end
                if ~isempty(obj.dimZ)
                    val(3)=obj.dimZ;
                end
            end
        end


        function set.n(obj,val)
            obj.n0=val;
        end
        function val = get.n(obj)
            val = obj.n0;
        end
        function set.eps(obj,val)
            obj.n0=sqrt(val);
        end
        function val = get.eps(obj)
            val = obj.n0*2;
        end

        function obj = moveTo(obj,opt)
            arguments
                obj
                opt.x (1,1) double = 0
                opt.y (1,1) double = 0
                opt.z (1,1) double = 0
            end

            obj.x0 = opt.x;
            obj.y0 = opt.y;
            obj.z0 = opt.z;

        end

        function obj = moveBy(obj,opt)
            arguments
                obj
                opt.x (1,1) double = 0
                opt.y (1,1) double = 0
                opt.z (1,1) double = 0
            end

            obj.x0 = obj.x0 + opt.x;
            obj.y0 = obj.y0 + opt.y;
            obj.z0 = obj.z0 + opt.z;

        end

        function obj = imaging(MI, IL)
            %% generation of the parameter file to be imported by the Fortran code
            
            if strcmp(illumination,'linear')
                beam="pwavelinear";
                theta0=0;
                Nphi=1;
            elseif strcmp(illumination,'circular')
                beam="pwavecircular";
                theta0=0;
                Nphi=1; 
            elseif strcmp(illumination,'ring')
                beam="pwavecircular";
                theta0=15;
                Nphi=24;
            end
            nrig = 0;
            IF.generateIFDDAparameters(IL.lambda,MI,IL.Medium,Obj,h5fileName=h5fileName, ...
                Npx=MI.CGcam.Camera.Ny,beam=beam,theta=theta0,nmaxloop=Nphi,nlecture=0,nrig=nrig)
            
            %% run the Fortran code that computes the Efied and save in the hdf5 file
            [~,cmdout]=system('./comp');
            if contains(cmdout,'Error')
                fprintf(cmdout)
                return
            end
            system('./ifdda_importParameters')
            
            %% import the hdf5 file
            h5fileName = geom + ".h5";
            
            IM0 = IF.import_h5(h5fileName);
            No=numel(IM0);
            
            %% binning
            obj=ImageEM(No);
            for io=1:No
                IM0(io).Microscope=MI;
                obj(io)=IM0(io).binning(bin);
            end

    end    
    
    
    
    end

    methods(Access=protected)
        function propgrp = getPropertyGroups(obj)
            if strcmp(obj.geom,'sphere')
                propList={'name','diameter','pxSize','n','z0'};
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            elseif strcmp(obj.geom,'cube')
                propList={'name','size','pxSize','n','z0'};
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            elseif ismember(obj.geom,{'cuboid','ellipsoid'})
                propList={'name','sizeX','sizeY','sizeZ','pxSize','n','z0'};
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            elseif strcmp(obj.geom,'cylinder')
                propList={'name','diameter','height','pxSize','n','z0'};
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            elseif strcmp(obj.geom,'arbitrary')
                propList={'name','filename','pxSize','n','nxm','nym','nzm'};
                propgrp=matlab.mixin.util.PropertyGroup(propList);
            end
        end
    end


end


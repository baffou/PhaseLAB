function IM0b = waveComputation(object,illumination,lambda,opt)
% generate the theoretical wave, from the knowledge of the illumination and
% object.

arguments
    object char {mustBeMember(object,{'NP','graphene','microbead','bacteria','cell','Gaussian','blank','none'})}
    illumination  char {mustBeMember(illumination,{'linear','circular','ring','disc','4-quadrants'})}
    lambda
    opt.focus (1,1) double = 0
    opt.NAill = 0
    opt.Ntheta = 5  % Used only for a disc illumination. odd number: naturally places a source at (0, 0)
    opt.theta0 = 0  % incidence angle. Used only for a circular or linear plane wave illmuination
    opt.NAobj = 1.3;
end


%% creation of the system
NAobj = opt.NAobj;
ME=Medium(1.33,1.5);
IL=Illumination(lambda,ME);
OB=Objective(100,NAobj,'Olympus');
CG=CrossGrating('Gamma',39e-6,'lambda0',IL.lambda);
Cam=Camera(6.5e-6,1024,1024);
CGcam=CGcamera(Cam,CG,1);
MI=Microscope(OB,180,CGcam);
%MI.CGcam.setDistance(0.86e-3);
MI.zo=0e-6;

%object='NP';
%object='microbead';
%object='bacteria';
%object='graphene';

h5fileName = object + ".h5";

nrig=0;
switch object
    case 'NP'
        ME=Medium(1.5,1.5);
        IL=Illumination(lambda,ME);
        bin=6;
        NPdiam = 100e-9;
        epsNP=epsRead(IL.lambda,'Au');
        Obj=IFDDAobject('sphere', "size",NPdiam, "pxSize", MI.pxSize/bin, "eps",epsNP);
        Obj.moveBy("x",MI.pxSize*0.25,"y",MI.pxSize*0.25,"z",1.0*NPdiam)
        Npx=2048;
    case 'microbead'
        bin=1;
        epsNP=1.51;
        Obj=IFDDAobject('sphere',"size",2000e-9,"pxSize",MI.pxSize/bin,"eps",epsNP);
        Npx=2048;
    case 'bacteria'
        bin=1;
        n_obj=1.38;
        IF.meshes.rodGenerator("L",2e-6,"D",0.5e-6,"pxSize",MI.pxSize/bin,"fileName",'rod.dat','n',n_obj)
        Obj=IFDDAobject('arbitrary','fileName','rod.dat','n',n_obj);
        Npx=1024;
    case 'cell'
        OB=Objective(60,NAobj,'Olympus');
        MI=Microscope(OB,180,CGcam);
        bin=1;
        n_obj=1.38;
        folderName = '/home/baffou/Documents/_SIMUS_ifddam/230210_QPIcomparison';
        IF.meshes.meshFromImage(readmatrix('cellTopo.txt'),MI.pxSize,'Zresize',1.4,'nCell',n_obj,'folder',folderName)
        Obj=IFDDAobject('arbitrary','fileName','cell3D.txt','n',n_obj);
        Npx=512;
        %nrig=5;
    case 'cell2' % image of the cell computed from the T and OPD images: EE=sqrt(T).*exp(1i*2*pi*OPD/lambda)
        T=readmatrix("dataCell/T_V4_1219.txt");
        OPD=readmatrix("dataCell/OPD_V4_1219.txt");
        EE=sqrt(T).*exp(1i*2*pi/lambda*OPD);
        Ex=EE*(illumination=="circular");
        Ey=EE;
        Ez=EE*0;
        Eincx=EE*0+(illumination=="circular");
        Eincy=EE*0+1;
        Eincz=EE*0;
        IM0b=ImageEM(Ex,Ey,Ez,Eincx,Eincy,Eincz,"Microscope",MI,'Illumination',IL);
        return
    case 'graphene'
        bin=1;
        reduc=1200;
        n_obj=(epsRead(IL.lambda,'graphene')-1.33)/reduc+1.33;
        diameter = 8e-6;
        shape = "square";
        IF.meshes.grapheneGenerator("shape",shape,"D",diameter,"nz",3, ...
            "pxSize",MI.pxSize/bin,"fileName",'graphene.dat','n',n_obj)
        Obj=IFDDAobject('arbitrary','fileName','graphene.dat','n',n_obj);
        Npx=1024;
    case {'blank','none'}
        bin=1;
        diameter = 8e-6;
        shape = "square";
        % calculate anything, one does not mind:
        IF.meshes.grapheneGenerator("shape",shape,"D",diameter,"nz",3, ...
            "pxSize",MI.pxSize/bin,"fileName",'graphene.dat','n',1.33)
        Obj=IFDDAobject('arbitrary','fileName','graphene.dat','n',1.33);
        Npx=512;
    case 'Gaussian'
        bin=1;
        diameter = 8e-6;
        shape = "square";
        % calculate anything, one does not mind:
        IF.meshes.grapheneGenerator("shape",shape,"D",diameter,"nz",3, ...
            "pxSize",MI.pxSize/bin,"fileName",'graphene.dat','n',1.33)
        Obj=IFDDAobject('arbitrary','fileName','graphene.dat','n',1.33);
        Npx=512;
end
%% Definition of the parameters of the illumination
switch illumination
    case 'linear'
        beam="pwavelinear";
        theta0=opt.theta0;
        Nphi=1;
    case 'circular'
        beam="pwavecircular";
        theta0=opt.theta0;
        Nphi=1;
    case 'ring'
        beam="pwavecircular";
        theta0=asind(opt.NAill);
        Nphi=12;
    case 'disc'
        beam="pwavecircular";
    case '4-quadrants'
        beam="pwavecircular";
end


%% running the IFDDA code

MI.zo=opt.focus;


switch illumination
    case {'linear','circular','ring'}
    
        % generation of the parameter file to be imported by the Fortran code
        IF.generateIFDDAparameters(IL.lambda,MI,ME,Obj,'h5fileName',h5fileName, ...
            'Npx',Npx,'beam',beam,'theta',theta0,'nmaxloop',Nphi,'nlecture',0,'nrig',nrig)
        
        % run the Fortran code that computes the Efied and save in the hdf5 file
        [~,cmdout]=system('./comp');
        if ~isempty(cmdout)
            error([' compilation of comp:' cmdout])
            
        end
        system('./ifdda_importParameters')
        
        % import the hdf5 file
        
        IM0 = IF.import_h5(h5fileName);
    case 'disc'
        [~, ~, NAlist, phiList]=generateDiscArray(opt.NAill,opt.Ntheta);
        thetaList = asind(NAlist);
        %thetaList=0;
        %phiList=0;
        Nsources = numel(NAlist);
        IM0=ImageEM(Nsources);
        for is = 1:Nsources
    
            % generation of the parameter file to be imported by the Fortran code
            IF.generateIFDDAparameters(IL.lambda,MI,ME,Obj,'h5fileName',h5fileName, ...
                'Npx',Npx,'beam',beam,'theta',thetaList(is),'phi',phiList(is),'nmaxloop',1,'nlecture',0,'nrig',nrig)
            
            % run the Fortran code that computes the Efied and save in the hdf5 file
            [~,cmdout]=system('./comp');
            if ~isempty(cmdout)
                error([' compilation of comp:' cmdout])
                
            end
            system('./ifdda_importParameters')
            
            % import the hdf5 file
            
            IM0(is) = IF.import_h5(h5fileName);

        end
    case '4-quadrants'
        MI.Objective = Objective(MI.Objective.Mobj, NAobj, MI.Objective.objBrand);
        NAill = opt.NAill/ME.n; % because this is what IFDDA considers as the illumination
        [~, ~, NAlist{1}, phiList{1}] = generateDiscArray(NAill,opt.Ntheta,"quadrant",'topLeft');
        [~, ~, NAlist{2}, phiList{2}] = generateDiscArray(NAill,opt.Ntheta,"quadrant",'topRight');
        [~, ~, NAlist{3}, phiList{3}] = generateDiscArray(NAill,opt.Ntheta,"quadrant",'bottomRight');
        [~, ~, NAlist{4}, phiList{4}] = generateDiscArray(NAill,opt.Ntheta,"quadrant",'bottomLeft');
        thetaList{1} = asind(NAlist{1});
        thetaList{2} = asind(NAlist{2});
        thetaList{3} = asind(NAlist{3});
        thetaList{4} = asind(NAlist{4});

        Nsources = numel(NAlist{1});
        IM0 = repmat(ImageEM(n=Nsources),1,4);
        for ii = 1:4
            thetaList0 = thetaList{ii};
            phiList0 = phiList{ii};
            for is = 1:Nsources
        
                % generation of the parameter file to be imported by the Fortran code
                IF.generateIFDDAparameters(IL.lambda,MI,ME,Obj,'h5fileName',h5fileName, ...
                    'Npx',Npx,'beam',beam,'theta',thetaList0(is),'phi',phiList0(is),'nmaxloop',1,'nlecture',0,'nrig',nrig)
                
                % run the Fortran code that computes the Efied and save in the hdf5 file
                [~,cmdout]=system('./comp');
                if ~isempty(cmdout)
                    error([' compilation of comp:' cmdout])
                end
                system('./ifdda_importParameters')
                
                % import the hdf5 file
                IM0(is,ii) = IF.import_h5(h5fileName);
            end
        end
end
No=numel(IM0);

%% binning
IM0b=ImageEM(No);
for io=1:No
    IM0b(io)=IM0(io).binning(bin);
    IM0b(io).Microscope.CGcam.CG=MI.CGcam.CG;
    IM0b(io).Microscope.CGcam.RL=MI.CGcam.RL;
end


if object=="blank"
    IM0b(io)=ImageEM(IM0b(io).Einc.Ex,IM0b(io).Einc.Ey,IM0b(io).Einc.Ez,IM0b(io).Einc.Ex,IM0b(io).Einc.Ey,IM0b(io).Einc.Ez,'Illumination',IL,'Microscope',MI);
end

if object == "Gaussian"
    [XX0, YY0] = meshgrid(1:IM0b(io).Nx,1:IM0b(io).Ny);
    XX=XX0-IM0b(io).Nx/2-1;
    YY=YY0-IM0b(io).Ny/2-1;
    ampl=100e-9; %[nm]
    sigma0 = 50; %[px]
    OPD = ampl*exp(-(XX.*XX+YY.*YY)/(2*sigma0^2));
    Efield = exp(1i*2*pi/lambda*OPD);
    IM0b(io) = ImageEM(Efield*0,Efield,Efield*0,Efield*0,Efield*0+1,Efield*0,"Illumination",IL,"Microscope",MI);
end
    
IM0b = reshape(IM0b, size(IM0));





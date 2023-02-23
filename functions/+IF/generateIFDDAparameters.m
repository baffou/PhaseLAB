function generateIFDDAparameters(lambda,MI,ME,Obj,opt)
arguments
    lambda double
    MI Microscope
    ME Medium
    Obj IFDDAobject
    opt.Npx = 512
    opt.nphi (1,1) uint16 = 144
    opt.ntheta (1,1) uint16 = 72
    opt.beam (1,:) char {mustBeMember(opt.beam,{...
        'pwavecircular','gwavelinear','gwavecircular','pwavelinear',...
        'pwavecircular','wavelinearmulti','gwaveiso','speckle','arbitrary'})}  ='pwavecircular'
    opt.theta (1,1) double = 0
    opt.nmaxloop (1,1) double = 1
    opt.pp (1,1) double = 0
    opt.ss (1,1) double = 1
    opt.object (1,:) char {mustBeMember(opt.object,{...
        'sphere','inhomosphere','cube','cuboid1','cuboid2','inhomocuboid1',...
        'inhomocuboid2','ellipsoid','nspheres','cylinder','concentricsphere',...
        'arbitrary'})}  = 'sphere'
    opt.objFileName (1,:) char = ['none']
    opt.nObj (1,1) double = 1.38
    opt.nlecture logical = 0
    opt.h5fileName (1,:) char = 'data.h5'
    opt.nrig (1,1) double = 0 % or 7
end

if strcmp(opt.object,'arbitrary') && strcmp(opt.objFileName,'none')
    error('A mesh file name (objFileName argument) must beam specified when selecting an arbitrary object')
end

hf=fopen('paramList.txt','w');

%nxm=63,nym=63,nzm=3,nphi=144,ntheta=72)

fprintf(hf,'%u\n',opt.Npx);  %=512       %nfft2d
fprintf(hf,'%u\n',Obj.nxm);  %=632.8d0       %wavelength
fprintf(hf,'%u\n',Obj.nym);  %=632.8d0       %wavelength
fprintf(hf,'%u\n',Obj.nzm);  %=632.8d0       %wavelength
fprintf(hf,'%u\n',opt.nmaxloop); % nombre de sources sur l'anneau
fprintf(hf,'%u\n',opt.nphi);  %=632.8d0       %wavelength
fprintf(hf,'%u\n',opt.ntheta);  %=632.8d0       %wavelength
fprintf(hf,'%f\n',lambda*1e9);  %=632.8d0       %wavelength
fprintf(hf,'%s\n',opt.beam);   %='pwavecircular'    %Circular plane wave
fprintf(hf,'%f\n',opt.theta);
fprintf(hf,'%f\n',opt.pp);
fprintf(hf,'%f\n',opt.ss);
fprintf(hf,'%s\n',Obj.name); %='arbitrary' %Arbitrary object
fprintf(hf,'%s\n',Obj.fileName);  % ='graphene_Disc4.dat'
fprintf(hf,'%f\n',Obj.n);  % refractive index of the material
fprintf(hf,'%f\n',Obj.pxSize*1e9);  % =65e-9
fprintf(hf,'%f\n',ME.n);  %=1.33d0
fprintf(hf,'%f\n',ME.nS);  %=1.5d0
fprintf(hf,'%u\n',MI.zo*1e9);  %=0 (focus)
fprintf(hf,'%u\n',opt.nlecture);  %=0
fprintf(hf,'%f\n',MI.NA);   %= 1.3d0
fprintf(hf,'%f\n',abs(MI.M));        %=100.d0
fprintf(hf,'%s\n',opt.h5fileName);  % output hdf5 file name ='SLIM_graphene.h5'
fprintf(hf,'%f\n',Obj.x0*1e9);  % output hdf5 file name ='SLIM_graphene.h5'
fprintf(hf,'%f\n',Obj.y0*1e9);  % output hdf5 file name ='SLIM_graphene.h5'
fprintf(hf,'%f\n',Obj.z0*1e9);  % output hdf5 file name ='SLIM_graphene.h5'
fprintf(hf,'%f\n',Obj.dim(1)*1e9);  % output hdf5 file name ='SLIM_graphene.h5'
fprintf(hf,'%f\n',Obj.dim(2)*1e9);  % output hdf5 file name ='SLIM_graphene.h5'
fprintf(hf,'%f\n',Obj.dim(3)*1e9);  % output hdf5 file name ='SLIM_graphene.h5'
fprintf(hf,'%u\n',opt.nrig);  % computation method (0: rigourous, 7: approxim.)



fclose(hf);
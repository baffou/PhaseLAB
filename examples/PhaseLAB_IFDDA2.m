clc
addpath(genpath('/home/gb/Documents/MATLAB/PhaseLAB_Git/'))

%% creation of the system
h5fileName="sphere.h5";

% wavelength:
lambda=632e-9;
% milieu
ME=Medium(1.33,1.5); 
% Microscope:
MI=Microscope(Objective(100,1.3));
MI.zo=0e-6;

%object='cuboid';
%object='bacteria';
object='graphene';

switch object
    case 'cuboid'
        Obj=IFDDAobject('cuboid',"size",[2000 100 200]*1e-9,"pxSize",40e-9,"n",1.5);
    case 'bacteria'
        IF.meshes.rodGenerator("L",4e-6,"D",0.5e-6,"pxSize",40e-9,"fileName",'rod.dat')
        Obj=IFDDAobject('arbitrary',fileName='rod.dat');
    case 'graphene'
        IF.meshes.grapheneGenerator("shape","disc","D",4e-6,"nz",3,"pxSize",40e-9,"fileName",'graphene.dat')
        Obj=IFDDAobject('arbitrary',fileName='graphene.dat');
end
%% generation of the parameter file to be imported by the Fortran code
generateIFDDAparameters(lambda,MI,ME,Obj,h5fileName=h5fileName, ...
    Npx=1024,beam="pwavecircular",theta=0)

%% run the Fortran code
[~,cmdout]=system('./comp');
if contains(cmdout,'Error')
    fprintf(cmdout)
    return
end
system('./main230208_importParams')

%% import the results of the simulation

namefileh5 = 'sphere.h5';
IM0 = IF.import_h5(namefileh5);
IM0.figure

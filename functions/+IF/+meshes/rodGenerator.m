function rodGenerator(opt)
arguments
    opt.pxSize (1,1) double = 65e-9 % size of the mesh unit cell
    opt.R (1,1) double = 250e-9 % radius of the rod
    opt.D double                % diameter of the rod
    opt.L (1,1) double = 2000e-9% length of the rod
    opt.n = 1.38
    opt.eps = []
    opt.n0 double =1.33
    opt.eps0 double = []
    opt.fileName char = "rod.dat"    
end
% Rrod=250e-9;
% Hrod=1500e-9;
if ~isempty(opt.D) % if a diameter is specified
    opt.R = opt.D/2;
end
Rrod=opt.R;
Lrod=opt.L;

fileName=opt.fileName;

pxSize=opt.pxSize;

if ~isempty(opt.eps)
    eps= opt.eps;
else
    eps= opt.n^2;
end

if ~isempty(opt.eps0)
    eps0= opt.eps0;
else
    eps0= opt.n0^2;
end

Lrod=(Lrod -2*Rrod)/2; % half length of the cylinder


nx=ceil(Lrod/(2*pxSize));
ny=ceil(Rrod/pxSize);
nz=floor(Rrod/pxSize);
fprintf('Ncells=%d\n',(2*nx+1)*(2*ny+1)*(2*nz+1))
if exist("fileName","file")
    delete fileName
end
hf=fopen(fileName,'w');
fprintf(hf,'%d %d %d\n',2*nx+1,2*ny+1,2*nz+1);
fprintf(hf,'%d\n',pxSize*1e9);

zshift = -Rrod-pxSize/2;
%figure
%hold on
for z=-nz:nz
    for y=-ny:ny
        for x=-nx:nx
            fprintf(hf,'%f %f %f\n',x*pxSize*1e9,y*pxSize*1e9,z*pxSize*1e9+zshift*1e9);
        end
    end
end
nCell=0;
for z=-nz:nz
    for y=-ny:ny
        for x=-nx:nx
            if y*y + z*z <= Rrod*Rrod/(pxSize*pxSize)
                if abs(x) <= Lrod/pxSize ...
                        || (x-Lrod/pxSize)*(x-Lrod/pxSize) + y*y + z*z <= Rrod*Rrod/(pxSize*pxSize) ...
                        || (x+Lrod/pxSize)*(x+Lrod/pxSize) + y*y + z*z <= Rrod*Rrod/(pxSize*pxSize) 
                    fprintf(hf,'(%f, %f) \n',real(eps),imag(eps));
                    nCell=nCell+1;
                else
                    fprintf(hf,'(%f, %f) \n',real(eps0),imag(eps0));
                end
            else
                fprintf(hf,'(%f, %f) \n',real(eps0),imag(eps0));
            end
        end
    end
end
fclose(hf);

fprintf('cell count: %d\n',nCell)

fprintf('cell optical volume: %d\n',nCell*pxSize^3*(sqrt(eps)-sqrt(eps0)))

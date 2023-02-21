function grapheneGenerator(opt)
arguments
    opt.da double = 65e-9
    opt.C double = [] % side of the square
    opt.R double = 2e-6 % radius of the disc
    opt.D double = [] % diameter of the disc
    opt.nz double = 3 % thickness of the layer in cells
    opt.shape {mustBeMember(opt.shape,{'disc','square'})} = 'disc'
    opt.n = 1.38
    opt.eps = []
    opt.n0 double =1.33
    opt.eps0 double = []
    opt.fileName
end

fileName=opt.fileName;

da=opt.da;

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

nz=opt.nz;

if strcmp(opt.shape,'disc')

    if ~isempty(opt.D)
        R=opt.D/2;
    else
        R=opt.R;
    end


    nx=ceil(R/da);
    ny=ceil(R/da);

    if exist('fileName','file')
        delete fileName
    end

    hf=fopen(fileName,'w');
    fprintf(hf,'%d %d %d\n',2*nx+1,2*ny+1,nz);
    fprintf(hf,'%d\n',da*1e9);

    zshift = -da/2;
    %figure
    %hold on
    for z=0:nz-1
        for y=-ny:ny
            for x=-nx:nx
                fprintf(hf,'%f %f %f\n',x*da*1e9,y*da*1e9,-z*da*1e9+zshift*1e9);
            end
        end
    end

    nCell=0;
    for z=0:nz-1
        for y=-ny:ny
            for x=-nx:nx
                if y*y + x*x <= R*R/(da*da)
                    nCell=nCell+1;
                    fprintf(hf,'(%f, 0) \n',eps);
                else
                    fprintf(hf,'(%f, 0) \n',eps0);
                end
            end
        end
    end

    fprintf('Ncell=%d\n',nCell)
    fprintf('OV=%d\n',nCell*da^3*(sqrt(eps)-sqrt(eps0)))
    fclose(hf);

else

    nx=ceil(opt.C/(2*da));
    ny=ceil(opt.C/(2*da));

    if exist('fileName','file')
        delete fileName
    end

    hf=fopen(fileName,'w');
    fprintf(hf,'%d %d %d\n',2*nx+1,2*ny+1,nz);
    fprintf(hf,'%d\n',da*1e9);

    zshift = -da/2;
    %figure
    %hold on
    for z=0:nz-1
        for y=-ny:ny
            for x=-nx:nx
                fprintf(hf,'%f %f %f\n',x*da*1e9,y*da*1e9,-z*da*1e9+zshift*1e9);
            end
        end
    end


    nCell=0;
    for z=0:nz-1
        for y=-ny:ny
            for x=-nx:nx
                nCell=nCell+1;
                fprintf(hf,'(%f, 0) \n',eps);
            end
        end
    end
end
fclose(hf);

fprintf([fileName '\n'])
fprintf('da = %.4g nm\n',da*1e9)
fprintf('Ncell = %d\n',nCell)
fprintf('OV = %d m^3\n',nCell*da^3*(sqrt(eps)-sqrt(eps0)))

hf=fopen([fileName(1:end-4) '_OV.txt'],'w');
fprintf(hf,'da = %.4g nm\n',da*1e9);
fprintf(hf,'Ncell = %d\n',nCell);
fprintf(hf,'OV = %d m^3\n',nCell*da^3*(sqrt(eps)-sqrt(eps0)));
fclose(hf);


end



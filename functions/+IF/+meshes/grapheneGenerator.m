function grapheneGenerator(opt)
arguments
    opt.pxSize double = 65e-9
    opt.C double = [] % side of the square
    opt.R double = 2e-6 % radius of the disc
    opt.D double = [] % diameter of the disc
    opt.nz double = 3 % thickness of the layer in cells
    opt.shape {mustBeMember(opt.shape,{'disc','square','hexagon'})} = 'disc'
    opt.n = 1.38
    opt.eps = []
    opt.n0 double =1.33
    opt.eps0 double = []
    opt.fileName
end

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

nz=opt.nz;

switch opt.shape
    case 'disc'

        if ~isempty(opt.D)
            R=opt.D/2;
        else
            R=opt.R;
        end


        nx=ceil(R/pxSize);
        ny=ceil(R/pxSize);

        if exist('fileName','file')
            delete fileName
        end

        hf=fopen(fileName,'w');
        fprintf(hf,'%d %d %d\n',2*nx+1,2*ny+1,nz);
        fprintf(hf,'%d\n',pxSize*1e9);

        zshift = -pxSize/2;
        %figure
        %hold on
        for z=0:nz-1
            for y=-ny:ny
                for x=-nx:nx
                    fprintf(hf,'%f %f %f\n',x*pxSize*1e9,y*pxSize*1e9,-z*pxSize*1e9+zshift*1e9);
                end
            end
        end

        nCell=0;
        for z=0:nz-1
            for y=-ny:ny
                for x=-nx:nx
                    if y*y + x*x <= R*R/(pxSize*pxSize)
                        nCell=nCell+1;
                        fprintf(hf,'(%f, 0) \n',eps);
                    else
                        fprintf(hf,'(%f, 0) \n',eps0);
                    end
                end
            end
        end

        fprintf('Ncell=%d\n',nCell)
        fprintf('OV=%d\n',nCell*pxSize^3*(sqrt(eps)-sqrt(eps0)))
        fclose(hf);

    case 'hexagon'

        if ~isempty(opt.D)
            R=opt.D/2;
        else
            R=opt.R;
        end

        nx=ceil(R/pxSize);
        ny=ceil(R/pxSize);

        if exist('fileName','file')
            delete fileName
        end

        hf=fopen(fileName,'w');
        fprintf(hf,'%d %d %d\n',2*nx+1,2*ny+1,nz);
        fprintf(hf,'%d\n',pxSize*1e9);

        zshift = -pxSize/2;
        %figure
        %hold on
        for z=0:nz-1
            for y=-ny:ny
                for x=-nx:nx
                    fprintf(hf,'%f %f %f\n',x*pxSize*1e9,y*pxSize*1e9,-z*pxSize*1e9+zshift*1e9);
                end
            end
        end

        nCell=0;
        for z=0:nz-1
            for y=-ny:ny
                for x=-nx:nx
                    if abs(y) < R*sqrt(3)/2/pxSize && abs(y+sqrt(3)*x) < sqrt(3)*R/pxSize && abs(y-sqrt(3)*x) < sqrt(3)*R/pxSize
                        nCell=nCell+1;
                        fprintf(hf,'(%f, 0) \n',eps);
                    else
                        fprintf(hf,'(%f, 0) \n',eps0);
                    end
                end
            end
        end

        fprintf('Ncell=%d\n',nCell)
        fprintf('OV=%d\n',nCell*pxSize^3*(sqrt(eps)-sqrt(eps0)))
        fclose(hf);

    case 'square'

        if ~isempty(opt.D)
            R=opt.D/2;
        else
            R=opt.R;
        end

        nx=ceil(R/pxSize);
        ny=ceil(R/pxSize);

        if exist('fileName','file')
            delete fileName
        end

        hf=fopen(fileName,'w');
        fprintf(hf,'%d %d %d\n',2*nx+1,2*ny+1,nz);
        fprintf(hf,'%d\n',pxSize*1e9);

        zshift = -pxSize/2;
        %figure
        %hold on
        for z=0:nz-1
            for y=-ny:ny
                for x=-nx:nx
                    fprintf(hf,'%f %f %f\n',x*pxSize*1e9,y*pxSize*1e9,-z*pxSize*1e9+zshift*1e9);
                end
            end
        end

        nCell=0;
        for z=0:nz-1
            for y=-ny:ny
                for x=-nx:nx
                    if abs(y) < R/pxSize && abs(x) < R/pxSize
                        nCell=nCell+1;
                        fprintf(hf,'(%f, 0) \n',eps);
                    else
                        fprintf(hf,'(%f, 0) \n',eps0);
                    end
                end
            end
        end

        fprintf('Ncell=%d\n',nCell)
        fprintf('OV=%d\n',nCell*pxSize^3*(sqrt(eps)-sqrt(eps0)))
        fclose(hf);


end

fprintf([fileName '\n'])
fprintf('da = %.4g nm\n',pxSize*1e9)
fprintf('Ncell = %d\n',nCell)
fprintf('OV = %d m^3\n',nCell*pxSize^3*(sqrt(eps)-sqrt(eps0)))

hf=fopen([fileName(1:end-4) '_OV.txt'],'w');
fprintf(hf,'da = %.4g nm\n',pxSize*1e9);
fprintf(hf,'Ncell = %d\n',nCell);
fprintf(hf,'OV = %d m^3\n',nCell*pxSize^3*(sqrt(eps)-sqrt(eps0)));
fclose(hf);


end



function meshFromImage(im0,pxSize,opt)
%% generate an IFDDA object from an image, typically a biocell
arguments
    im0 (:,:) double
    pxSize
    opt.eps0 (1,1) double = 1.33^2
    opt.epsCell (1,1) double = 1.38^2
    opt.n0 double = []
    opt.nCell double = []
    opt.folder char = pwd % output folder
    opt.fileName char = 'cell3D.txt'  % output file
    opt.Zresize double = 1
end
%pxSize=97.5e-9;
%im=readmatrix("cellTopo.txt");

im=im0*opt.Zresize;

if ~isempty(opt.nCell)
    opt.epsCell=opt.nCell^2;
end
if ~isempty(opt.n0)
    opt.epsCell=opt.n0^2;
end

[Ny, Nx] = size(im);
Nz=round(max(im(:))/pxSize);

fprintf('Ncells=%d\n',Nx*Ny*Nz)
%folder=pwd;

%%

fileN=[opt.folder '/' opt.fileName];
if exist(fileN,"file")
    fprintf('erase existing file\n')
    delete(fileN)
end

hf=fopen(fileN,'w');
fprintf(hf,'%d %d %d\n',Nx,Ny,Nz);
fprintf(hf,'%f\n',pxSize*1e9);
close all

positionList=zeros(Nx*Ny*Nz,3);
ii=0;
for z=Nz:-1:1
    for y=1:Ny
        for x=1:Nx
            ii=ii+1;
            positionList(ii,:)=[(x-Nx/2)*pxSize*1e9,(y-Ny/2)*pxSize*1e9,-z*pxSize*1e9];
        end
    end
end

fprintf(['Writing data in:\n' fileN '\n...\n'])
writematrix(positionList,fileN,"Delimiter",' ','WriteMode','append')

%%
%figure,
%scatter3(positionList(:,1),positionList(:,2),positionList(:,3),50*ones(Nx*Ny*Nz,1),positionList(:,3))
%set(gca,'DataAspectRatio',[1 1 1])
%%

%view(40,35)
%set(gca,'DataAspectRatio',[1 1 1])
aa=sprintf('(%f, 0)',opt.epsCell);
bb=sprintf('(%f, 0)',opt.eps0);
if length(aa)~=length(bb)
    error('error in the eps character lengths, they are not equal')
end

len=length(aa);
tab=zeros(Nx*Ny*Nz,len);
ii=0;
reconstructedHeight=zeros(Ny,Nx);
for z=Nz:-1:1
    for y=1:Ny
        for x=1:Nx
            ii=ii+1;
            if z <= im(y,x)/pxSize
                reconstructedHeight(y,x)=reconstructedHeight(y,x)+1;
                tab(ii,:)=sprintf('(%f, 0)',opt.epsCell);
            else
                tab(ii,:)=sprintf('(%f, 0)',opt.eps0);
            end
        end
    end
end
figure, imagegb(reconstructedHeight),drawnow
writematrix(char(tab),fileN,'WriteMode','append',QuoteStrings='none')
fclose(hf);
%%
s=dir(fileN);
the_size=s.bytes;
fprintf([opt.fileName ' / size: %.1f Mo\n'],the_size/1e6)
fprintf('done\n')

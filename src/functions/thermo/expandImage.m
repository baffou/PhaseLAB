%% program that double the size of an image for Fourier Transform purposes,
%% in a smooth manner, avoiding discontinuities.

% This version is based on the use of a smooth function ax2+bx3.

% in this new version, I calculate the slope t over a larger distance

%% ideally Ny and Nx are even (pairs)

function DexpBig=expandImage(Dexp)


%Dexp=zeros(10,20)+1;




[Ny,Nx]=size(Dexp);
DexpBig=zeros(2*Ny,2*Nx);
DexpBig(1+floor(Ny/2):Ny+floor(Ny/2),1+floor(Nx/2):Nx+floor(Nx/2))=Dexp;

if Ny/2~=floor(Ny/2) || Nx/2~=floor(Nx/2)        %This programs works only for even (pair) sizes
    Ny_et_Nx_doivent_etre_pairs
end

%% computation of the boundary vectors

Nb=2*Ny+2*Nx-4;
boundary=zeros(1,Nb);

boundary(        1 :   Ny     -1)=Dexp(1:Ny-1 ,      1);
boundary(  Ny      :   Ny+  Nx-2)=Dexp(  Ny   , 1:Nx-1);
boundary(  Ny+Nx-1 : 2*Ny+  Nx-3)=Dexp(Ny:-1:2   , Nx    );
boundary(2*Ny+Nx-2 :          Nb)=Dexp(     1 , Nx:-1:2  );

Nsm=7;      % 2Nsm+1 : number of averaged pixels

boundaryS=zeros(1,Nb);
for ii=1:Nb
    for jj=-Nsm:Nsm
        boundaryS(ii)=boundaryS(ii)+boundary(mod(ii+jj-1,Nb)+1);
    end
end

boundaryS=boundaryS/(2*Nsm+1);


%% computation of the 2nd boundary vectors

boundary2=zeros(1,Nb);

boundary2(        1 :   Ny     -1)=Dexp(1:Ny-1 ,      5);
boundary2(  Ny      :   Ny+  Nx-2)=Dexp(  Ny-4   , 1:Nx-1);
boundary2(  Ny+Nx-1 : 2*Ny+  Nx-3)=Dexp(Ny:-1:2   , Nx-4    );
boundary2(2*Ny+Nx-2 :          Nb)=Dexp(     5 , Nx:-1:2  );

%Nsm=10;      % 2Nsm+1 : number of averaged pixels

boundary2S=zeros(1,Nb);
for ii=1:Nb
    for jj=-Nsm:Nsm
        boundary2S(ii)=boundary2S(ii)+boundary2(mod(ii+jj-1,Nb)+1);
    end
end

boundary2S=boundary2S/(2*Nsm+1);

%% computation of the boundary slope


boundaryT=(boundary2S-boundaryS)/4;



%% building of the surrounding part of the image

for ii=1:Ny
    pied=apodize(Nx/2+1,boundaryS(ii),boundaryT(ii));
    DexpBig(Ny/2+ii,1:Nx/2+1)=pied;
    pied=apodize(Nx/2+1,boundaryS(2*Ny+Nx-1-ii),boundaryT(2*Ny+Nx-1-ii));
    DexpBig(Ny/2+ii,2*Nx:-1:3*Nx/2)=pied;
end
for ii=1:Nx
    pied=apodize(Ny/2+1,boundaryS(Ny-1+ii),boundaryT(Ny-1+ii));
    DexpBig(2*Ny:-1:3*Ny/2,Nx/2+ii)=pied;
    pied=apodize(Ny/2+1,boundaryS(mod(Nb+1-ii,Nb)+1),boundaryT(mod(Nb+2-ii,Nb)+1));
    DexpBig(1:Ny/2+1,Nx/2+ii)=pied;
end

%% building of the corners of the image

% DexpBig(1:Ny/2+1,   1:Nx/2+1   )=fillArea(DexpBig(1:Ny/2+1,   1:Nx/2+1   ));
% DexpBig(3*Ny/2:2*Ny,1:Nx/2+1   )=fillArea(DexpBig(3*Ny/2:2*Ny,1:Nx/2+1   ));
% DexpBig(1:Ny/2+1,   3*Nx/2:2*Nx)=fillArea(DexpBig(1:Ny/2+1,   3*Nx/2:2*Nx));
% DexpBig(3*Ny/2:2*Ny,3*Nx/2:2*Nx)=fillArea(DexpBig(3*Ny/2:2*Ny,3*Nx/2:2*Nx));

DexpBig(1:Ny/2+1,   1:Nx/2+1   )=fillArea(DexpBig(1:Ny/2+1,   1:Nx/2+1   ));
DexpBig(2*Ny:-1:3*Ny/2,1:Nx/2+1   )=fillArea(DexpBig(2*Ny:-1:3*Ny/2,1:Nx/2+1   ));
DexpBig(1:Ny/2+1,2*Nx:-1:3*Nx/2)=fillArea(DexpBig(1:Ny/2+1,   2*Nx:-1:3*Nx/2));
DexpBig(3*Ny/2:2*Ny,3*Nx/2:2*Nx)=fillArea(DexpBig(3*Ny/2:2*Ny,3*Nx/2:2*Nx));














             

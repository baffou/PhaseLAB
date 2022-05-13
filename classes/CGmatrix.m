classdef CGmatrix
% class of images that are either grating transmittance or E-field
% G. Baffou, CNRS, Jan 2022

    properties
        im
        pxSize %[m]
    end
    
    properties(Dependent)
        Nx    %[px]
        Ny    %[px]
        imSize %[m]
    end
    
    methods

        function M=CGmatrix(im0,imS)
            % im: image matrix
            % imS: lateral (in x) image size in µm
            if nargin ~= 0
                M.im=im0;
                M.pxSize=imS/M.Nx;
            end
        end
        
        function M=set.im(M,im0)
            if size(im0,1)==size(im0,2)
                M.im=im0;
            else
                error('The matrix must be square')
            end
        end
        
        function val=get.Ny(M)
            val=size(M.im,1);
        end
        
        function val=get.Nx(M)
            val=size(M.im,2);
        end
        
        function val=get.imSize(M)
            if M.Nx == M.Ny
                val = M.pxSize*M.Nx;
            else
                val = [ M.pxSize*M.Ny, M.pxSize*M.Nx];
            end                
        end
        
        function M=removeBorderLines(M,n)
            M.im=M.im(1:end-n,1:end-n);
        end
        
        function [M,fac]=setI0(M,I0,opt)
            arguments
                M
                I0
                opt.mode (1,:) char {mustBeMember(opt.mode,{'max','mean'})} = 'max'
            end
            if strcmpi(opt.mode,'max') % Adjust the max of the interfero to the full well capacity (fwc)
                fac=1/max(abs(M.im(:)))*I0;
            else
                fac=mean(abs(M.im(:)))*I0/2; % Adjust the mean of the interfero to half the fwc
            end 
            M.im=M.im*fac;
        end
        
        function [M,fac]=timesC(M,fac)
            M.im=M.im*fac;
        end
        
        function Mat=tile(Mat,Nx,Ny)
            %(Mat,Nx,Ny)
            if nargin==2
                Ny=Nx;
            end
            % N: new matric size
            factorx=ceil(Nx/Mat.Nx);
            factory=ceil(Ny/Mat.Ny);
            Mat.im=repmat(Mat.im,factory,factorx);
            Mat.im=Mat.im(1:Ny,1:Nx); % in case gratingSize is not an integer, it was overestimated in the previous line so we cut here the image properly à Ni
        end
        
        function M2=rotation(M,thetad)
            M2=M;
            M2.im=imrotate(M.im,thetad);
        end

        function M=redimension(M,camPxSize,pxRatio)
%            fac=M.pxSize/(camPxSize);
            fac=abs(pxRatio);
            M.im=imresize(M.im,fac);
            M.pxSize=abs(camPxSize);
        end
        
        function M=crop(M,Nx,Ny)
            Nx=abs(Nx);
            Ny=abs(Ny);
            M.im=M.im(1+(M.Nx-Nx)/2:Nx+(M.Nx-Nx)/2,1+(M.Ny-Ny)/2:Ny+(M.Ny-Ny)/2);
        end
        
        function M=square(M)
            M.im=abs(M.im).^2;
        end
        
        function M=propagation(M,lambda,L,dx,dy)
            if nargin==3
                dx=0;
                dy=0;
            end
            M.im=improp(M.im,M.imSize,lambda,L,dx,dy);
        end
        
        function M = BackForPropagation(M,Grating,MI,IL)
            lambda=IL.lambda;
            L=MI.CGcam.distance(lambda);
            
            if IL.NA==0
                Fdb2=M;
                Fdb2.im=M.im*0;
                imp=improp(M.im,M.imSize,lambda,-L,0,0);
                imp2=Grating.im.*imp;
                imp3=improp(imp2,M.imSize,lambda,L,0,0);
                impsq=abs(imp3).^2;
                Fdb2.im=impsq;
                M=Fdb2;
            else
                n=1; %refractive index of the upper medium
                Mobj=MI.Objective.Mobj;
                thetaIll=asin(IL.NA/n);
                anglemax=atan(tan(thetaIll)/abs(Mobj)); % remplacé par cette formule normalement plus juste
                dxmax=abs(anglemax*L);

                dnmax=(dxmax/MI.CGcam.Camera.dxSize); % déplacement maximal en dexels de l'interféro quandon fait varier l'angle d'illumination
                dn=1/10; % degree of discretization (fraction of a dexel) for the integration over the illumination angle
                dnmax=ceil(dnmax/dn)*dn; % rend dnmax multiple de dn pour être sur que la boucle passe par is=0 et iy=0 
                    
                if dnmax==0
                    dn=0.2;
                else
                    dn=min(0.2,dnmax); % degree of discretization (fraction of a dexel) for the integration over the illumination angle
                end
                
                Fdb2=M;
                Fdb2.im=M.im*0;
                nc=0;
                for ix=-dnmax:dn:dnmax
                    for iy=-dnmax:dn:dnmax
                        if ix*ix+iy*iy<=dnmax*dnmax
                            nc=nc+1;
                            % propagation(lambda,z0,dnx,dny)
%                            Fd=Fdb.propagation(lambda,z0,ix,iy);% Propagate the light after the unit cell
                            imp=improp(M.im,M.imSize,lambda,-L,-ix,-iy);
                            imp2=Grating.im.*imp;
                            imp3=improp(imp2,M.imSize,lambda,L,ix,iy);
                            impsq=abs(imp3).^2;
                            Fdb2.im=Fdb2.im+impsq;
                        end
                    end
                end
                Fdb2.im=Fdb2.im/nc;
%                 figure
%                 imagegb(Fdb2.im)
%                 colormap('Gray')
%                 fullscreen
%                 sfgsdf
                
                %%
                M=Fdb2;
            end
        end
        
        function M=TileRot5(M,th)
            fac=5;
            if nargin==1
                theta=acos(3/5);
            elseif nargin==2
                theta=th;
            else
                error('wrong number of inputs')
            end
            [X,Y]=meshgrid(1:M.Nx*fac,1:M.Ny*fac);
            M.im=rotation(X,Y,M.im,theta);
        end
    
        function figure(M,h)
            if nargin==2
                figure(h)
            else
                figure
            end
            ai=imagesc(1e6*(1:M.Nx)*M.pxSize,1e6*(1:M.Ny)*M.pxSize,real(M.im));
            set(ai.Parent,'DataAspectRatio',[1 1 1])
            xlabel(gca,'um')
            colorbar
            colormap(gca,CGcolorScale)
            
        end

        function obj=times(obj1,obj2)
            if obj1.Nx~=obj2.Nx || obj1.Ny~=obj2.Ny
                error('Different image sizes')
            elseif obj1.pxSize~=obj2.pxSize
                error('Different pixel sizes')
            end
            obj=obj1;
            obj.im=obj1.im.*obj2.im;
        end
    end
    
end













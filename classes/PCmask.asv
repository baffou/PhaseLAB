classdef PCmask < handle & matlab.mixin.Copyable
    % defines an annulus or disc phase mask in an objective lens
    % for Zernike phase contrast or SLIM or dark field imaging
    % the disc mask can be off-centered
    properties
        A       % transmittance of the mask in intensity (not in E, which is sqrt(A))
        phi     % phase shift of the mask
        NA0     % radius of the ring, or shift from the center of the disc
        dNA     % thickness of the ring, or diameter of the disc
        theta   = 0 % angular position of the disc, meaningful only for type='disc'
        type {mustBeMember(type,{'ring','disc'})} = 'ring'
        inverted logical = false
    end

    methods
        function obj = PCmask(NA0,dNA,opt)
            arguments
                NA0 double = double.empty()            % radius of the phase annulus, in NA
                dNA double = double.empty()           % width of the annulus, in NA
                opt.A double = 1    % transmittance of the annulus
                opt.phi double = pi/2 % phase shift of the annulus
                opt.type char ='ring'
            end
            if nargin==0
                % do nothing
            elseif nargin==2
                obj.NA0 = NA0;
                obj.dNA = dNA;
            else
                error('not the proper number of inputs: 0 or 2')
            end
            obj.A = opt.A;
            obj.phi = opt.phi;
            obj.type = opt.type;
        end

        function setRadius(obj,var)
            % function that sets the NA0 value
            % setRadius(ImageEM)
            % setRadius(PCmask)
            % setRadius(NA)
            arguments
                obj PCmask
                var
            end
            if isa(var,'ImageEM')
                Nx = var.Nx;
                Ny = var.Nx;
                lambda = var.Illumination.lambda;
                M = abs(var.Microscope.M);
                dxSize = var.dxSize;
                
                %figure
               % imagegb(log(abs(imgaussfilt(var(1).FT,2))))
                %zoom(6)
                %fullscreen
                %pause(0.7)
                %[x,y]=ginput(1);
                [y,x]=find(abs(var(1).FT)==max(max(abs(var(1).FT))));
                dx=x-(var(1).Nx/2+1);
                dy=y-(var(1).Ny/2+1);
                if strcmp(obj.type,'disc')
                    obj.theta=angle(dx+1i*dy);
                end
                Rpx=sqrt(dx*dx+dy*dy);
                fprintf('Rpx=%.1f\n',Rpx)
    
                dk = 2*pi/(dxSize*Nx);
                kx=Rpx*dk;
                k0=2*pi/lambda;
                NA0image = kx/k0;
                n_glass=1.5;
                theta_inc = asin(sin(atan(M*NA0image))*n_glass);
                %disp(theta_inc*180/pi)
                obj.NA0 = sin(theta_inc);
                fprintf('NA0=%.1g\n',obj.NA0)
                %NAmax = tan(asin(sind(theta_inc)/n_glass))/M
            elseif isa(var,'PCmask')
                obj.NA0=var.NA0;
                obj.theta=var.theta;
            elseif isnumeric(var)
                obj.NA0=var;
            end

        end

        function val = mask(obj,var1,IL)
            % returns the mask, but requires an image or a
            % microscope as an input to know the dimensions.
            % .mask(IM)
            % .mask(MI,IL)
            % .mask(MI,lambda)

            % definition of the parameters
            if isa(var1,'ImageEM')
                IM=var1;
                Nx = IM(1).Nx;
                Ny = IM(1).Ny;
                dk = 2*pi/(IM(1).dxSize*Nx);
                k0=2*pi/IM(1).Illumination.lambda;
                M = abs(IM(1).Microscope.M);
            elseif isa(var1,Microscope)
                MI=var1;
                if isa(IL,'Illumination')
                    lambda=IL.lambda;
                elseif isnumeric(IL)
                    lambda=IL;
                else
                    error('not the proper input type for an illumination')
                end
                Nx = MI.CGcam.Camera.Nx;
                Ny = MI.CGcam.Camera.Ny;
                dk = 2*pi/(MI.CGcam.dxSize*Nx);
                k0=2*pi/lambda;
                M = abs(MI.M);
            end

            n_glass=1.5;
            Rpx = tan(asin(obj.NA0/n_glass))/M*k0/dk;
            %fprintf('Rpx = %.1f\n',Rpx)

            dRpx = tan(asin(obj.dNA/n_glass))/M*k0/dk;
            %fprintf('dRpx= %.1f\n',dRpx)

            if strcmp(obj.type,'disc')
                [X0, Y0] = meshgrid(-Nx/2:Nx/2-1,-Ny/2:Ny/2-1);
                X=X0-Rpx*cos(obj.theta);
                Y=Y0-Rpx*sin(obj.theta);
                R=sqrt(X.*X+Y.*Y);
                pattern = R<=dRpx/2;
            else
                [X, Y] = meshgrid(-Nx/2:Nx/2-1,-Ny/2:Ny/2-1);
                R=sqrt(X.*X+Y.*Y);
                pattern = (R>=(Rpx-dRpx/2)).*(R<=(Rpx+dRpx/2));
            end
            val = (1-pattern + sqrt(obj.A)*pattern) .* exp(1i*obj.phi*pattern);
            if obj.inverted
                val=1-val;
            end
        end

        function figure(obj,IM)
            figure
            ax1=subplot(1,3,1);
            imagesc(log(IM(1).FT));
            set(gca,'DataAspectRatio',[1,1,1])
            title('OPD image')
            colorbar
            ax2=subplot(1,3,2);
            imagesc(abs(obj.mask(IM(1))));
            set(gca,'DataAspectRatio',[1,1,1])
            title('intensity')
            colorbar
            colormap(gca,"gray")
            clim([0 1]);
            ax3=subplot(1,3,3);
            imagesc(angle(obj.mask(IM(1))));
            set(gca,'DataAspectRatio',[1,1,1])
            colormap(gca,Pradeep)
            colorbar
            clim([-pi pi]);
%            cb=colorbar;
%            cb.Label.String='phase';
            title('Phase')
            fullwidth
            linkaxes([ax1, ax2, ax3])
            zoom on
        end

        function val = x0(obj)
            if strcmp(obj.type,'ring')
                warning('It does not make sense to try and compute the position x0 for a ring shape. Makes sense only for a disc mask.')
            end
            val = obj.NA0*cos(obj.theta);
        end

        function val = y0(obj)
            if strcmp(obj.type,'ring')
                warning('It does not make sense to try and compute the position x0 for a ring shape. Makes sense only for a disc mask.')
            end
            val = obj.NA0*sin(obj.theta);
        end



    end
end
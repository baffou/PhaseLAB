classdef IFfield
    properties
        fileName char =[]
        Ex
        Ey
        Ez
        E2
        xscale
        Npx
        lambda
        P0
        w0
        aretecube
        ndipole
        epsmax
        epsmin
        NA
        M
    end
    properties(Dependent)
        pxSize
        N   % NxN is the number of pixels of the image
        I0  % intensity in the camera plane
        I   % normalized intensity image
        Ix  % x-component of the normalized intensity image
        Iy  % y-component of the normalized intensity image
        Iz  % z-component of the normalized intensity image
        E0x % amplitude of the incident electric field along x, camera plane
        E0y % amplitude of the incident electric field along y, camera plane
        E0z % amplitude of the incident electric field along z, camera plane
        OPDx
        OPDy
        OPDz
        OPD % = OPDy
        nameValue
    end

    methods
        function obj = IFfield(Ex, Ey, Ez, E, prop)
            arguments
                Ex
                Ey
                Ez
                E
                prop.options
                prop.fileName char =[]
            end
            obj.Ex=Ex;
            obj.Ey=Ey;
            obj.Ez=Ez;
            obj.E2=E.^2;

            if ~isempty(prop.options) % IFfield(Exyz,'data',data)
                obj=obj.load(prop.options); % incorporate the properties within the object
            end
            
            obj.fileName=prop.fileName;
        end

        function obj = load(obj,data)
            propList=fieldnames(data);
            Nl=length(propList);
            for il=1:Nl
                eval(['obj.' propList{il} '=data.' propList{il} ';'])
            end

        end

        function val = get.pxSize(obj)
            val=obj.xscale(2)-obj.xscale(1);
        end

        function val = get.Ix(obj)
            val=abs(obj.Ex).^2/obj.I0;
        end

        function val = get.Iy(obj)
            val=abs(obj.Ey).^2/obj.I0;
        end

        function val = get.Iz(obj)
            val=abs(obj.Ez).^2/obj.I0;
        end

        function val = get.I(obj)
            val=obj.Ix+obj.Iy+obj.Iz;
        end

        function val = get.OPDx(obj)
            val=angle(obj.Ex/obj.E0x)*obj.lambda/(2*pi);
        end

        function val = get.OPDy(obj)
            val=angle(obj.Ey/obj.E0y)*obj.lambda/(2*pi);
        end

        function val = get.OPDz(obj)
            val=angle(obj.Ez/obj.E0z)*obj.lambda/(2*pi);
        end

        function val = get.I0(obj)
            %val = obj.P0/(pi*(objw0/2)^2);
            val=abs(obj.E0x)^2+abs(obj.E0y)^2+abs(obj.E0z)^2;
        end
        
        function val = get.N(obj)
            val = size(obj.Ex,1);
        end

        function val=get.nameValue(obj)
            if ~isempty(obj.fileName)
                indices=regexp(obj.fileName,'[0-9]');
                if strcmp(obj.fileName(indices(1)-1),'-')
                    val=-str2double(obj.fileName(indices));
                else
                    val=str2double(obj.fileName(indices));
                end
            end
        end

        function val=nameValues(obj)
            No=numel(obj);
            val=zeros(No,1);
            for io=1:No
                if ~isempty(obj(io).fileName)
                    indices=regexp(obj(io).fileName,'[0-9]');
                    if strcmp(obj(io).fileName(indices(1)-1),'-')
                        val(io)=-str2double(obj(io).fileName(indices));
                    else
                        val(io)=str2double(obj(io).fileName(indices));
                    end
                end
            end
        end

        function obj = set.pxSize(obj,val)
            if(val>0.1) % if in [nm]
                obj.pxSize=val*1e-9;
            else % if in [m]
                obj.pxSize=val;
            end
        end

        function objList2=sort(objList)
            [~,order]=sort(objList.nameValues);
            objList2=objList(order);
        end 

        function objList2=crop(objList,val)
            objList2=objList;
            for io=1:numel(objList)
                objList2(io).Ex=objList(io).Ex(end/2-val/2+1:end/2-val/2+val,end/2-val/2+1:end/2-val/2+val);
                objList2(io).Ey=objList(io).Ey(end/2-val/2+1:end/2-val/2+val,end/2-val/2+1:end/2-val/2+val);
                objList2(io).Ez=objList(io).Ez(end/2-val/2+1:end/2-val/2+val,end/2-val/2+1:end/2-val/2+val);
            end
        end

        function h2=figure(obj)
            h=figure;
            X=1e6*(1:obj(1).nfft)*obj(1).pxSize;
            ax1=subplot(1,2,1);
            imagesc(X,X,obj(1).I)
            set(gca,'DataAspectRatio',[1 1 1])
            title('Intensity')
            set(gca,'Colormap',gray)
            colorbar
            ax2=subplot(1,2,2);
            imagesc(X,X,obj(1).OPDy)
            set(gca,'DataAspectRatio',[1 1 1])
            title('OPD')
            set(gca,'Colormap',phase1024)
            colorbar
            linkaxes([ax1 ax2])
            h.UserData.ImList=obj;
            h.UserData.nIm=1; % object number
            h.UserData.ax1=ax1; % object number
            h.UserData.ax2=ax2; % object number
            set(h,'WindowButtonDownFcn',@changeImage)
            h.Name=['Image ' num2str(h.UserData.nIm) ' - ' h.UserData.ImList(h.UserData.nIm).fileName];
            
            function changeImage(src,evt)
                % right click: next image
                % left click: previous image
                % center click: zoom in
                % double click any button : zoom out
                Nim=numel(src.UserData.ImList);
                if strcmpi(src.SelectionType,'normal')
                    src.UserData.nIm=mod(src.UserData.nIm-2,Nim)+1;
                elseif strcmpi(src.SelectionType,'alt')
                    src.UserData.nIm=mod(src.UserData.nIm,Nim)+1;
                elseif strcmpi(src.SelectionType,'extend')
                    zoom(src,sqrt(2))
                elseif strcmpi(src.SelectionType,'open')
                    zoom out
                end
                src.UserData.nIm
                src.UserData.ax1.Children.CData=src.UserData.ImList(src.UserData.nIm).I;
                src.UserData.ax2.Children.CData=src.UserData.ImList(src.UserData.nIm).OPDy;
                src.Name=['Image ' num2str(src.UserData.nIm) ' - ' src.UserData.ImList(src.UserData.nIm).fileName];
                drawnow
            end
            if nargout
                h2=h;
            end
            
        end

        function val = get.OPD(obj)
            val = obj.OPDy();
        end

        function val = OV(obj)
            No=numel(obj);
            val=zeros(No,1);
            for io=1:No
                val(io)=sum(obj(io).OPD(:))*obj(io).pxSize*obj(io).pxSize;
            end
        end

        function val = OVnorm(obj)
            No=numel(obj);
            val=zeros(No,1);
            for io=1:No
                val(io)=sum(obj(io).OPD(:).*sqrt(obj(io).I(:)))*obj(io).pxSize*obj(io).pxSize;
            end
        end

        function val = OVtheo(obj,val)
            if nargin==2
                Ndip=val;
            else
                Ndip=obj(1).ndipole;
            end
            No=numel(obj);
            val=zeros(No,1);
            for io=1:No
                val(io)=(sqrt(obj(io).epsmax)-sqrt(obj(io).epsmin))*Ndip*obj(io).aretecube^3;
            end
        end
    
        function val = get.E0x(obj)
            val=obj.E0xreal+1i*obj.E0ximag;
        end
        function val = get.E0y(obj)
            val=obj.E0yreal+1i*obj.E0yimag;
        end
        function val = get.E0z(obj)
            val=obj.E0zreal+1i*obj.E0zimag;
        end
    end
end






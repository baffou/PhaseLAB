% Method of the Interfero class.

function [IM,DWx,DWy,W,T,FIm,cropParam0,cropParam1,cropParam2] = QLSIprocess(Itf,IL,opt)
% field contains T or W. Useful when IM is not an ouput because not T and W need to be both computed, so IM cannot be constructed : [~, DWx, DWy, field]
arguments
    Itf Interfero
    IL % Illumination object or wavelength
    opt.Fcrops = []
    opt.crop = []
    opt.method     char {mustBeMember(opt.method,     {'Tikhonov','Errico','CPM','ASDI'})} = 'Tikhonov'
    opt.definition char {mustBeMember(opt.definition, {'high','low'})} = 'high'
    opt.Fcropshape char {mustBeMember(opt.Fcropshape, {'disc','square'})} = 'disc'
    opt.Smatrix = []
    opt.apodization = false        % true, 1, or the width of the apodization in px
    opt.remotePath = []
    opt.Tnormalisation = true % or false or 'subtraction'. To be false for a fluorescence image for instance
    opt.RemoveCameraOffset logical = false
    opt.darkImage = 0 % dark Image to be removed
    opt.darkZoneCorrection logical = false
    opt.auto = true % Find automatically the spot of highest intensity
    opt.noRef logical = false % Do not consider the Ref interferogram to compute the DW and OPD images
    opt.CGdistanceList = []  % the grating distance was varied during the acquisition of the images list
    opt.resetCrops   logical = false % reset crops between each image calculation, to make sure the algorithm enable the user to click for each image, or force the detection of the spot for each image in the auto mode.
    opt.unwrap (1,1) logical = false % use unwrapping. Slows down a bit the processing.
    opt.displayCrop (1,1) logical = true % display the crops, even when automatic
    opt.displayBar (1,1) logical = true % display the progression bar in case of multiple images
    opt.Rdistance (1,1) double = 1 % multiplies the distance of the crop from the center of the image by Rfactor. Useful to crop the spots at 45°, by just setting R=sqrt(2)
    opt.Rfactor (1,1) double = 1 % Crop radius factor
    opt.saveGradients = false
    opt.computeW = true
    opt.computeT = true
    opt.computeIM = true % false if we only wish to get T, W, DWx, ..., but not the object
    opt.sizeMustBeEven logical = true
end

Nf = size(Itf,1);
Np = size(Itf,2);

zetaTheo = round(Itf(1).Microscope.CGcam.zeta,1);

%% Shaping of the Illumination object(s)
if isa(IL,'Illumination')
elseif isnumeric(IL) % if IL is a wavelength
    IL = Illumination(IL);
else
    error('error with the thrid input must be an Illumination object or a wavelength')
end

if opt.unwrap % if unwrapping is selecting, redefine the angle function
    anglefun = @(x) Unwrap_TIE_DCT_Iter(angle(x));
else
    anglefun = @angle;
end

if numel(IL)==1
    if length(IL.lambda)==1
        IL = repmat(IL,Nf,1);
    elseif length(IL.lambda)~=Nf
        error(['The number of Interferos (' num2str(Nf) ') is not the number of specified lambda (' num2str(length(IL.lambda)) ')'])
    else % single IL object, but with a list of lambda
        IList = repmat(IL,Nf,1);
        for il = 1:Nf
            IList(il) = Illumination(IL.lambda(il),Medium(IL.n,IL.nS),IL.I,IL.polar);
        end
        IL = IList;
    end
elseif numel(IL)~=Nf
    error(['The number of images (' num2str(Nf) ') is not the number Illumination objects (' num2str(length(IL)) ')'])
end


%% shaping of the crops
updateRefFcrop = 0;

IM = repmat(ImageQLSI(),Nf,Np);
if ~isempty(opt.Fcrops) % If crops are defined within the options
    if numel(opt.Fcrops)~=3
        error('cropping parameters must be a 3-cell array.')
    end
    if isa(opt.Fcrops(1),'FcropParameters') && isa(opt.Fcrops(2),'FcropParameters') && isa(opt.Fcrops(3),'FcropParameters')
        cropParam0 = opt.Fcrops(1);
        cropParam1 = opt.Fcrops(2);
        cropParam2 = opt.Fcrops(3);
    else
        opt.Fcrops(1)
        error('not FcropParameters objects')
    end
elseif ~isempty(Itf(1).Ref) && ~isempty(Itf(1).Ref.Fcrops(1).Nx) % if the ref already has crops
    cropParam0 = Itf(1).Ref.Fcrops(1);
    cropParam1 = Itf(1).Ref.Fcrops(2);
    cropParam2 = Itf(1).Ref.Fcrops(3);
else % if crops are not defined anywhere
    updateRefFcrop = 1;
    cropParam0 = FcropParameters(Itf(1).Nx/2+1,Itf(1).Ny/2+1,[],Itf(1).Nx,Itf(1).Ny,'zeta',zetaTheo);
    cropParam1 = FcropParameters([],[],[],Itf(1).Nx,Itf(1).Ny,'zeta',zetaTheo);
    cropParam2 = FcropParameters([],[],[],Itf(1).Nx,Itf(1).Ny,'zeta',zetaTheo);
end
Nx0 = 0;
Ny0 = 0;


if numel(opt.Tnormalisation) == 1 % just true or false
    opt.Tnormalisation = repmat(opt.Tnormalisation,Nf,1);
elseif numel(opt.Tnormalisation) ~= Nf
    error('The length of the Tnormalisation vector input must equal the number of images')
end

for ii = 1:Nf
    for ip = 1:Np
        if Nf>1
            fprintf('Interfero %d / %d, ',ii,Nf)
        end

        % handling the offset option
        if isnumeric(opt.RemoveCameraOffset) && opt.RemoveCameraOffset~=1 % an offset is set manually
            offset = opt.RemoveCameraOffset;
        elseif opt.RemoveCameraOffset % if true
            offset = Itf(1).Microscope.CGcam.Camera.offset;
        else
            offset = 0;
        end

        % handling the darkimage option
        if any(opt.darkImage ~=0) % if a darkImage has been specified
            offset = 0; % don't substract the camera offset if a dark image is already subtracted
            if isa(opt.darkImage,'Interfero')
                if numel(opt.darkImage) == 1 % if darkImage consists of 1 interfero
                    opt.darkImage = opt.darkImage.Itf; % take the Itf property once and for all
                    darkImage = opt.darkImage;
                else % if darkImage consists of multiple interferos, typically for Np = 2 or 4
                    if size(opt.darkImage) ~= size(Itf,2)
                        error('The number of dark interferograms should equal the number of parallel interferos')
                    else
                        Nd = size(Itf,2);
                        jj = ceil(ii*Nd/Nf);
                        darkImage = opt.darkImage(jj).Itf;
                    end
                end
            elseif isnumeric(opt.darkImage)
                % fine
            else
                error('Not a proper type for darkImage')
            end
        else
            darkImage = 0;
        end


        if ~isempty(opt.crop)
            if ischar(opt.crop) % ie manual
                hroi = figure;
                set(hroi,'Visible','on') % in case a liveeditor program is used
                imagegb(imgaussfilt(Itf(ii,ip).Itf,2)./imgaussfilt(Itf(ii,ip).Ref.Itf,2))
                roi = drawrectangle;
                x1 = round(roi.Position(1)-0.5);
                x2 = round(roi.Position(1)+roi.Position(3)-0.5);
                y1 = round(roi.Position(2)-0.5);
                y2 = round(roi.Position(2)+roi.Position(4)-0.5);
                close(hroi)
                Itfi = Itf(ii,ip).crop([x1 y1],[x2 y2]);
                opt.crop = [x1;y1;x2;y2];
            else
                Itfi = Itf(ii,ip).crop(opt.crop(1:2),opt.crop(3:4));
            end
        else
            Itfi = Itf(ii,ip);
        end


        if ii==2 && opt.displayBar && ip == 1
            fwb = waitbar(0,'1','Name','Image processing...',...
                'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            setappdata(fwb,'canceling',0);
        end

        if ii>=2 && opt.displayBar
            if getappdata(fwb,'canceling')
                break
            end
        end

        if isempty(Itfi.Itf)
            error(['the interferogram number ' num2str(ii) ' is empty'])
        end
        if isempty(Itfi.Ref)
            warning(['the reference of the interferogram number ' num2str(ii) ' is empty'])
        end

        MI = Itfi.Microscope;

        if ~isempty(opt.CGdistanceList)
            if numel(opt.CGdistanceList) == Nf
                MI.CGcam.setDistance(opt.CGdistanceList(ii));
            elseif numel(opt.CGdistanceList) == 1
                MI.CGcam.setDistance(opt.CGdistanceList);
            else
                error('not the proper number of elements of CGdistanceList')
            end
        end


        Nx = Itfi.Nx;
        Ny = Itfi.Ny;
        if Nx~=cropParam0.Nx || Ny~=cropParam0.Ny % check if the image size changed compared with the previous one, and reinitialize the parameters in case it did.
            zetaTheo = round(Itf(ii,ip).Microscope.CGcam.zeta,1);
            cropParam0 = FcropParameters(Nx/2+1,Ny/2+1,[],Nx,Ny,'zeta',zetaTheo);
            cropParam1 = FcropParameters([],[],[],Nx,Ny,'zeta',zetaTheo);
            cropParam2 = FcropParameters([],[],[],Nx,Ny,'zeta',zetaTheo);
            opt.Smatrix=[];
        end

        if opt.resetCrops % force to reset the crops between each simulations, for instance when the angle of the grating changes, which cannot be detected by looking only at MI.
            zetaTheo = round(Itf(ii,ip).Microscope.CGcam.zeta,1);
            cropParam0 = FcropParameters(Nx/2+1,Ny/2+1,[],Nx,Ny,'zeta',zetaTheo);
            cropParam1 = FcropParameters([],[],[],Nx,Ny,'zeta',zetaTheo);
            cropParam2 = FcropParameters([],[],[],Nx,Ny,'zeta',zetaTheo);
        end


        if opt.apodization % if apodization required
            fprintf("apodization \n")
            if opt.apodization == 1 % if apo value not specified, then equals 20
                apoNpx = 20;
            else
                apoNpx = opt.apodization;
            end

            % 1.
            % [~,mask] = apodization0(Itfi.Itf,apoNpx);
            % FIm = fftshift(fft2(Itfi.Itf.*mask));

            % 2.
            FIm = fftshift(fft2(apodization0(Itfi.Itf-darkImage-offset,apoNpx)));



            if Itfi.Ref.TFapo == apoNpx  % if the apo TF has already been calculated for Ref and matches the one of the Itf
                FRf = Itfi.Ref.TF;
            else   % else calculate the TF of the Ref with apodization
                Itfi.Ref.computeTF(apoNpx,darkImage+offset)
                FRf = Itfi.Ref.TF;
            end

        else
            apoNpx = 0;
            FIm = fftshift(fft2(Itfi.Itf));
            if ~opt.noRef
                FRf = Itfi.Ref.TF;
            else
                FRf = FIm*0;
            end
        end

        if isempty(FRf) && ~opt.noRef
            computeTF(Itfi.Ref,apoNpx,darkImage+offset)
            if ~opt.noRef
                FRf = Itfi.Ref.TF;
            else
                FRf = FIm*0;
            end
        end

        %    fprintf('ZERO ORDER\n')
        zeta = Itfi.Microscope.CGcam.zeta / Itfi.binningFactor;

        if ~isequal(size(FIm),size(FRf))
            error('sizes of itf and ref not identical')
        end

        % intensity image


        [FImc,FRfc,cropParam0] = FourierCrop(FIm,FRf,zeta, ...
            'Fcrops',cropParam0, ...
            'definition',opt.definition, ...
            'FcropShape',opt.Fcropshape, ...
            'auto',opt.auto, ...
            'display',opt.displayCrop, ...
            'Rdistance',opt.Rdistance, ...
            'Rfactor',opt.Rfactor);

        if opt.computeT
            Im_int = ifft2(ifftshift(FImc));
            Rf_int = ifft2(ifftshift(FRfc));

            if strcmpi(opt.Tnormalisation(ii),'subtraction')
                T = abs(Im_int) - abs(Rf_int);
            elseif opt.Tnormalisation(ii)
                T = abs(Im_int)./abs(Rf_int);
            else
                T = abs(Im_int);
            end

        else
            T = [];
        end


        % fprintf('FIRST ORDER ALONG XD\n')
        cropParam1.R = cropParam0.R;
        cropParam2.R = cropParam0.R;
        [FImc,FRfc,cropParam1] = FourierCrop(FIm,FRf,zeta, ...
            'Fcrops',cropParam1, ...
            'definition',opt.definition, ...
            'FcropShape',opt.Fcropshape, ...
            'auto',opt.auto, ...
            'display',opt.displayCrop, ...
            'Rdistance',opt.Rdistance, ...
            'Rfactor',opt.Rfactor);

        Im_DW1 = ifft2(ifftshift(FImc));
        Rf_DW1 = ifft2(ifftshift(FRfc));

        % fprintf('FIRST ORDER ALONG YD\n')
        cropParam2 = cropParam1.rotate90();
        [FImc,FRfc,cropParam2] = FourierCrop(FIm,FRf,zeta, ...
            'Fcrops',cropParam2, ...
            'definition',opt.definition, ...
            'FcropShape',opt.Fcropshape, ...
            'display',opt.displayCrop, ...
            'Rdistance',opt.Rdistance, ...
            'Rfactor',opt.Rfactor);

        Im_DW2 = ifft2(ifftshift(FImc));
        Rf_DW2 = ifft2(ifftshift(FRfc));


        % phase gradient images

        if ~opt.darkZoneCorrection % == false
            if strcmpi(opt.definition,'low') % compute the correction factor in case the image is small (fast mode)
                rx = cropParam2.R(1);
                corr = Nx/length(round((-rx:rx-1)));
            else
                corr = 1;
            end

            alpha = corr*MI.CGcam.alpha(IL(ii).lambda)*Itfi.binningFactor;

            if isinf(alpha)
                error('the grating distance is zero')
            end

            if opt.noRef
                DW1 = -anglefun(Im_DW1)* alpha;
                DW2 = -anglefun(Im_DW2)* alpha;
            else
                DW1 = -anglefun(Im_DW1.*conj(Rf_DW1))* alpha;
                DW2 = -anglefun(Im_DW2.*conj(Rf_DW2))* alpha;
            end
            DWx = cropParam1.angle.cos*DW1-cropParam1.angle.sin*DW2;
            DWy = cropParam1.angle.sin*DW1+cropParam1.angle.cos*DW2;

        elseif opt.darkZoneCorrection == 1 % Bing Xu
            % from Optics Communications 402 (2017) 276–284

            if strcmpi(opt.definition,'low')
                error('darkZoneCorrection only works in high definition')
            end
            zeta = Itfi.Microscope.CGcam.zeta;
            if strcmpi(opt.definition,'low')
                ItfNew = Itfi.normalize(imresize(T,zeta*size(T)));
            else
                ItfNew = Itfi.normalize(T);
            end
            [~,DWx_error,DWy_error] = QLSIprocess(ItfNew,IL(ii).lambda,"displayCrop",false,"definition","high","computeT",0,"computeW",0); %Add options?

            IM_Ph0 = ImageQLSI(T,T*0,MI,IL(ii).lambda); % Zero phase
            Itf_Ph0 = CGMinSilico(IM_Ph0);
            [~,DWx_Ph0,DWy_Ph0] = QLSIprocess(Itf_Ph0,IL(ii).lambda,"displayCrop",false,"definition","high","computeT",0,"computeW",0);
            DWx = DWx_error - DWx_Ph0;
            DWy = DWy_error - DWy_Ph0;
            figure
            subplot(1,2,1)
            imagegb(DWx_error)
            imgg = imgaussfilt(DWx_error(:),10);
            minc = min(imgg);
            maxc = max(imgg);
            clim([minc, maxc])
            title('Itf/T gradients')
            subplot(1,2,2)
            imagegb(DWx_Ph0)
            clim([minc, maxc])
            title('zero W gradients')
            drawnow
        else % opt.darkZoneCorrection ∈ ]0, 1[ is the threshold
            % method that sets dWX and dWy to 0
            dzc = opt.darkZoneCorrection;
            if strcmpi(opt.definition,'low') % compute the correction factor in case the image is small (fast mode)
                rx = cropParam2.R(1);
                corr = Nx/length(round((-rx:rx-1)));
            else
                corr = 1;
            end

            if opt.noRef
                DW1 = -anglefun(Im_DW1)* corr*MI.CGcam.alpha(IL(ii).lambda);
                DW2 = -anglefun(Im_DW2)* corr*MI.CGcam.alpha(IL(ii).lambda);
            else
                DW1 = -anglefun(Im_DW1.*conj(Rf_DW1))* corr*MI.CGcam.alpha(IL(ii).lambda);
                DW2 = -anglefun(Im_DW2.*conj(Rf_DW2))* corr*MI.CGcam.alpha(IL(ii).lambda);
            end
            DWx = cropParam1.angle.cos*DW1-cropParam1.angle.sin*DW2;
            DWy = cropParam1.angle.sin*DW1+cropParam1.angle.cos*DW2;

            if strcmpi(dzc,'mask')
                hfig = figure;
                imageph(integration(DWx,DWy))
                roi = drawpolygon();
                mask = createMask(roi);
                DWx(mask) = 0;
                DWy(mask) = 0;
                close(hfig)
            elseif isnumeric(dzc)
                DWx(T < dzc) = 0;
                DWy(T < dzc) = 0;
            else
                error('Wrong value for darkZoneCorrection')
            end
        end

        % artificial aberrations
        %[Ny, Nx]=size(DWx);
        %[X,~]=meshgrid(1:Nx,1:Ny);
        %n=3;
        %Cxn=cos(n*2*pi*X/(2*Nx));
        %DWx = DWx + Cxn*3e-10;


        DWx = DWx-mean( DWx(:));
        DWy = DWy-mean( DWy(:));

        if opt.computeW

            if ii>=2,tic,end
            if strcmpi(opt.method,'CPM')
                W = intgrad_CPM(DWx,DWy);
            elseif strcmpi(opt.method,'Errico')
                W = intgrad2(DWx,DWy);
            elseif strcmpi(opt.method,'ASDI')
                mg = 0; % margin
                DWxLarge = [-DWx(end-mg:-1:1+mg,end-mg:-1:1+mg),-DWx(end-mg:-1:1+mg,1+mg:end-mg) ;
                    DWx(1+mg:end-mg,end-mg:-1:1+mg) ,   DWx(1+mg:end-mg,   1+mg:end-mg)];
                DWyLarge = [-DWy(end-mg:-1:1+mg,end-mg:-1:1+mg), DWy(end-mg:-1:1+mg,1+mg:end-mg) ;
                    -DWy(1+mg:end-mg,end-mg:-1:1+mg) ,   DWy(1+mg:end-mg,   1+mg:end-mg)];
                WLarge = intgrad_CPM(DWxLarge,DWyLarge);
                W = WLarge(size(DWxLarge,1)/2+1:end,size(DWxLarge,2)/2+1:end);
            elseif strcmpi(opt.method,'Tikhonov')
                N = 13;
                Tikh = 1e-5;

                if (size(DWx,1)~=Nx0 || size(DWy,2)~=Ny0) || isempty(opt.Smatrix)  % if first time S calculation (Nx0 and Ny0 not yet defined), but not if S already exists because specified by the user
                    x = (1:size(DWx,2))';
                    y = (1:size(DWy,1))';
                    opt.Smatrix = g2sTikhonovRTalpha(x,y,N);
                    Nx0 = size(DWx,1);
                    Ny0 = size(DWy,2);
                end
                W = g2sTikhonovRT(DWx,DWy,opt.Smatrix,Tikh);
                DWx = DWx/MI.pxSize;
                DWy = DWy/MI.pxSize;
            end
        else
            W = [];
        end

        if ii>=2 && opt.displayBar && ip == 1
            waitbar(ii/Nf,fwb,sprintf('Image processing duration: %.3f s',toc))
        end

        if opt.computeIM % if compute both intensity and wavefront, create the ImageQLSI object
            if isempty(opt.remotePath)
                IM(ii,ip) = ImageQLSI(T,W,MI,Methods.duplicate(IL(ii)),imageNumber=Itfi.imageNumber);
            else
                IM(ii,ip) = ImageQLSI(T,W,MI,Methods.duplicate(IL(ii)),"remotePath",opt.remotePath,"fileName",removeExtension(Itfi.fileName),imageNumber=Itfi.imageNumber);
            end
%            IM(ii,ip).Interfero = Itfi;

            IM(ii,ip).Microscope = Methods.duplicate(MI); % copy of MI because, as an handle object, MI may change for some reason after the computation of the image.
            IM(ii,ip).binningFactor = Itf(ii,ip).binningFactor;

            if strcmpi(opt.definition,'low')
                IM(ii,ip).pxSizeCorrection = corr;
            end

            IM(ii,ip) = IM(ii,ip).setFcrops([cropParam0, cropParam1, cropParam2]);
            IM(ii,ip) = IM(ii,ip).setProcessingSoftware('PhaseLAB');

            if opt.saveGradients
                IM(ii,ip).DWx0 = DWx;
                IM(ii,ip).DWy0 = DWy;
            end

            IM(ii,ip).ItfFileName = Itf(ii,ip).fileName;
            IM(ii,ip).comment = Itf(ii,ip).comment;
            IM(ii,ip).channel = Itf(ii,ip).channel;
        end
        %    if updateRefFcrop==1
        if ~opt.noRef
            Itfi.Ref.Fcrops = [cropParam0; cropParam1; cropParam2];
        end
        if cropParam1.zeta - MI.CGcam.zeta>0.05
            warning('the zeta measured and theoretical values are much different\n')
            fprintf(['Measured zeta factor: ' num2str(cropParam1.zeta) '\n'])
            fprintf(['Theo. zeta factor   : ' num2str(MI.CGcam.zeta) '\n'])
        end
        %    end


        if Nf > 1
            fprintf('\n')
        end

        if opt.sizeMustBeEven
            if ~isEven(IM(ii,ip).Nx)
                IM(ii,ip).crop("xy1",[1,1],"xy2",[IM(ii,ip).Nx-1,IM(ii,ip).Ny]);
            end
            if ~isEven(IM(ii,ip).Ny)
                IM(ii,ip).crop("xy1",[1,1],"xy2",[IM(ii,ip).Nx,IM(ii,ip).Ny-1]);
            end
        end

    end
end

if Nf >= 2 && opt.displayBar && ip == Np % delete waitbar
    delete(fwb)
end

% if opt.computeIM % ie if IM has been defined
%     IM = reshape(IM,size(Itf)); % in case the Itf was an N*M array of interferos, i.e., in case there are channels
% end


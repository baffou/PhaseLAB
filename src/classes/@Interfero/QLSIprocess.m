% Method of the Interfero class.

function [IM,DWx,DWy,Im_int] = QLSIprocess(Itf,IL,opt)
arguments
    Itf Interfero
    IL % Illumination object or wavelength
    opt.Fcrops = []
    opt.crop = []
    opt.method char {mustBeMember(opt.method,{'Tikhonov','Errico','CPM'})} = 'Tikhonov'
    opt.definition char {mustBeMember(opt.definition,{'high','low'})} = 'high'
    opt.Fcropshape char {mustBeMember(opt.Fcropshape,{'disc','square'})} = 'disc'
    opt.Smatrix = []
    opt.apodization = false        % true, 1, or the width of the apodization in px
    opt.saveGradients = false
    opt.remotePath = []
    opt.Tnormalisation = true % or false or 'subtraction'
    opt.RemoveCameraOffset = false
    opt.auto = true % Find automatically the spot of highest intensity
    opt.noRef = false % Do not consider the Ref interferogram to compute the DW and OPD images
    opt.CGdistanceList = []  % the grating distance was varied during the acquisition of the images list
    opt.resetCrops logical = false % reset crops between each image calculation, to make sure the algorithm enable the user to click for each image, or force the detection of the spot for each image in the auto mode.
    opt.unwrap (1,1) logical = false % use unwrapping. Slows down a bit the processing.
end
Nf = numel(Itf);
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

IM = repmat(ImageQLSI(),Nf,1);
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
    cropParam0 = FcropParameters(Itf(1).Nx/2+1,Itf(1).Ny/2+1,[],Itf(1).Nx,Itf(1).Ny);
    cropParam1 = FcropParameters([],[],[],Itf(1).Nx,Itf(1).Ny);
    cropParam2 = FcropParameters([],[],[],Itf(1).Nx,Itf(1).Ny);
end
Nx0 = 0;
Ny0 = 0;

for ii = 1:Nf

    if Nf>1
        fprintf('Interfero %d / %d, ',ii,Nf)
    end

    % cancels the offset of the camera
    if isnumeric(opt.RemoveCameraOffset) && opt.RemoveCameraOffset~=1 % an offset is set manually
        offset = opt.RemoveCameraOffset;
    elseif opt.RemoveCameraOffset % if true
        offset = Itf(1).Microscope.CGcam.Camera.offset;
    else
        offset = 0;
    end




    if ~isempty(opt.crop)
        if ischar(opt.crop) % ie manual
            hroi = figure;
            set(hroi,'Visible','on') % in case a liveeditor program is used
            imagegb(imgaussfilt(Itf(ii).Itf,2)./imgaussfilt(Itf(ii).Ref.Itf,2))
            roi = drawrectangle;
            x1 = round(roi.Position(1));
            x2 = round(roi.Position(1)+roi.Position(3));
            y1 = round(roi.Position(2));
            y2 = round(roi.Position(2)+roi.Position(4));
            close(hroi)
            Itfi = Itf(ii).crop([x1 y1],[x2 y2]);
            opt.crop = [x1;y1;x2;y2];
        else
            Itfi = Itf(ii).crop(opt.crop(1:2),opt.crop(3:4));
        end
    else
        Itfi = Itf(ii);
    end
    
    if ii==2
        fwb = waitbar(0,'1','Name','Image processing...',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(fwb,'canceling',0);
    end
    
    if ii>=2
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
        cropParam0 = FcropParameters(Nx/2+1,Ny/2+1,[],Nx,Ny);
        cropParam1 = FcropParameters([],[],[],Nx,Ny);
        cropParam2 = FcropParameters([],[],[],Nx,Ny);
        opt.Smatrix=[];
    end

    if opt.resetCrops % force to reset the crops between each simulations, for instance when the angle of the grating changes, which cannot be detected by looking only at MI.
        cropParam0 = FcropParameters(Nx/2+1,Ny/2+1,[],Nx,Ny);
        cropParam1 = FcropParameters([],[],[],Nx,Ny);
        cropParam2 = FcropParameters([],[],[],Nx,Ny);
    end
    


    if opt.apodization % if apodization required
        fprintf("apodization \n")
        if opt.apodization == 1 % if apo value not specified, then equals 20
            apoNpx = 20;
        else
            apoNpx = opt.apodization;
        end
        [~,mask] = apodization(Itfi.Itf,apoNpx);

        FIm = fftshift(fft2(Itfi.Itf.*mask));
        if Itfi.Ref.TFapo == apoNpx  % if the apo TF has already been calculated for Ref and matches the one of the Itf
            FRf = Itfi.Ref.TF;
        else   % else calculate the TF of the Ref with apodization
            Itfi.Ref.computeTF(apoNpx)
            FRf = Itfi.Ref.TF;
        end

    else
        FIm = fftshift(fft2(Itfi.Itf));
        if ~opt.noRef
            FRf = Itfi.Ref.TF;
        else
            FRf = FIm*0;
        end
    end

    if isempty(FRf) && ~opt.noRef
        computeTF(Itfi.Ref);
        if ~opt.noRef
            FRf = Itfi.Ref.TF;
        else
            FRf = FIm*0;
        end
    end

    %    fprintf('ZERO ORDER\n')
    zeta = Itfi.Microscope.CGcam.zeta;

    if ~isequal(size(FIm),size(FRf))
        pause(1)
    end

    [FImc,FRfc,cropParam0] = FourierCrop(FIm,FRf,zeta,Fcrops=cropParam0,definition=opt.definition,FcropShape=opt.Fcropshape,auto=opt.auto);

    Im_int = ifft2(ifftshift(FImc));
    Rf_int = ifft2(ifftshift(FRfc));

    %    fprintf('FIRST ORDER ALONG XD\n')
    cropParam1.R = cropParam0.R;
    cropParam2.R = cropParam0.R;
    [FImc,FRfc,cropParam1] = FourierCrop(FIm,FRf,Fcrops=cropParam1,definition=opt.definition,FcropShape=opt.Fcropshape,auto=opt.auto);
    

    %figure('Name','QLSIprocess.m/ TF Fourier crop 1st order'),imagetf(FImc)
    
    Im_DW1 = ifft2(ifftshift(FImc));
    Rf_DW1 = ifft2(ifftshift(FRfc));

    % fprintf('FIRST ORDER ALONG YD\n')
    cropParam2 = cropParam1.rotate90();
    [FImc,FRfc,cropParam2] = FourierCrop(FIm,FRf,Fcrops=cropParam2,definition=opt.definition,FcropShape=opt.Fcropshape);
    
    Im_DW2 = ifft2(ifftshift(FImc));
    Rf_DW2 = ifft2(ifftshift(FRfc));
   
    % intensity image
    if strcmpi(opt.Tnormalisation,'subtraction')
        Int = abs(Im_int-offset) - abs(Rf_int-offset);
    elseif opt.Tnormalisation
        Int = abs(Im_int-offset)./abs(Rf_int-offset);
    else
        Int = abs(Im_int-offset);
    end
    
    % phase gradient images

%    DW1 = sign(MI.CGcam.zoom)*angle(Im_DW1.*conj(Rf_DW1))* MI.CGcam.alpha(IL(ii).lambda);
%    DW2 = sign(MI.CGcam.zoom)*angle(Im_DW2.*conj(Rf_DW2))* MI.CGcam.alpha(IL(ii).lambda);
    if opt.noRef
        DW1 = -anglefun(Im_DW1)* MI.CGcam.alpha(IL(ii).lambda);
        DW2 = -anglefun(Im_DW2)* MI.CGcam.alpha(IL(ii).lambda);
    else
        DW1 = -anglefun(Im_DW1.*conj(Rf_DW1))* MI.CGcam.alpha(IL(ii).lambda);
        DW2 = -anglefun(Im_DW2.*conj(Rf_DW2))* MI.CGcam.alpha(IL(ii).lambda);
    end
    DWx = cropParam1.angle.cos*DW1-cropParam1.angle.sin*DW2;
    DWy = cropParam1.angle.sin*DW1+cropParam1.angle.cos*DW2;


    % artificial aberrations
    %[Ny, Nx]=size(DWx);
    %[X,~]=meshgrid(1:Nx,1:Ny);
    %n=3;
    %Cxn=cos(n*2*pi*X/(2*Nx));
    %DWx = DWx + Cxn*3e-10;


    DWx = DWx-mean( DWx(:));
    DWy = DWy-mean( DWy(:));

    if ii>=2,tic,end
    if strcmpi(opt.method,'CPM')
        W = intgrad_CPM(DWx,DWy);
    elseif strcmpi(opt.method,'Errico')
        W = intgrad2(DWx,DWy);
    elseif strcmpi(opt.method,'Tikhonov')

        if strcmpi(opt.definition,'low')
            N = 13;
            Tikh = 1e-5;
        else
            N = 3;
            Tikh = 1e-5;
        end

        if (size(DWx,1)~=Nx0 || size(DWy,2)~=Ny0) && isempty(opt.Smatrix)  % if first time S calculation (Nx0 and Ny0 not yet defined), but not if S already exists because specified by the user
            x = (1:size(DWx,2))';
            y = (1:size(DWy,1))';
            opt.Smatrix = g2sTikhonovRTalpha(x,y,N);
            Nx0 = size(DWx,1);
            Ny0 = size(DWy,2);
        end
        W = g2sTikhonovRT(DWx,DWy,opt.Smatrix,Tikh);
    end

    if ii>=2
        waitbar(ii/Nf,fwb,sprintf('Image processing duration: %.3f s',toc))
    end
    
    if strcmpi(opt.definition,'low') % compute the correction factor in case the image is small (fast mode)
        rx = cropParam2.R(1);
        corr = Nx/length(round((-rx:rx-1)));
    else
        corr = 1;
    end
    
    if isempty(opt.remotePath)
        IM(ii) = ImageQLSI(Int,W*corr,MI,duplicate(IL(ii)),imageNumber=Itfi.imageNumber);
    else
        IM(ii) = ImageQLSI(Int,W*corr,MI,duplicate(IL(ii)),"remotePath",opt.remotePath,"fileName",removeExtension(Itfi.fileName),imageNumber=Itfi.imageNumber);
    end

    IM(ii).Microscope = duplicate(MI); % copy of MI because, as an handle object, MI may change for some reason after the computation of the image.

    if strcmpi(opt.definition,'low')
        IM(ii).pxSizeCorrection=corr;
    end
    
    IM(ii) = IM(ii).setFcrops([cropParam0, cropParam1, cropParam2]);
    IM(ii) = IM(ii).setProcessingSoftware('PhaseLAB');

    if opt.saveGradients
        IM(ii).DWx0 = DWx;
        IM(ii).DWy0 = DWy;
    end
    
%    if updateRefFcrop==1
        if ~opt.noRef
            Itfi.Ref.Fcrops = [cropParam0; cropParam1; cropParam2];
        end
        if cropParam1.zeta-MI.CGcam.zeta>0.05
            warning('the zeta measured and theoretical values are much different\n')
        fprintf(['Measured zeta factor: ' num2str(cropParam1.zeta) '\n'])
        fprintf(['Theo. zeta factor   : ' num2str(MI.CGcam.zeta) '\n'])
        end
%    end

    IM(ii).ItfFileName = Itf(ii).fileName;
    IM(ii).comment = Itf(ii).comment;
    IM(ii).channel = Itf(ii).channel;

   if Nf>1
       fprintf('\n')
   end
end

if Nf>=2 % delete waitbar
    delete(fwb)
end

IM = reshape(IM,size(Itf)); % in case the Itf was an N*M array of interferos, i.e., in case there are channels

end

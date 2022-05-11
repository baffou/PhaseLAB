% Method of the Interfero class.

function [IM,DWx,DWy]=QLSIprocess(Itf,IL,opt)
arguments
    Itf Interfero
    IL % Illumination object or wavelength
    opt.Fcrops = []
    opt.crop = []
    opt.method char {mustBeMember(opt.method,{'Tikhonov','Errico','CPM'})} = 'Tikhonov'
    opt.resolution char {mustBeMember(opt.resolution,{'high','low'})} = 'high'
    opt.Fcropshape char {mustBeMember(opt.Fcropshape,{'disc','square'})} = 'disc'
    opt.Smatrix {mustBeNumeric} = []
    opt.saveGradients = false
end
Nf=numel(Itf);
%% Shaping of the Illumination object(s)
if isa(IL,'Illumination')
elseif isnumeric(IL) % if IL is a wavelength
    IL=Illumination(IL);
else
    error('error with the thrid input must be an Illumination object or a wavelength')
end

if numel(IL)==1
    if length(IL.lambda)==1
        IL=repmat(IL,Nf,1);
    elseif length(IL.lambda)~=Nf
        error(['The number of Interferos (' num2str(Nf) ') is not the number of specified lambda (' num2str(length(IL.lambda)) ')'])
    else % single IL object, but with a list of lambda
        IList=repmat(IL,Nf,1);
        for il=1:Nf
            IList(il)=Illumination(IL.lambda(il),Medium(IL.n,IL.nS),IL.I,IL.polar);
        end
        IL=IList;
    end
elseif numel(IL)~=Nf
    error(['The number of images (' num2str(Nf) ') is not the number Illumination objects (' num2str(length(IL)) ')'])
end

%% shaping of the crops
updateRefFcrop=0;

IM=repmat(ImageQLSI(),Nf,1);
if ~isempty(opt.Fcrops) % If crops are defined within the options
    if numel(opt.Fcrops)~=3
        error('cropping parameters must be a 3-cell array.')
    end
    if isa(opt.Fcrops(1),'FcropParameters') && isa(opt.Fcrops(2),'FcropParameters') && isa(opt.Fcrops(3),'FcropParameters')
        cropParam0=opt.Fcrops(1);
        cropParam1=opt.Fcrops(2);
        cropParam2=opt.Fcrops(3);
    else
        opt.Fcrops(1)
        error('not FcropParameters objects')
    end
elseif ~isempty(Itf(1).Ref.Fcrops(1).Nx) % if the ref already has crops
    cropParam0=Itf(1).Ref.Fcrops(1);
    cropParam1=Itf(1).Ref.Fcrops(2);
    cropParam2=Itf(1).Ref.Fcrops(3);
else % if crops are not defined anywhere
    updateRefFcrop=1;
    cropParam0=FcropParameters(Itf(1).Nx/2+1,Itf(1).Ny/2+1,[],Itf(1).Nx,Itf(1).Ny);
    cropParam1=FcropParameters([],[],[],Itf(1).Nx,Itf(1).Ny);
    cropParam2=FcropParameters([],[],[],Itf(1).Nx,Itf(1).Ny);
end
Nx0=0;
Ny0=0;

for ii=1:Nf
    if ~isempty(opt.crop)
        if ischar(opt.crop) % ie manual
            hroi=figure;
            set(hroi,'Visible','on') % in case a liveeditor program is used
            imagegb(imgaussfilt(Itf(ii).Itf,2)./imgaussfilt(Itf(ii).Ref.Itf,2))
            roi = drawrectangle;
            x1=round(roi.Position(1));
            x2=round(roi.Position(1)+roi.Position(3));
            y1=round(roi.Position(2));
            y2=round(roi.Position(2)+roi.Position(4));
            close(hroi)
            Itfi=Itf(ii).crop([x1 y1],[x2 y2]);
            opt.crop=[x1;y1;x2;y2];
        else
            Itfi=Itf(ii).crop(opt.crop(1:2),opt.crop(3:4));
        end
    else
        Itfi=Itf(ii);
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
        error(['the reference of the interferogram number ' num2str(ii) ' is empty'])
    end
    
    MI=Itfi.Microscope;
    
    Nx=Itfi.Nx;
    Ny=Itfi.Ny;
    if Nx~=cropParam0.Nx || Ny~=cropParam0.Ny % check if the image size changed compared with the previous one, and reinitialize the parameters in case it did.
        cropParam0 = FcropParameters(Nx/2+1,Ny/2+1,[],Nx,Ny);
        cropParam1 = FcropParameters([],[],[],Nx,Ny);
        cropParam2 = FcropParameters([],[],[],Nx,Ny);
    end
    
    FIm = fftshift(fft2(Itfi.Itf));
    FRf = Itfi.Ref.TF;
    
    %    fprintf('ZERO ORDER\n')
    zeta=Itfi.Microscope.CGcam.zeta;
    [FImc,FRfc,cropParam0] = FourierCrop(FIm,FRf,zeta,Fcrops=cropParam0,resolution=opt.resolution,FcropShape=opt.Fcropshape);

    Im_int = ifft2(ifftshift(FImc));
    Rf_int = ifft2(ifftshift(FRfc));

    %    fprintf('FIRST ORDER ALONG XD\n')
    cropParam1.R = cropParam0.R;
    cropParam2.R = cropParam0.R;
    [FImc,FRfc,cropParam1] = FourierCrop(FIm,FRf,Fcrops=cropParam1,resolution=opt.resolution,FcropShape=opt.Fcropshape);
    %figure('Name','QLSIprocess.m/ TF Fourier crop 1st order'),imagetf(FImc)
    
    Im_DW1 = ifft2(ifftshift(FImc));
    Rf_DW1 = ifft2(ifftshift(FRfc));

    % fprintf('FIRST ORDER ALONG YD\n')
    cropParam2=cropParam1.rotate90();
    [FImc,FRfc,cropParam2] = FourierCrop(FIm,FRf,Fcrops=cropParam2,resolution=opt.resolution,FcropShape=opt.Fcropshape);
    
    Im_DW2 = ifft2(ifftshift(FImc));
    Rf_DW2 = ifft2(ifftshift(FRfc));
   
    % intensity image
    Int=abs(Im_int)./abs(Rf_int);

    
    % phase gradient images

    DW1=sign(MI.CGcam.RL.zoom)*angle(Im_DW1.*conj(Rf_DW1))* MI.CGcam.alpha(IL(ii).lambda);
    DW2=sign(MI.CGcam.RL.zoom)*angle(Im_DW2.*conj(Rf_DW2))* MI.CGcam.alpha(IL(ii).lambda);

    DWx=cropParam1.angle.cos*DW1-cropParam1.angle.sin*DW2;
    DWy=cropParam1.angle.sin*DW1+cropParam1.angle.cos*DW2;

    DWx= DWx-mean( DWx(:));
    DWy= DWy-mean( DWy(:));

    if ii>=2,tic,end
    if strcmpi(opt.method,'CPM')
        DWx=DWx/Itfi.CGcam.zeta;
        DWy=DWy/Itfi.CGcam.zeta;
        W=intgrad_CPM(DWx,DWy);
    elseif strcmpi(opt.method,'Errico')
        DWx=DWx/Itfi.CGcam.zeta;
        DWy=DWy/Itfi.CGcam.zeta;
        W=intgrad2(DWx,DWy);
    elseif strcmpi(opt.method,'Tikhonov')

        if strcmpi(opt.resolution,'low')
            N=13;
            Tikh=1e-5;
        else
            N=3;
            Tikh=1e-5;
        end

        if (size(DWx,1)~=Nx0 || size(DWy,2)~=Ny0) && isempty(opt.Smatrix)  % if first time S calculation (Nx0 and Ny0 not yet defined), but not if S already exists
            x=(1:size(DWx,2))';
            y=(1:size(DWy,1))';
            opt.Smatrix=g2sTikhonovRTalpha(x,y,N);
            Nx0=size(DWx,1);
            Ny0=size(DWy,2);
        end
        W=g2sTikhonovRT(DWx,DWy,opt.Smatrix,Tikh);
    end

    if ii>=2
        waitbar(ii/Nf,fwb,sprintf('Image processing duration: %.3f s',toc))
    end
    
    if strcmpi(opt.resolution,'low') % compute the correction factor in case the image is small (fast mode)
        rx=cropParam2.R(1);
        corr=Nx/length(round((-rx:rx-1)));
    else
        corr=1;
    end

    IM(ii)=ImageQLSI(Int,W*corr,MI,IL(ii));
    IM(ii).Microscope=MI;
    if strcmpi(opt.resolution,'low')
        IM(ii).pxSize0=MI.pxSizeItf()*corr;
    elseif strcmpi(opt.resolution,'high')
        IM(ii).pxSize0=MI.pxSizeItf();
    else
        error('wrong value of resolution')
    end
    IM(ii).TfileName=Itfi.fileName;
    IM(ii).OPDfileName=Itfi.fileName;
    IM(ii)=IM(ii).setFcrops([cropParam0, cropParam1, cropParam2]);
    IM(ii)=IM(ii).setProcessingSoftware('PhaseLAB');

    if opt.saveGradients
        IM(ii).DWx=DWx;
        IM(ii).DWy=DWy;
    end
    
    if updateRefFcrop==1
        Itfi.Ref.Fcrops=[cropParam0; cropParam1; cropParam2];
    end

end

if Nf>=2
    delete(fwb)
end


end

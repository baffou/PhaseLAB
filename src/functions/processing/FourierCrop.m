function [SImout, SRfout, cropParamsout] = FourierCrop(FItf,FRef,zeta,opt)
% Imout: the image, the Fourier transform of which has been croped
% Rfout: the reference image, which has undergone the same crop
% cropParams: the parameters of the crop
% possible flags are
    % 'cropParams'
    % 'cropShape'   : 'disc' or 'square'
arguments
FItf (:,:) {mustBeNumeric} 
FRef (:,:) {mustBeNumeric, mustBeEqualSize(FItf,FRef)} 
zeta (1,1) double = 3
opt.Fcrops FcropParameters
opt.FcropShape = 'disc'
opt.definition = 'high'
opt.auto = false
end

if size(FItf)~=size(FRef)
    size(FItf)
    size(FRef)
    error('Interferogram and reference images do not have the same size')
end
[Ny,Nx] = size(FItf);
ex = Nx/Ny; % the ellipse excentricity

%if nargin==2
%    cropParams=FcropParameters(0,0,0,size(Itf(1).Itf,2),size(Itf(1).Itf,1));
%end
Fcrops = opt.Fcrops;
definition = opt.definition;
FcropShape = opt.FcropShape;
if strcmp(FcropShape,'disc')
    drawCrop = @drawCircle;
else
    drawCrop = @drawRectangle;
end    

%% zoom on the spot of interest
if isempty(Fcrops.R) && (isempty(Fcrops.x) || isempty(Fcrops.y)) % No parameter specified
    h = figure;
    set(h,'Visible','on')
    imagetf(FItf,'log10')
    %sound:
%    Fs = 8192;t = 0:1/Fs:1;y=sin(2*pi*440*erf(t));soundsc(y)
    
    title('Zoom in on the order of interest, and click enter')
    zoom on
    waitfor(gcf,'CurrentCharacter',char(13))
    title('Click on the order''s center pixel')
    
    button = 0;
    while button~=1
        [x1,y1,button] = ginput(1);
    end

    %close(h)
    set(gcf,'CurrentCharacter',char(0))
    zoom out
    title('Click further away to define a crop radius around this order')
    [x2,y2] = ginput(1);

    % radius
    R(1) = sqrt((x2-x1)^2+ex^2*(y2-y1)^2);
    R(2) = R(1)/ex;

    h = drawCrop(x1,y1,R,h);
    drawnow
    close(h)
    cropParamsout = FcropParameters(x1,y1,R,Nx,Ny);
elseif isempty(Fcrops.R) % The center of the crop is specified, but not the radius.
    h = figure;
    set(h,'Visible','on')
    imagetf(FItf,'log10')
%    Fs = 8192;t = 0:1/Fs:1;y=sin(2*pi*440*erf(t));soundsc(y)
    
    x0 = Fcrops.x;
    y0 = Fcrops.y;
    
    x1 = x0;
    y1 = y0;
    R(1) = Nx/(2*zeta);
    R(2) = Nx/(2*zeta)/ex;
    h = drawCrop(x1,y1,R,h);
    drawnow
    if ~opt.auto
        button = 0;
        while button~=1
            [x2,y2,button] = ginput(1);
            if button == 1
                button = 1;
                R(1) = sqrt((x2-x1)^2+ex^2*(y2-y1)^2);
                R(2) = R(1)/ex;
            elseif isempty(button) || button==13 % press carriage return, keep original R=Nx/3
                button = 1;
            end
        end
    end
    h = drawCrop(x1,y1,R,h);
    drawnow
    pause(0.5)
    close(h)
    cropParamsout = FcropParameters(x1,y1,R,Nx,Ny);
    
    
elseif isempty(Fcrops.x) || isempty(Fcrops.y) % no center position, but R determined
    h = figure;
    set(h,'Visible','on')
    imagetf(FItf,'log10')
%    Fs = 8192;t = 0:1/Fs:1;y=sin(2*pi*440*erf(t));soundsc(y)
    if opt.auto % auto selection of the first order
        [XX, YY]=meshgrid(1:Nx,1:Ny);
        XX=ceil(XX-mean(XX(:)));
        YY=ceil(YY-mean(YY(:)));
        RR=sqrt(XX.*XX+YY.*YY*(Fcrops.R(1)/Fcrops.R(2))^2);
        [x1,y1]=maxPix(abs(FItf).*(XX>0).*(YY>=0).*double((RR>1.8*Fcrops.R(1))).*double((RR<2.2*Fcrops.R(1))));
    else
        
        title('Zoom in on the order of interest, and click enter')
        zoom on
        waitfor(gcf,'CurrentCharacter',char(13))
        title('Click on the order center pixel')
        [x1,y1] = ginput(1);
    end
    R = Fcrops.R;
    h = drawCrop(x1,y1,R,h);
    h = drawCrop(size(FItf,2)/2,size(FItf,1)/2,R,h);
    
    zoom out
    drawnow
    
    pause(1)
    
    close(h)
    cropParamsout = FcropParameters(x1,y1,R,Nx,Ny);
    
else % The center and the radius are specified, so we just plot the crop and thats it.
    x0 = Fcrops.x;
    y0 = Fcrops.y;
    r0 = Fcrops.R;
    x1 = x0;
    y1 = y0;
    R = r0;
    cropParamsout = FcropParameters(x1,y1,R,Nx,Ny);
end

if strcmp(definition,'high')  % High definition (full image size)
    %% Center of the image on zero order of the Fourier space, recentered (demodulated, hence the circshift)

    if length(R)==1
        rx = R;
        ry = R;
    else
        rx = R(1);
        ry = R(2);
    end

    if strcmpi(FcropShape,'disc')
        [xx,yy] = meshgrid(1:Nx, 1:Ny);

        R2C = (xx  -Nx/2-1-cropParamsout.shiftx).^2/rx^2 + (yy - Ny/2-1-cropParamsout.shifty).^2/ry^2;
        circle = (R2C < 1); %mask circle for each iteration

        % demodulation in the Fourier space
        Imout = FItf.*circle;
        Rfout = FRef.*circle;
    elseif strcmpi(FcropShape,'square')
        [xx,yy] = meshgrid(1:Nx, 1:Ny);

        X2 = (xx  -Nx/2-1-cropParamsout.shiftx).^2/rx^2;
        Y2 = (yy - Ny/2-1-cropParamsout.shifty).^2/ry^2;
        bandX = (X2 < 1); %mask circle for each iteration
        bandY = (Y2 < 1); %mask circle for each iteration

        % demodulation in the Fourier space
        Imout = FItf.*bandX.*bandY;
        Rfout = FRef.*bandX.*bandY;
    end
    SImout = circshift(Imout,[-cropParamsout.shifty -cropParamsout.shiftx]);
    SRfout = circshift(Rfout,[-cropParamsout.shifty -cropParamsout.shiftx]);

elseif strcmp(definition,'low')
    if length(R)==1
        rx = R;
        ry = R;
    else
        rx = R(1);
        ry = R(2);
    end

%    SImout = FItf(round(Ny/2+cropParamsout.shifty + (-ryn:ryn-1)),round(Nx/2+cropParamsout.shiftx + (-rxn:rxn-1)));
%    SRfout = FRef(round(Ny/2+cropParamsout.shifty + (-ryn:ryn-1)),round(Nx/2+cropParamsout.shiftx + (-rxn:rxn-1)));

    SImout = FItf(cropParamsout.yrange , cropParamsout.xrange);
    SRfout = FRef(cropParamsout.yrange , cropParamsout.xrange);

    if strcmpi(FcropShape,'disc')

        [xx,yy] = meshgrid(1:size(SImout,2), 1:size(SImout,1));

        R2C = (xx  -size(SImout,2)/2-1).^2/rx^2 + (yy - size(SImout,1)/2-1).^2/ry^2;
        circle = (R2C < 1); %mask circle for each iteration

        % demodulation in the Fourier space
        SImout = SImout.*circle;
        SRfout = SRfout.*circle;  

    end
% de-griding (not necessary anymore if one use the
% FourierSpaceMultiplication formula
    [xx,yy] = meshgrid(1:size(SImout,2), 1:size(SImout,1));
    
    R2C = (xx  -size(SImout,2)/2-1).^2/rx^2 + (yy - size(SImout,1)/2-1).^2/ry^2;
    circle = (R2C < 0.05); %mask circle for each iteration
    mask = (1-circshift(circle,round(size(SImout,2)/2),2)).*(1-circshift(circle,round(size(SImout,1)/2),1));
    SImout = SImout.*mask;
    SRfout = SRfout.*mask;

end 
    
end

% Custom validation function
function mustBeEqualSize(a,b)
    % Test for equal size
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = 'Size of first input must equal size of second input.';
        throwAsCaller(MException(eid,msg))
    end
end


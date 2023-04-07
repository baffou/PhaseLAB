function [SImout, SRfout, cropParamsout] = FourierCropFast(Itf,Ref,cropParams)
%Imout: the image, the Fourier transform of which has been croped
%Rfout: the reference image, which has undergone the same crop
%cropParams: the parameters of the crop


if ~(nargin==2 || nargin==3)
    error('wrong number of inputs')
end

if size(Itf)~=size(Ref)
    size(Itf)
    size(Ref)
    error('Interferogram and reference images do not have the same size')
end
[Ny,Nx] = size(Itf);
ex = Nx/Ny; % the ellipse excentricity

if nargin==2
    cropParams = FcropParameters(0,0,0,Itf(1).Nx,Itf(1).Ny);
end


%% zoom on the spot of interest

if sum(cropParams.R)==0 && (cropParams.x==0 || cropParams.y==0) % No parameter specified
h = figure;
    set(h,'Visible','on')
    imagegb(log(abs(Itf)))
    %sound:
    Fs = 8192;t = 0:1/Fs:1;y = sin(2*pi*440*erf(t));soundsc(y)
    
    title('Zoom in on the order of interest, and click enter')
    zoom on
    waitfor(gcf,'CurrentCharacter',char(13))
    title('Click on the order''s center pixel')
    
    button = 0;
    while button~=1
        [x1,y1,button] = ginput(1);
    end
    
    close(h)
    set(gcf,'CurrentCharacter',char(0))
    zoom out
    title('Click further away to define a crop radius around this order')
    [x2,y2] = ginput(1);
    
    % radius
    R(1) = sqrt((x2-x1)^2+ex^2*(y2-y1)^2);
    R(2) = R(1)/ex;
    
    
    h = drawCircle(x1,y1,R,h);
    drawnow
    close(h)
    cropParamsout = FcropParameters(x1,y1,R,Nx,Ny);
    
    
elseif sum(cropParams.R)==0 % The center of the crop is specified, but not the radius.
h = figure;
    set(h,'Visible','on')
    imagegb(log(abs(Itf)))
    Fs = 8192;t = 0:1/Fs:1;y = sin(2*pi*440*erf(t));soundsc(y)
    
    x0 = cropParams.x;
    y0 = cropParams.y;
    
    x1 = x0;
    y1 = y0;
    R(1) = Nx/6;
    R(2) = Nx/6/ex;
    h = drawCircle(x1,y1,R,h);
    drawnow
    
    button = 0;
    while button~=1
        [x2,y2,button] = ginput(1);
        if button==1
            button = 1;
            R(1) = sqrt((x2-x1)^2+ex^2*(y2-y1)^2);
            R(2) = R(1)/ex;
        elseif isempty(button) || button==13 % press carriage return, keep original R = Nx/3
            button = 1;
        end
    end
    h = drawCircle(x1,y1,R,h);
    drawnow
    close(h)
    cropParamsout = FcropParameters(x1,y1,R,Nx,Ny);
    
    
elseif (cropParams.x==0 || cropParams.y==0) % no center position, but R determined
    h = figure;
    set(h,'Visible','on')
    imagegb(log(abs(Itf)))
    Fs = 8192;t = 0:1/Fs:1;y = sin(2*pi*440*erf(t));soundsc(y)
    
    title('Zoom in on the order of interest, and click enter')
    zoom on
    waitfor(gcf,'CurrentCharacter',char(13))
    title('Click on the order center pixel')
    [x1,y1] = ginput(1);
    
    R = cropParams.R;
    h = drawCircle(x1,y1,R,h);
    zoom out
    drawnow
    
    
    close(h)
    cropParamsout = FcropParameters(x1,y1,R,Nx,Ny);
    
else % The center and the radius are specified, so we just plot the crop and thats it.
    x0 = cropParams.x;
    y0 = cropParams.y;
    r0 = cropParams.R;
    x1 = x0;
    y1 = y0;
    R = r0;
    cropParamsout = FcropParameters(x1,y1,R,Nx,Ny);
end



%% Center of the image on zero order of the Fourier space, shifted by shift

if length(R)==1
    rx = R;
    ry = R;
else
    rx = R(1);
    ry = R(2);
end


SImout = Itf(round(Ny/2+cropParamsout.shifty + (-ry:ry-1)),round(Nx/2+cropParamsout.shiftx + (-rx:rx-1)));
SRfout = Ref(round(Ny/2+cropParamsout.shifty + (-ry:ry-1)),round(Nx/2+cropParamsout.shiftx + (-rx:rx-1)));



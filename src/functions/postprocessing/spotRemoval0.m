function [img,mask0] = spotRemoval0(img0,mask)
% remove spots in the Fourier space of an image in order to remove periodic
% artefacts

[Ny, Nx] = size(img0);

if nargin==1 % no predefined mask


    h = figure;
    %% zoom on the spot of interest
    button = 1;
    mask = ones(Ny,Nx);
    Zlim = 0;
    TF = fftshift(fft2(img0));    
    while(button==1)
    
        imagegb(log(abs(TF)))
        if Zlim==0
            Zlim = get(gca,'CLim');
        else
            set(gca,'CLim',Zlim);
        end
        title('Click on the center of the spot to be removed')

        [x1,y1,button] = ginput(1); % center
        if button==1
            set(gcf,'CurrentCharacter',char(0))
            zoom out
            title('Click further away to define a crop radius around this spot')
            [x2,y2] = ginput(1); % radius

            % radius
            ex = Nx/Ny; % the ellipse excentricity
            R(1) = sqrt((x2-x1)^2+ex^2*(y2-y1)^2);
            R(2) = R(1)/ex;


            h = drawCircle(x1,y1,R,h);
            pause (1.6)
            cropParamsout = FcropParameters(x1,y1,R,Nx,Ny);

            if length(R)==1
                rx = R;
                ry = R;
            else
                rx = R(1);
                ry = R(2);
            end

            [xx,yy] = meshgrid(1:Nx, 1:Ny);

            R2C = (xx  -Nx/2-1-cropParamsout.shiftx).^2/rx^2 + (yy - Ny/2-1-cropParamsout.shifty).^2/ry^2;
            circle1 = (R2C >= 1); %mask circle for each iteration
            R2C = (xx  -Nx/2-1+cropParamsout.shiftx).^2/rx^2 + (yy - Ny/2-1+cropParamsout.shifty).^2/ry^2;
            circle2 = (R2C >= 1); %mask circle for each iteration
            % demodulation in the Fourier space
            mask = mask.*double(circle1.*circle2);
            imagegb(log(abs(TF.*mask)))
            drawnow
            TF = TF.*circle1.*circle2;
        end
    end
    img = ifft2(ifftshift(TF.*circle1.*circle2));
    if nargout
        mask0 = mask;
    end
    close(h)
elseif nargin==2
    TF = fftshift(fft2(img0));
    img = ifft2(ifftshift(TF.*mask));
    mask0 = mask;
else
    error('not the proper number of inputs')
end

end


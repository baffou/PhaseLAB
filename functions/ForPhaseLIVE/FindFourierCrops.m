function [Fcrops] = FindFourierCrops(Interferos)
% FINDFOURIERCROPS Finds the [x,y] coordinate and the radius of crops for Interfero
%
% ARGUMENTS
%       Interferos - Array of Interfero object
%
% OUTPUTS 
%		Fcrops - Cell array of FCrops parameters - one for each Interfero
%
% SAMPLE:
%   FCrops = FindFourierCrops(Interferos); %Compute the fourier crops paramters
%	QLSIImage = Interferos.QLSIprocess('FourierCrop',FCrops); %Use the FCrops array in the QLSIprocess method
%   
%
% See also INTERFERO, QLSIPROCESS.
%
% Baptiste Marthy - 2021

    Fcrops = cell(length(Interferos),1);
    refineRadius = 0.75;
     %Size based calculus
    

    %Can change for each itf
    for k = 1:length(Interferos)
        Nx = Interferos(k).Nx; Ny = Interferos(k).Ny;
        [xx,yy] = meshgrid(1:Nx, 1:Ny);
        RappPixelSize = 0.5*Interferos(k).CGcam.CG.Gamma/Interferos(k).CGcam.Camera.pxSize;
        mat_fft = fftshift(fft2(Interferos(k).Itf));

        %Find Rx, Ry the radius of the ellips, add +/- pixels errors to search in 
        Rx_in = refineRadius * (Nx / (RappPixelSize * Interferos(k).CGcam.zoom) );
        Rx_out = (1/refineRadius) * (Nx / (RappPixelSize * Interferos(k).CGcam.zoom));
        Ry_in = refineRadius * (Ny / (RappPixelSize * Interferos(k).CGcam.zoom));
        Ry_out = (1/refineRadius) * (Ny / (RappPixelSize * Interferos(k).CGcam.zoom));

        %Mask the space in a ring shape maner between the two ellipses [Rx_in Ry_in] [Rx_in Rx_out]
        CircleMask_In = (xx - floor(Nx)/2 - 1).^2/Rx_in^2 + (yy - floor(Ny/2) - 1).^2/Ry_in^2 > 1;
        CircleMask_Out = (xx - floor(Nx/2) - 1).^2/Rx_out^2 + (yy - floor(Ny/2) - 1).^2/Ry_out^2 < 1;
        UpLeftMask = (xx < Nx/2) .* (yy < Ny/2);
        UpRightMask = (xx > Nx/2) .* (yy < Ny/2);
        
        %Crop the fft in the up left corner and the up right one
        croppedFFT_left = mat_fft .* CircleMask_In .* CircleMask_Out .* UpLeftMask;
        croppedFFT_right = mat_fft .* CircleMask_In .* CircleMask_Out .* UpRightMask;

        %Find the brighest point, get the coordinate
        boolMatriceMax_left = (croppedFFT_left==max(max(croppedFFT_left)));
        [y_left,x_left] = ind2sub(size(boolMatriceMax_left),find(boolMatriceMax_left,1));
        boolMatriceMax_right = (croppedFFT_right==max(max(croppedFFT_right)));
        [y_right,x_right] = ind2sub(size(boolMatriceMax_right),find(boolMatriceMax_right,1));
        
        %Compute the apparente zoom to adjust the crop radius
        dist = sqrt((floor(Nx/2+1) - x_left)^2 + ...
                    (floor(Ny/2+1) - y_left)^2);

        Zoom = ((Nx/2 - x_left)) / ...
            ( dist * (1/2 - x_left/Nx) * RappPixelSize);
        Rx = Nx / (2 * Interferos(k).CGcam.CG.Gamma * Zoom);
        Ry = Ny / (2 * Interferos(k).CGcam.CG.Gamma * Zoom);

        %Verify that the crops coordinate are not too big for the image
        [x_left,y_left,Rx,Ry] = coordinateValidation(x_left,y_left,Rx,Ry,Nx,Ny);
        [x_right,y_right,Rx,Ry] = coordinateValidation(x_right,y_right,Rx,Ry,Nx,Ny);

        %Build the 3 crops parameters
        Fcrops{k} = {...
            FcropParameters(floor(Nx/2+1),floor(Ny/2+1),[Rx Ry],Nx,Ny), ...
            FcropParameters(x_left,y_left,[Rx Ry],Nx,Ny), ....
            FcropParameters(x_right,y_right,[Rx Ry],Nx,Ny) ...
            };
    end
end

function [x,y,Rx,Ry] = coordinateValidation(x,y,Rx,Ry,Nx,Ny)
%Coordinate outside the image, put it in the center and warn the user
if x < 0 || x > Nx
    x = Nx/2;
    y = Ny/2;
    warning('ERROR : The (x) cropper coordinate is beyond the limits');
end
if y < 0 || y > Ny
    x = Nx/2;
    y = Ny/2;
    warning('ERROR : The (y) cropper coordinate is beyond the limits');
end
%The cropping will fail because it will crop outside the image -> Adapt Rx and Ry
if x - Rx < 0 || x + Rx > Nx
    Rx = min(x, Nx - x) - 1 ;
    Ry = Rx * (Ny  / Nx);
end
if y - Ry < 0 || y + Ry > Ny
    Ry = min(y, Ny - y) - 1 ;
    Rx = Ry * (Nx  / Ny);
end
end
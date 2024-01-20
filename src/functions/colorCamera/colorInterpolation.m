function ImInt=colorInterpolation(Im,color)
% Function that interpolates the image of a two-color interferogram into either the green or the red image.
arguments
    Im double % image to interpolate
    color char {mustBeMember(color,{'g','r','G','R','green','red','Green','Red'})} % color of the image, green or red
end


% creates the checkerboard pattern
cc = strcmpi(color(1),'g'); % = true if green, false if red.
[Ny, Nx]=size(Im);
[XX, YY]=meshgrid(1:Nx,1:Ny);
CBmask=mod(XX+YY,2)==cc;

% interpolation
I1=circshift(Im, 1, 1);
I2=circshift(Im,-1, 1);
I3=circshift(Im, 1, 2);
I4=circshift(Im,-1, 2);
ImInt=CBmask.*Im+~CBmask.*(I1+I2+I3+I4)/4;






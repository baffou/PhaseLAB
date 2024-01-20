function [x, y] = maxPix(im)
% function that returns the coordinates of the pixel of maximum value in
% the upper right corner of the image

[Ny, Nx] = size(im);

y_values = round(Ny/2+10) : Ny;
x_values = round(Nx/2+10) : Nx;

roi = abs(im(y_values, x_values));

[~ , max_idx] = max(roi(:));

[max_y, max_x] = ind2sub(size(roi), max_idx);

x = x_values(max_x);
y = y_values(max_y);

end


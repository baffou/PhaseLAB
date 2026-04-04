function [Z, d_coords] = plotPolylineCrosscut(hax,opt)
arguments
    hax = gca
    opt.Img = []
    opt.polyLine
end

% plotPolylineCrosscut - Lets the user draw a polyline on an axes
% and displays the intensity profile (crosscut) along that polyline.
%
% Usage:
%   plotPolylineCrosscut(gca)


% Retrieve the image object from the axes
if isempty(opt.Img)
    img = findobj(hax, 'Type', 'image');
    if isempty(img)
        error('No image found in the provided axes.');
    end
    I = img.CData;
else
    I = opt.Img
end

% Ask the user to draw a polyline
h = drawpolyline(hax, 'Color', 'r');
pos = h.Position; % Nx2 array [x y]

% Extract x and y coordinates
x = pos(:,1);
y = pos(:,2);

% Compute cumulative distance along the polyline (in pixels)
d = [0; cumsum(sqrt(diff(x).^2 + diff(y).^2))];

% Resample the line with ~1 pixel spacing
d_query = linspace(0, d(end), round(d(end)));
xq = interp1(d, x, d_query);
yq = interp1(d, y, d_query);

% Interpolate image intensities along the polyline (bilinear interpolation)
profile = interp2(double(I), xq, yq, 'linear');

% Plot the intensity profile
figure;
plot(d_query, profile, 'LineWidth', 1.5);
xlabel('Distance (pixels)');
ylabel('Intensity');
title('Intensity profile along the polyline');
grid on;

if nargout
    Z = profile;
    d_coords = d_query;
end

end

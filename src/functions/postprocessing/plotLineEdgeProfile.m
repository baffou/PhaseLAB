function [Z, hline] = plotLineEdgeProfile(hax,crosscutDirection,opt)
arguments
    hax = gca
    crosscutDirection {mustBeMember(crosscutDirection,{'x','y'})} = 'x'
    opt.Img = []
    opt.hline = []
    opt.color = 'r'
    opt.width = 50
    opt.xy = []
end

% plotLineEdgeprofile - Lets the user draw a polyline on an axes
% and displays the edge profile along that polyline.
%
% Usage:
%   plotPolylineEdgeProfile(gca)


% Retrieve the image object from the axes
if isempty(opt.Img)
    img = findobj(hax, 'Type', 'image');
    if isempty(img)
        error('No image found in the provided axes.');
    end
    I = img.CData;
else
    I = opt.Img;
end


if isempty(opt.xy)
    % Ask the user to draw a polyline
    if isempty(opt.hline)
        hline = drawline(hax, 'Color', opt.color);
    else
        hline = opt.hline;
    end
    xy = hline.Position; % Nx2 array [x y]
else
    xy = opt.xy;
end


profile = edgeExtraction(I, crosscutDirection, 'xy',xy,'display',false,'width',opt.width);



if nargout
    Z = profile;
end

end

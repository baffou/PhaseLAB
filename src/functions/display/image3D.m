function image3D(varargin)
% image3D(image)
% image3D(AxesHandle, image)
% image3D(x, y, image)
% image3D(AxesHandle, x, y, image)

if nargin == 1 % image3D(image)
    ha = gca;
    im=varargin{1};
    x = 1:size(im,2);
    y = 1:size(im,1);
elseif nargin == 3 % image3D(image)
    ha = gca;
    x = varargin{1};
    y = varargin{2};
    im = varargin{3};
end

if nargin == 2 % image3D(AxesHandle, image)
    ha = varargin{1};
    im = varargin{2};
    x = 1:size(im,2);
    y = 1:size(im,1);
elseif nargin == 4 % image3D(AxesHandle, x, y image)
    ha = varargin{1};
    x = varargin{2};
    y = varargin{3};
    im = varargin{4};
end

surf(ha, x, y, im,'FaceColor','interp','EdgeColor','none',...
                        'FaceLighting','gouraud')

view(ha,2)
camlight(ha,30,25)

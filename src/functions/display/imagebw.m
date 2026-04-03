function him = imagebw(varargin,opt)
arguments(Repeating)
    varargin
end
arguments
    opt.ax = gca
    opt.reverseColor = false
end

if nargin == 1
    W = varargin{1};
elseif nargin == 3
    xx = varargin{1};
    yy = varargin{2};
    W = varargin{3};
else
    error('not the proper number of inputs')
end

if nargout
    if nargin == 3
        him = imagesc(opt.ax,xx,yy,real(W));
    else
        him = imagesc(opt.ax,real(W));
    end        
else
    if nargin == 3
        imagesc(opt.ax,xx,yy,real(W));
    else
        imagesc(opt.ax,real(W));
    end        
end
set(opt.ax,'DataAspectRatio',[1 1 1])

if opt.reverseColor
    colormap(opt.ax,flipud(gray))
else
    colormap(opt.ax,'Gray')
end

set(opt.ax,'YDir','normal')
colorbar(opt.ax)



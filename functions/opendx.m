%% NPimaging package
% Display images with an OpenDX rendering, i.e. a sort of 3D display with a
% nice, smooth surface.
% It can display two images within a single. The first image is coded with
% the topography, and the second image is coded with a colorscale. This is
% useful to display images with complex values for instance. In particular,
% this function is called by the function imagecx.

% authors: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 26, 2020

function c = opendx(T,varargin)
% parameters: (T) or (T,colorScale) or (T,Ph) or (T,Ph,EL) or (T,colorscale,EL)
% specifying a coloringIm input enable the color of the image to represent
% something different from the values of Im. This way, for an Image object,
% Im is coded in 3D topography while the phase is color-coded.
% EL: angle of the camlight.
% coloringmap: image which values sets the color. Normally Ph, but T when
% Ph is absent

[Ny,Nx]=size(T);
DZ=max(T(:))-min(T(:));
if DZ==0
    DZ=max(T(:));
end

[X,Y] = meshgrid(0:Nx-1,0:Ny-1);
viewangle=90;
persp=1;

if persp==1
    DZ=(max(T(:))-min(T(:)))/3;
    viewangle=40;
end

%% handling the number of parameters


if nargin==1                % (T)
    colorScale=hsv(1024);
    coloringMap=T;
    EL=35;
elseif nargin==2
    if size(varargin{1})==1 % (T,EL)
        colorScale=hsv(1024);
        coloringMap=T;
        EL=Ph;
    elseif size(varargin{1})==size(T) % (T,Ph)
        colorScale=colorPhaseMap(varargin{1}); % asign the color white to the mean value of the image.
        coloringMap=varargin{1};
        EL=35;
    else                  % (T,colorScale)
        colorScale=varargin{1};
        coloringMap=T;
        EL=35;
    end
elseif nargin==3
    if size(varargin{1})==size(T)
        if size(varargin{2})==1 %(T,Ph,EL)
            colorScale=colorPhaseMap(varargin{1});
            coloringMap=varargin{1};
            EL=varargin{2};
        else  %(T,Ph,colorScale)
            colorScale=varargin{2};
            coloringMap=varargin{1};
            EL=35;
        end                        
    else                    %(T,colorScale0,EL)
        coloringMap=T;
        colorScale=varargin{1};
        EL=varargin{2};
    end
elseif nargin==4
    colorScale=varargin{2};
    coloringMap=varargin{1};
    EL=varargin{3};
end

colormap(gca,colorScale);

%% Display
surf(X,Y,T,coloringMap,'FaceColor','interp',...
   'EdgeColor','none',...
   'FaceLighting','phong')

daspect([1 1 DZ/10])
%axis tight
view(0,90)
%camlight left
%camlight(AZ, EL)
camlight(20,EL,'infinite')
%light('Position',[-1 0 0],'Style','local')
cb=colorbar;
axis([1 Nx 1 Ny])
view(0,viewangle)
camproj('perspective')
%axis off


if nargout
	c=cb;
end





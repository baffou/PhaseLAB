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

function c = opendx2(xx,yy,Im1,Im2,colorScale0,EL)

% xx and yy are same as in imagesc(xx,yy,Z). They are 2-vectors that specify the corners.
% parameters: (Im) or (Im,colorScale) or (Im1,Im2) or (Im1,Im2,colorScale)
% specifying a coloringIm input enable the color of the image to represent
% something different from the values of Im. This way, for an Image object,
% Im is coded in 3D topography while the phase is color-coded.

[Ny,Nx] = size(Im1);
DZ = max(Im1(:)) - min(Im1(:));

%%[X,Y] = meshgrid(0:Ny-1,0:Nx-1);

Y = linspace(yy(1),yy(2),Ny).'*ones(1,Nx);
X = ones(Ny,1)*linspace(xx(1),xx(2),Nx);
viewangle = 90;
persp = 0;

if persp == 1
    DZ = (max(Im1(:))-min(Im1(:)))/3;
    viewangle = 40;
end

%% handling the number of parameters

if nargin==3                % (Im)
    colorScale=hsv(1024);
    coloringMap=Im1;
    EL=35;
elseif nargin==4
    EL=35;
    if size(Im2)==size(Im1) % (Im1,Im2)
        colorScale=colorPhaseMap(Im2);
        coloringMap=Im2;
    else                  % (Im,colorScale)
        colorScale=Im2;
        coloringMap=Im1;
    end
elseif nargin==5
    if size(Im2)==size(Im1) %(Im1,Im2,colorScale0)
        coloringMap=Im2;
        EL=35;
        colorScale=colorScale0;
    else                    %(Im1,colorScale,EL)
        coloringMap=Im1;
        EL=colorScale0;
        colorScale=Im2;
    end
elseif nargin==6
    colorScale=colorScale0;
    EL=35;
end

colormap(gca,colorScale);

%% Display

surf(X,Y,Im1,coloringMap,'FaceColor','interp',...
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
axis([1 Ny 1 Nx])
view(0,viewangle)
camproj('perspective')
%axis off


if nargout
	c=cb;
end





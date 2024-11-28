%% NPimaging package
% display a matrix with complex values
% The image is displayed in 3D. The topography represents the intensity and
% the color represents the phase.

% authors: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 07, 2020

function imagecx(ImComplex)  % or opendx(Z,nFig)
% parameters: (Im) or (Im,colorScale) or (Im,coloringIm) or (Im,coloringIm,colorScale)
% specifying a coloringIm input enable the color of the image to represent
% something different from the values of Im. This way, for an Image object,
% Im is coded in 3D topography while the phase is color-coded.

Int = abs(ImComplex).^2;
Ph = angle(ImComplex);

opendx(Int,Ph)

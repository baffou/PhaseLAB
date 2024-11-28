%% NPimaging package
% function that computes an object otical volume from its image

% authors: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Nov 19, 2021

function OV = OV_Image(Image)
Nim=length(Image);
OV = zeros(Nim,1);

for iim=1:Nim
    OV(iim) = sum(Image(iim).OPD(:))*Image(iim).pxSize*Image(iim).pxSize;
end



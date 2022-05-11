%% NPimaging package
% Generate a rvb colorscale (1024x3 matrix) from a phase image, and asign
% the color white to the value phase=0.
% To use it to define the color scale of a figure, it can be used in the form:
% colormap(gca,colorScale)

% authors: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 26, 2020

function colorScale=colorPhaseMap(Ph)
            NcolPx=1024;
            hsvPhVal0=8*abs(cos(pi*(1:NcolPx)'/NcolPx));
            hsvPhVal=double(hsvPhVal0>1) + (hsvPhVal0<=1).*hsvPhVal0;
            Map=rgb2hsv(hsv(NcolPx));
            Map(:,2)=Map(:,2).*hsvPhVal;
            Map=hsv2rgb(Map); % colormap with some white in the middle

            minPh=min(Ph(:));
            maxPh=max(Ph(:));
            nPh0=(mean(Ph(:))-minPh)/(maxPh-minPh); % the mean is actually the phase 0; True especially for nanoparticle imaging, not really for cell imaging...

            if nPh0>=0.5*0.9999
                colorScale=Map(1:round(end*0.5/nPh0),:);
            else
                colorScale=Map(round(end*0.5*(1-2*nPh0)/(1-nPh0)):end,:);
            end




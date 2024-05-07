%% FUNCTION THAT COMPUTES THE GREEN'S FUNCTION IN THE rho/z PLANE.
%% IS SUPPOSED TO BE USED IN THE CASE OF A 3-LAYER SYSTEM. OTHERWISE
%% THE 3D GREEN'S FUNCTION IS DIRECTLY CONSTRUCTED.

% greenT_RHOZ(rho , universe [, folder])
%
%   rho:      vector of radial coordinates.
%   universe: array of 2 or 3 Medium objects.
%   folder:   (optional) The Green's function will be stored in the folder
%             'folder/_postprocess'. If nothing is specified, nothing is
%             saved.

% Theory from the article Appl. Phys. Lett. 102, 244103 (2013)
%                         https://doi.org/10.1063/1.4811557

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 1, 2018

function [Green,figureGreen] = greenT_RHOZ(rho,ME,folder)


%% calculation of the Green's function in the (rho,z) plane
z = [ME(1).mesh.z(ME(1).mesh.npx:-1:2) ME(2).mesh.z ME(3).mesh.z(2:ME(3).mesh.npx)];

Nz=length(z);
Nx=length(rho.z);

Green = zeros(Nz,Nx);

figureGreen = figure;
daspect([1 1 1])
title('Green''s function construction in the rho/z plane  - integral algorithm')
xlabel('rho (px)') % x-axis label
ylabel('z (px)') % y-axis label   
set(gcf, 'Position', [700, 100, 500, 800])

for iz = 1:Nz

fprintf([int2str(iz) '/' int2str(Nz) ', '])

    if z(iz)<ME(1).mesh.z(1) && z(iz)>ME(1).mesh.z(end)
        fprintf('M1 ')
    elseif z(iz)<ME(2).mesh.z(1) && z(iz)>ME(2).mesh.z(end)
        fprintf('M2 ')
    elseif z(iz)<ME(3).mesh.z(1) && z(iz)>ME(3).mesh.z(end)
        fprintf('M3 ')
    end

    tic
    Green(iz,:) = greenT_3layers(rho.z,0*rho.z,z(iz).*(0*rho.z+1),ME);
    toc
    figure(figureGreen)
    imagesc('XData',rho.z*1e6,'YData',z*1e6,'CData',Green*1e-9)
    caxis([0 max(Green(:)*1e-9)])
    drawnow


end % iz

if nargin == 3
    % saving the Green's function
    actualFolder=cd(folder);
    cd('_postprocess')
    dlmwrite('GreenRHOZ.txt',Green,' ')
    saveas(figureGreen,'GreenRHOZ.png')
    cd(actualFolder)
end



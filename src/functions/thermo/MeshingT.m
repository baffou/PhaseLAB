%% Class that defines a 1D meshing

% Sid4Thermo Matlab Package
% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 1, 2018

classdef MeshingT
    properties(GetAccess=public , SetAccess=private)
        z       % Array of z coordinates.
        npx     % Number of elements of z.
        z1      % z(1)
        z2      % z(npx)
        dz      % z(2)-z(1)
    end
    
    methods
        function m = MeshingT(z1,z2,dz,npx)
            %(z1 , z2 , dz [, npx])
            if nargin == 3
                npx = round(abs((z2-z1)/dz))+1;
            end
            if nargin == 0
            elseif z1==z2
                m.z = z1;
                m.z1 = z1;
                m.z2 = z2;
                m.dz = 0;
                m.npx = 1;
            else
                m.z1 = z1;
                m.z2 = z2;
                m.dz = dz;
                m.npx = round(npx);
                a = (z2-z1-dz*(npx-1))/(npx-1)^2;
                n = 0:round(npx)-1;
                m.z = a*n.^2+dz*n+z1;
                m.z(m.npx) = z2;
            end

        end
        
    end
      
end
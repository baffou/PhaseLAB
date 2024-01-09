%% NPimaging package
% Class that defines the mesh of a particle

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Jul 31, 2019

classdef Meshing
    
    properties(Access=public)
        pos     % (Nx3) array of the positions of the cells
        a       % lattice parameter
        chi     % susceptibility of the cells.
        E0      % Incident polarization vector amplitude
        EE0     % Incident E field in each cell
        EE      % Local E field in each cell
        p       % polarization vector of each cell
    end
    
    properties(Dependent)
        N       % Number of cells
    end    
    
    methods
        function obj=Meshing()
        end
        
        function val = get.N(obj)
            val=numel(obj.pos)/3;
        end
    end
    
end
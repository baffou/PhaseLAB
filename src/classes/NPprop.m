%% NPimaging package
% Class that defines a collection of optical properties of a nanoparticle

% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Mar 17, 2020

classdef NPprop
    properties(SetAccess = private , GetAccess = public)
        alpha	% Complex polarizability [m^3]
        Cext    % absorption cross section [m^2]
        Csca    % scattering cross section [m^2]
        Cabs    % absorption cross section [m^2]
    end

    methods
        function obj = NPprop(alpha,Cext,Csca,Cabs)
            if nargin==4
                No = length(alpha);
                if No~=length(Cext) ||...
                   No~=length(Csca) ||...
                   No~=length(Cabs)
                   error('input vectors must have the same length')
                end
                obj = repmat(NPprop(),No,1);
                for io = 1:No
                    obj(io).alpha = alpha(io);
                    obj(io).Cext = Cext(io);
                    obj(io).Csca = Csca(io);
                    obj(io).Cabs = Cabs(io);
                end
            end
        end
    end
end
            
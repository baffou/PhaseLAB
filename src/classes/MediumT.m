%% Class that defines a layer of material

% Sid4Thermo Matlab Package
% author: Guillaume Baffou
% affiliation: CNRS, Institut Fresnel
% date: Feb 1, 2018

classdef MediumT
    properties (Access=public)
        h       % Thickness of the layer medium.
        num     % Number of the layer: 1(substrate), 2(medium), 3(cover)
    end
    properties (GetAccess=public , SetAccess=private)
        name    % Material of the medium ( can be 'water', 'glycerol', 'BK7' or 'none').
        mesh    % Mesh object. Coordinates of the points meshing the layer in z.
        mesh_param  % regular or progressive
        mesh_Npx
    end        
    properties (Dependent)
        kappa   % Thermal conductivity of the medium.
        b       % 4-number vector defining the dn/dT fit coefficients b1, b2, b3, b4.
    end
        
    methods
        function obj = MediumT(material,h,m_p,mesh_Npx)
            % (material,h[,mesh_param[,mesh_Npx]])
            if ~ischar(material)
                error('The name assigned to a medium has to be a string.\n')
            elseif ~strcmp(material,'water') && ~strcmp(material,'glycerol') && ~strcmp(material,'BK7')
                error(['the material ''' material ''' is not in the database.\n'])
            end
            obj.name = material;
            obj.h = h;
            obj.mesh_param='regular';
            if nargin>=3
                if strcmp(m_p,'regular') || strcmp(m_p,'progressive')
                    obj.mesh_param=m_p;
                else
                    warning(['be careful, ' m_p ' is not a valid parameter. Only ''regular'' and ''progressive'' are permitted. ''regular'' used instead.'])
                end
            end
            if nargin==4
                if strcmp(m_p,'regular')
                    warning('the mesh_Npx parameter makes sense only for the ''progressive'' mode.')
                else
                    if isnumeric(mesh_Npx)
                        if mesh_Npx>1
                            obj.mesh_Npx=mesh_Npx;
                        else
                            warning('mesh_Npx must be >1')
                        end
                    else
                        warning('mesh_Npx must be a number.')
                    end
                end
            end
        end
        
        function b = get.b(obj) % Here is where B values have to be implemented
            if strcmp(obj.name,'water')
                b(1) = -2.9301e-5;
                b(2) = -1.6218e-6;
                b(3) = 4.1573e-9;
                b(4) = -6.702e-12;
            elseif strcmp(obj.name,'quartz')
                b(1) = 0;
                b(2) = 0;
                b(3) = 0;
                b(4) = 0;
            elseif strcmp(obj.name,'glycerol')
                b(1) = -27.0e-5;
                b(2) = 0;
                b(3) = 0;
                b(4) = 0;
            elseif strcmp(obj.name,'BK7')
                b(1) = 1.5e-6;
                b(2) = 0;
                b(3) = 0;
                b(4) = 0;
            elseif strcmp(obj.name,'none')
                b(1) = 0;
                b(2) = 0;
                b(3) = 0;
                b(4) = 0;
            else
                error(['the material ''' obj.name ''' is not in the database.\n'])
            end
        end
        
        function value = get.kappa(obj) % Here is where kappa values have to be implemented
            if strcmp(obj.name,'water')
                value = 0.6;
            elseif strcmp(obj.name,'glycerol')
                value = 1.4;
            elseif strcmp(obj.name,'BK7')
                value = 1.38;
            elseif strcmp(obj.name,'quartz')
                value = 1.4;
            elseif strcmp(obj.name,'none')
                value = 1e7;
            else
                error(['the material ''' obj.name ''' is not in the database.\n'])
            end
        end
        
        function obj = set.h(obj,height)
            if ~isnumeric(height)
                error('height has to be a numeric value\n')
            elseif height>=0
                obj.h = height;
            else
                error('in class ''MediumT''. The specified height is not a positive number.\n')
            end
        end
                
        function obj = zmesh(obj,z1,z2,dz,npx)
            % (obj,z1,z2,dz,Npx). Meshes the layer. obj: le MediumT object to be meshed .z1: starting z. z2: final z.dz: starting increment.Npx: (optional) Number of pixels. By default: h/dz+1.
            % obj: le MediumT object to be meshed
            % z1: starting z
            % z2: final z
            % dz: starting increment
            % npx: (optional) Number of pixels. By default: h/dz+1.
            if abs(z1-z2) ~= obj.h
                error('The specifed z range does not correspond to the thickness of the medium')
            end
            if nargin == 4
                obj.mesh = MeshingT(z1,z2,dz);
            else
                obj.mesh = MeshingT(z1,z2,dz,npx);
            end
        end

        function saveObject(obj,folder)
            % Saves an array of MediumT object ME(i) in files named ['medium' int2str(i) '.txt'].
            previousFolder=cd(folder);
            a = exist('_postprocess','dir');
            if a ~= 7
                mkdir('_postprocess')
            end
            cd('_postprocess')
            for ii = 1:length(obj)
                fid = fopen(['medium' int2str(ii) '.txt'],'w');
                fprintf(fid,'h = %e\n',obj(ii).h);
                fprintf(fid,'name = %s\n',obj(ii).name);
                fprintf(fid,'kappa = %f\n',obj(ii).kappa);
                fprintf(fid,'b = %d\n  %d\n  %d\n  %d\n',obj(ii).b(1),obj(ii).b(2),obj(ii).b(3),obj(ii).b(4));
                fprintf(fid,'MESHING:\n');
                if ~isempty(obj(ii).mesh)
                    fprintf(fid,' npx = %d\n',obj(ii).mesh.npx);
                    fprintf(fid,' z1 = %d\n',obj(ii).mesh.z1);
                    fprintf(fid,' z2 = %d\n',obj(ii).mesh.z2);
                    fprintf(fid,' dz = %d\n',obj(ii).mesh.dz);
                    fprintf(fid,' z=\n');
                    for iz=1:obj(ii).mesh.npx
                        fprintf(fid,'%d\n',obj(ii).mesh.z(iz));
                    end
                end
                fclose(fid);
            end
            cd(previousFolder)
        end
    end
end





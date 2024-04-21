classdef ImageT

    properties(SetAccess = private)
        OPD  (:,:) double
        TMP  (:,:) double
        HSD  (:,:) double
        zT   (1,1) double = 0
    end

    properties(Dependent)
        Nx
        Ny
    end

    properties
        Microscope Microscope
        Illumination Illumination % Illumination object
    end

    methods

        function obj = ImageT(W, T, H)
            arguments
                W = [] % OPD map
                T = [] % temperature map
                H = [] % heat source density map
            end
            obj.OPD = W;
            obj.TMP = T;
            obj.HSD = H;
        end

        function val = get.Nx(obj)
            if ~isempty(obj.TMP)
                val = size(obj.TMP,2);
            elseif ~isempty(obj.OPD)
                val = size(obj.OPD,2);
            elseif ~isempty(obj.HSD)
                val = size(obj.HSD,2);
            end
        end

        function val = get.Ny(obj)
            if ~isempty(obj.TMP)
                val = size(obj.TMP,1);
            elseif ~isempty(obj.OPD)
                val = size(obj.OPD,1);
            elseif ~isempty(obj.HSD)
                val = size(obj.HSD,1);
            end
        end

        function obj = set.TMP(obj,val)
            % makes sure that any new TMP image has the same size as any other image
            if ~isempty(obj.HSD)
                if any(size(obj.HSD)~=size(val)) % if any of the dimensions does not match
                    error('the dimension of the T map must match the dimensions of the HSD map')
                end
            elseif ~isempty(obj.OPD)
                if any(size(obj.OPD)~=size(val)) % if any of the dimensions does not match
                    error('the dimension of the T map must match the dimensions of the OPD map')
                end
            end
            obj.TMP = val;
        end

        function obj = set.OPD(obj,val)
            % makes sure that any new TMP image has the same size as any other image
            if ~isempty(obj.HSD)
                warning('You are not supposed to set an OPD image while there is already an HSD image')
                if any(size(obj.HSD)~=size(val)) % if any of the dimensions does not match
                    error('the dimension of the OPD map must match the dimensions of the HSD map')
                end
            elseif ~isempty(obj.TMP)
                warning('You are not supposed to set an OPD image while there is already a TMP image')
                if any(size(obj.TMP)~=size(val)) % if any of the dimensions does not match
                    error('the dimension of the OPD map must match the dimensions of the TMP map')
                end
            end
            obj.OPD = val;
        end

        function obj = set.HSD(obj,val)
            % makes sure that any new TMP image has the same size as any other image
            if ~isempty(obj.OPD)
                if any(size(obj.OPD)~=size(val)) % if any of the dimensions does not match
                    error('the dimension of the HSD map must match the dimensions of the OPD map')
                end
            elseif ~isempty(obj.TMP)
                if any(size(obj.TMP)~=size(val)) % if any of the dimensions does not match
                    error('the dimension of the HSD map must match the dimensions of the TMP map')
                end
            end
            obj.HSD = val;
        end

        function obj = set.zT(obj, val)
            if val > 0.001
                warning('Are you sure zT is in [m]?')
            end
            obj.zT = val;
        end
    end

end
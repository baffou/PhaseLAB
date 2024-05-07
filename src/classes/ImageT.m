classdef ImageT   <   ImageMethods

    properties(SetAccess={?ImageMethods})
        OPD  (:,:) double
        TMP  (:,:) double
        HSD  (:,:) double
        T    (:,:) double
        zT   (1,1) double = 0
    end

    properties(Dependent)
        Nx
        Ny
    end

    methods

        function obj = ImageT(W, TMP, H, T)
            arguments
                W = [] % OPD map
                TMP = [] % temperature map
                H = [] % heat source density map
                T = [] % heat source density map
            end
            obj.OPD = W;
            obj.TMP = TMP;
            obj.HSD = H;
            obj.T = T;
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

        function set.zT(obj, val)
            if val > 0.001
                warning('Are you sure zT is in [m]?')
            end
            obj.zT = val;
        end

        function figureT(obj)
            dynamicFigure("gb",{obj.OPD},"gb",{obj.HSD},"gb",{obj.TMP},"titles",{"OPD","HSD","TMP"})
            fullwidth
            linkAxes
        end

    end

end
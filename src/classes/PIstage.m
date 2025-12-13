classdef PIstage  <  handle

    properties
        hndl
        X
        Y
        Z
    end

    methods

        function obj= PIstage(hndl)
            obj.X =  0;
            obj.Y =  0;
            obj.Z  = 0;
        end

        function moveTo(obj, opt)
            arguments
                obj
                opt.x = 0
                opt.y = 0
                opt.z = 0
            end

            obj.X = opt.x;
            obj.Y = opt.y;
            obj.Z = opt.z;

        end

        function moveBy(obj, opt)
            arguments
                obj
                opt.x = 0
                opt.y = 0
                opt.z = 0
                opt.up = 0
                opt.top = 0
                opt.right = 0
                opt.left = 0
                opt.down = 0
                opt.bottom = 0
            end

            obj.X = obj.X + opt.x + abs(opt.right) - abs(opt.left);
            obj.Y = obj.Y + opt.y + abs(opt.top) + abs(opt.up) - abs(opt.down) - abs(opt.bottom);
            obj.Z = obj.Z + opt.z;
        end

    end

end
classdef JonesMatrix
    properties
        xx (:,:) double = 1
        xy (:,:) double = 0
        yx (:,:) double = 0
        yy (:,:) double = 1
    end

    properties(Dependent)
        Nx
        Ny
        mat
    end

    properties(SetAccess = private)
        lambda
    end

    methods

        function obj = JonesMatrix(mat)
            % CONSTRUCTOR
            % JonesMatrix({Ja, Jb, Jc, ...})  , wher each J is a J matrix, or J matrix image
            % JonesMatrix(J)       ; where J is a 2*2 double matrix
            % JonesMatrix(Jimage)  , where Jimage is a 2*2*Ny*Nx double matrix image
            

            if nargin % enables JonesMartrix()
                if isnumeric(mat) && numel(mat) == 1  % JonesMatrix (n)
                    obj = repmat(JonesMatrix(),mat,1);
                    for ii = 1:mat % to make sure they are not identical handles
                        obj(ii) = JonesMatrix();
                    end
                    return
                end

                if iscell(mat)
                    No = numel(mat);
                elseif isnumeric(mat)
                    No = 1; % only 1 matrix (2*2), or 1 matrix image (2*2*Ny*Nx)
                else
                    error('not a right type of input for mat. Should be cell or numeric.')
                end
    
                obj = repmat(JonesMatrix(),No,1);
    
                for io = 1:No
                    if iscell(mat)
                        mat0 = mat{io}; % thanks to @, not duplicated.
                    else
                        mat0 = mat;
                    end

                    % test if it is a 2*2 matrix:
                    [nx, ny, ~, ~] = size(mat0); % mat can be 2*2 or 2*2*Ny*Nx
                    if nx ~=2 || ny ~=2
                        error("Wrong matrix size, it is ["+nx+","+ny+"], and should be [2, 2].")
                    end
                    obj(io).xx = squeeze(mat0(1,1,:,:));
                    obj(io).xy = squeeze(mat0(1,2,:,:));
                    obj(io).yx = squeeze(mat0(2,1,:,:));
                    obj(io).yy = squeeze(mat0(2,2,:,:));
                end
            end
        end

        function val = c(J,iy,ix)
            % extracts components
            arguments
                J
                iy (1,1) {mustBeMember(iy,[1 2])}
                ix (1,1) {mustBeMember(ix,[1 2])}
            end
            if     iy == 1 && ix == 1
                val = J.xx;
            elseif iy == 1 && ix == 2
                val = J.xy;
            elseif iy == 2 && ix == 1
                val = J.yx;
            elseif iy == 2 && ix == 2
                val = J.yy;
            end
                
        end

        function val = get.mat(obj)
            % returns the 2*2*Ny*Nx matrix
            val = zeros([2,2,size(obj.xx)]);
            val (1,1,:,:) = obj.c(1,1);
            val (1,2,:,:) = obj.c(1,2);
            val (2,1,:,:) = obj.c(2,1);
            val (2,2,:,:) = obj.c(2,2);
        end

        function Eout = mtimes(J, Ein)
            arguments
                J JonesMatrix
                Ein {mustBeA(Ein,["ImageMethods","double"])}
            end
            
            if isa(Ein,'ImageQLSI')
                Ein = ImageEm(Ein);
            elseif isnumeric(Ein)
                Ein = ImageEM(Ein(1),Ein(2),0);
            elseif ~isa(Ein,'ImageEM')
                error('Not a proper format for Ein. It should be an ImageEM or an ImageQLSI object.')
            end

            No = numel(J);            
            Eout = ImageEM(n=No);
            for io = 1:No
                %% pixelwise multiplicatin of the images
                eoutx = J(io).xx.*Ein.Ex + J(io).xy.*Ein.Ey;
                eouty = J(io).yx.*Ein.Ex + J(io).yy.*Ein.Ey;
                Eout(io) = ImageEM(eoutx,eouty,eoutx*0);
            end
        end

        function hfig = figure(obj,func)
            arguments
                obj
                func = 'abs'
            end

            if nargout
                hfig = displayJonesMatrix(obj,"func",func);
            else
                displayJonesMatrix(obj,"func",func)
            end  
        end

        function val = get.Nx(J)
            val = size(J.xx,2);
        end
        function val = get.Ny(J)
            val = size(J.xx,1);
        end
    end
end















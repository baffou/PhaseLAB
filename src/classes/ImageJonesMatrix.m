classdef ImageJonesMatrix
    properties
        xx (:,:) double = 1
        xy (:,:) double = 0
        yx (:,:) double = 0
        yy (:,:) double = 1
    end

    properties(SetAccess = {?ImageQLSIpolar})
        Illumination Illumination
        Microscope Microscope
    end

    properties(Dependent)
        Nx
        Ny
        mat % (2,2,:,:) array

        T ImageTransmittance % Complex transmittance coefficients to, te, phi
    end

    properties(SetAccess = private)
        lambda
    end

    methods

        function obj = ImageJonesMatrix(mat)
            % CONSTRUCTOR
            % ImageJonesMatrix({Ja, Jb, Jc, ...})  , where each J is a J matrix, or J matrix image
            % ImageJonesMatrix(J)       ; where J is a 2*2 double matrix
            % ImageJonesMatrix(Jimage)  , where Jimage is a 2*2*Ny*Nx double matrix image
            

            if nargin % ImageJonesMatrix()
                if isnumeric(mat) && isscalar(mat)  % ImageJonesMatrix(n)
                    obj = repmat(ImageJonesMatrix(),mat,1);
                    for ii = 1:mat % to make sure they are not identical handles
                        obj(ii) = ImageJonesMatrix();
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
    
                obj = repmat(ImageJonesMatrix(),No,1);
    
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

        function val = c(obj,iy,ix)
            % extracts components
            arguments
                obj
                iy (1,1) {mustBeMember(iy,[1 2])}
                ix (1,1) {mustBeMember(ix,[1 2])}
            end
            if     iy == 1 && ix == 1
                val = obj.xx;
            elseif iy == 1 && ix == 2
                val = obj.xy;
            elseif iy == 2 && ix == 1
                val = obj.yx;
            elseif iy == 2 && ix == 2
                val = obj.yy;
            end
                
        end

        function Eout = mtimes(obj, Ein)
            arguments
                obj ImageJonesMatrix
                Ein {mustBeA(Ein,["ImageMethods","double"])}
            end
            
            if isa(Ein,'ImageQLSI')
                Ein = ImageEm(Ein);
            elseif isnumeric(Ein)
                Ein = ImageEM(Ein(1),Ein(2),0);
            elseif ~isa(Ein,'ImageEM')
                error('Not a proper format for Ein. It should be an ImageEM or an ImageQLSI object.')
            end

            No = numel(obj);            
            Eout = ImageEM(n=No);
            for io = 1:No
                %% pixelwise multiplication of the images
                eoutx = obj(io).xx.*Ein.Ex + obj(io).xy.*Ein.Ey;
                eouty = obj(io).yx.*Ein.Ex + obj(io).yy.*Ein.Ey;
                Eout(io) = ImageEM(eoutx,eouty,eoutx*0);
            end
        end

        function hfig = figure(obj,opt)
            arguments
                obj
                opt.func = 'abs'
                opt.clim = []
            end

            if nargout
                hfig = displayJonesMatrix0(obj,"func",opt.func,"clim",opt.clim);
            else
                displayJonesMatrix0(obj,"func",opt.func,"clim",opt.clim)
            end  
        end

        function [val, phid] = dichro(obj)
            [~, diatt] = jones_decomposition_vectorized0(obj.mat, 'HU');
            phid = -angle(diatt.pd(:,:,1)+1i*diatt.pd(:,:,2))/2;
            val = diatt.D;
        end

        function [val, phib] = biref(obj)
            bir = jones_decomposition_vectorized0(obj.mat, 'HU');
            phib = -angle(bir.pb(:,:,1)+1i*bir.pb(:,:,2))/2;
            val = bir.beta;
        end

        function T = J2T(obj)
            % export an array of Jones matrix images into an array of
            % complex transmittance images.
            Nim = numel(obj);
            T = ImageTransmittance(Nim);
            for ii = 1:Nim
                T(ii) = obj(ii).T;
            end
        end

        function [U,V] = J2Schur(obj)
            arguments
                obj ImageJonesMatrix
            end
            % Computes the Schur decomposition
            
            Nim = numel(obj);
            
            Ny0 = obj(1).Nx;
            Nx0 = obj(1).Ny;
            
            U = cell(Nim,1);
            V = cell(Nim,1);
            for ii = 1:Nim
            
                U{ii} = zeros(2,2,Ny0,Nx0);
                V{ii} = zeros(2,2,Ny0,Nx0);
                Jmat = obj(ii).mat;
                for ix = 1:Nx0
                    for iy = 1:Ny0
                        [U{ii}(:,:,iy,ix),V{ii}(:,:,iy,ix)] = schur(squeeze(Jmat(:,:,iy,ix)));
                    end
                end
            
            end
            U = ImageJonesMatrix(U);
            V = ImageJonesMatrix(V);
            for ii = 1:Nim
                U(ii).Microscope = obj(ii).Microscope;
                V(ii).Microscope = obj(ii).Microscope;
                U(ii).Illumination = obj(ii).Illumination;
                V(ii).Illumination = obj(ii).Illumination;
            end
        end

        function [T, J_lin,eigenvect, Dhat, beta_hat, h0_hat, phi0_hat] = Schur2T(U,V)
            arguments
                U ImageJonesMatrix
                V ImageJonesMatrix
            end
            
            Nim = numel(U);
            
            Dhat = cell(Nim,1);
            beta_hat = cell(Nim,1);
            h0_hat = cell(Nim,1);
            phi0_hat = cell(Nim,1); % difference in factor 2 because of the way we defined phi0 in birefringence_to_unitary
            T = ImageTransmittance(Nim);
            for im = 1:Nim
                
                V(im).xy = 0; % set off-diagonal to zero to enforce homogeneity
                J_homo = pagemtimes( U(im).mat , pagemtimes(V(im).mat , pagectranspose(U(im).mat)));
                % project to linear only
                J_lin = 0.5*(J_homo + pagetranspose(J_homo)); % symmetry enforces linearity (component on sigma_3 vanishes)
                % compute parameters via eigendecomposition
                [eigenvect, t_vals] = pageeig(J_lin);
                %t_vals = diag(t_vals);
            
                % Ensure eigenvalues on each page are ordered by decreasing absolute value
                sz = size(t_vals);               % e.g. [2 2 nrows ncols]
                npages = prod(sz(3:end));
                tvals2 = reshape(t_vals, 2, 2, npages);
                eigvec2 = reshape(eigenvect, 2, 2, npages);
            
                for p = 1:npages
                    a = tvals2(1,1,p);
                    b = tvals2(2,2,p);
                    if abs(a) < abs(b)
                        % swap eigenvalues (diagonal entries)
                        tvals2(:,:,p) = tvals2([2 1],[2 1],p);
                        % swap corresponding eigenvectors (columns)
                        eigvec2(:,:,p) = eigvec2(:,[2 1],p);
                    end
                end
            
                % reshape back to original page sizes
                t_vals = reshape(tvals2, sz);
                eigenvect = reshape(eigvec2, size(eigenvect));
            
                % determine psi from eigenvectors
                psi = squeeze( angle(eigenvect(1, 1,:,:) + 1j*eigenvect(2, 1,:,:)));
                % get D, beta
                to = squeeze( t_vals(1,1,:,:)); % largest absolute value
                te = squeeze( t_vals(2,2,:,:));
                Dhat{im} = (abs(to) - abs(te)) ./ (abs(to) + abs(te)) ;
                beta_hat{im} = angle(to) - angle(te);
                h0_hat{im} = (abs(to) + abs(te))/2;
                phi0_hat{im} = (angle(to) + angle(te))/2;

                T(im) = ImageTransmittance(to,te,psi,U(im).Illumination);
            
            end        
        
        end
        
        % set/get functions
        function val = get.mat(obj)
            % returns the 2*2*Ny*Nx matrix
            val = zeros([2,2,size(obj.xx)]);
            val(1,1,:,:) = obj.c(1,1);
            val(1,2,:,:) = obj.c(1,2);
            val(2,1,:,:) = obj.c(2,1);
            val(2,2,:,:) = obj.c(2,2);
        end

        function val = get.Nx(obj)
            val = size(obj.xx,2);
        end

        function val = get.Ny(obj)
            val = size(obj.xx,1);
        end

        function T = get.T(obj)
            % Spectral decomposition
            
            Nim = numel(obj);
            
            T = ImageTransmittance(Nim);
            
            % vectorized algorithm of the retrieval of biref and diatt properties, from J
            
            for ii = 1:Nim
                [bir, diatt] = jones_decomposition_vectorized0(obj(ii).mat, 'HU');
                phid = angle(diatt.pd(:,:,1)+1i*diatt.pd(:,:,2))/2;
                phib = angle(bir.pb(:,:,1)+1i*bir.pb(:,:,2))/2;
                phi = angle(exp(1i*phib*4)+exp(1i*phid*4))/4;
                        
                % sign correction in case where pd = -pd
                sgn = sign(dot(squeeze(bir.pb),squeeze(diatt.pd),3));
                
                % by convention, to and te are such that abs(to) > abs(te)
                to = diatt.h0.*exp(1i*bir.phi0).*(1+diatt.D).*exp(1i*sgn.*(bir.beta/2)); 
                te = diatt.h0.*exp(1i*bir.phi0).*(1-diatt.D).*exp(1i*sgn.*(-bir.beta/2));
                T(ii) = ImageTransmittance(to,te,phi,obj.Illumination,"phib",phib,"phid",phid);
            end
            
            if isscalar(T(ii).t_e) % scalar and not images
                T(ii).te = cell2mat(T(ii).t_e);
                T(ii).to = cell2mat(T(ii).t_o);
                T(ii).phi = unwrap2(cell2mat(T(ii).phi)*4)/4;
            end
        end


    end
end















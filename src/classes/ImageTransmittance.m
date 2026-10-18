classdef ImageTransmittance
    properties(SetAccess = private)
        t_o (:,:) double % Complex transmittance (ordinary)
        t_e (:,:) double % Complex transmittance (extraordinary)
        phi (:,:) double % angle of the ordinary axis
        phib (:,:) double
        phid (:,:) double
        IL Illumination
    end

    properties(Dependent)
        sigma_o % Ordinary complex conductivity
        sigma_e % Extraordinary complex conductivity
        chi_o   % Ordinary complex susceptibility
        chi_e   % Extraordinary complex susceptibility
        alpha_o % Ordinary complex 2D polarizability
        alpha_e % Extraordinary complex 2D polarizability
    end

    % Transmittance tensor of a material, defined by its complex eigen
    % values and main axis angle.
    methods
        function obj = ImageTransmittance(to, te, phi, IL, opt)
            % Transmittance()
            % Transmittance(N)
            % Transmittance(to, te, phi, IL)
            % Transmittance(to, te, phi, IL, "phib", phib, "phid", phid)
            arguments
                to = 1  % eigen ordinary transmittance
                te = 1  % eigen extraodinary transmittance
                phi = 0 % rotation angle of the main axis
                IL Illumination = Illumination() % surrounding medium
                opt.phid = []  % dichroism angle
                opt.phib = []  % birefringence angle
            end

            if nargin == 1 % Transmittance(N)
                obj = repmat(ImageTransmittance(),to,1);
                for ii = 1:to % To make sure all the objects don't have the same handle
                    obj(ii) = ImageTransmittance();
                end
                return
            end

            obj.t_o = to;
            obj.t_e = te;
            obj.phi = mod(phi,pi);
            obj.IL = IL;
            obj.phid = opt.phid;
            obj.phib = opt.phib;
        end


        % set/get functions

        function val = get.sigma_o(obj)
            % Ordinary complex conductivity normalized by epsilon_0*c [no dimension]
            n1  = obj.IL.ME.n;
            n2  = obj.IL.ME.nS;
            val = (n1+n2)*(1./obj.t_o-1);
        end
    
        function val = get.sigma_e(obj)
            % Extraordinary complex conductivity normalized by epsilon_0*c [no dimension]
            n1  = obj.IL.ME.n;
            n2  = obj.IL.ME.nS;
            val = (n1+n2)*(1./obj.t_e - 1);
        end

        function val = get.chi_o(obj)
            % Ordinary complex susceptibility
            k0  = 2*pi/obj.IL.lambda;
            val = 1i*obj.sigma_o(obj.IL.ME)/k0;
        end
    
        function val = get.chi_e(obj)
            % Extraordinary complex susceptibility
            k0  = 2*pi/obj.IL.lambda;
            val = 1i*obj.sigma_e(obj.IL.ME)/k0;
        end
    
        function val = get.alpha_o(obj)
            % Ordinary complex 2D polarizability
            k0  = 2*pi/obj.IL.lambda;
            val = 1i*2*obj.IL.ME.n1*(1-obj.t_o)/k0;
        end
    
        function val = get.alpha_e(obj)
            % Extraordinary complex 2D polarizability
            k0  = 2*pi/obj.IL.lambda;
            val = 1i*2*obj.IL.ME.n1*(1-obj.t_e)/k0;
        end    
    
    end

    
end

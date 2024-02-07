Make a movie
++++++++++++

.. dropdown:: **Making a movie** |subTitle|  Animating the image of nanoparticles as a function of the focus. |/subTitle|
    :name: toto
    :open:

    .. code:: matlab

        %% code that animates the image of a ring of nanoparticles
        clear
        lambda = 530e-9;                    % Illumination wavelength
        Npx = 1200;                          % Final image with Npx*Npx pixels
        n = 1.33;                           % Refractive index of the surrounding medium

        ME = Medium(n);
        OB = Objective(100,1.3,'Olympus');
        CGcam = CGcamera('Silios_mono');
        MI = Microscope(OB,180,CGcam);
        IL = Illumination(lambda,ME,1,[1 1i]); % circularly polarized illumination

        radius = 50e-9;           % Nanoparticle radius
        DI0 = Dipole('Au',radius);

        DI = repmat(DI0,12,1);

        R=3e-6;                   % radius of the ring

        for ii=1:12
            DI(ii)=DI(ii).moveTo('x',R*cos(2*pi*ii/12),'y',R*sin(2*pi*ii/12));
        end

        DI = DI.shine(IL);

        Nf = 21;                  % number of nanoparticles over the ring
        focus = linspace(-2,2,Nf)*1e-6;  % various focus distances

        IM = ImageEM(Nf);
        for iz = 1:Nf             % positioning of the Nf nanoparticles
            MI.zo = focus(iz);
            IM(iz) = imaging(DI,IL,MI,Npx);
        end

        IM.crop(Size=300);

        IM.makeMoviedx('IM.avi','theta',0,'phi',0,'rate',2,'zrange',[-10 10])
    

    .. raw:: html

        <video width="560" height="473" autoplay loop muted>
            <source src="http://guillaume.baffou.com/movies/NPcorral.mp4" type="video/mp4">
            Your browser does not support the video tag.
        </video>


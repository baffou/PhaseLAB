Image simulation
++++++++++++++++

.. dropdown:: **Image simulation** |subTitle|  Code that simulates the image of a gold nanoparticle |/subTitle|
    :open:

    .. code:: matlab

        %% code that simulates the image of a gold nanoparticle

        lambda = 530e-9;                    % Illumination wavelength
        Npx = 300;                          % Final image with Npx*Npx pixels 
        n = 1.33;                           % Refractive index of the surrounding medium 

        ME = Medium(n);
        OB = Objective(200,1.3,'Olympus');
        CGcam = CGcamera('Silios_mono');
        MI = Microscope(OB,180,CGcam);
        IL = Illumination(lambda,ME);

        radius = 50e-9;                     % Nanoparticle radius
        DI = Dipole('Au',radius);
        DI = DI.shine(IL);

        IM0 = imaging(DI,IL,MI,Npx);

        IM0.figure

    .. figure:: /images/NPinSilico_Ex2.png
        :width: 500
        :align: center

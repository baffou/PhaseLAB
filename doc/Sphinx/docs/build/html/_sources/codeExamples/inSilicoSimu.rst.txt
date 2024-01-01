In Silico simulation
++++++++++++++++++++

.. dropdown:: **In Silico simulation** |subTitle|  Code that simulates the image of a gold nanoparticle including shot noise |/subTitle|
    :open:

    .. code:: matlab

        %% code that simulates the image of a gold nanoparticle including shot noise

        lambda = 530e-9;            % Illumination wavelength
        Npx = 120;                  % Final image with Npx*Npx pixels

        % model the setup
        ME = Medium('water', 'glass');
        OB = Objective(100,1.0,'Olympus');
        CGcam = CGcamera('sC8-944');
        MI = Microscope(OB,'Olympus',CGcam);
        IL = Illumination(lambda,ME);

        % model the nanoparticle
        radius = 60e-9;             % Nanoparticle radius
        DI = Dipole('Au',radius);   % creation of the Dipole object
        DI = DI.shine(IL);          % illumination of the dipole

        % compute the images
        IM0 = imaging(DI,IL,MI,Npx);

        % model the experimental interferogram
        Itf = CGMinSilico(IM0,'shotNoise',true);

        % processin the in Silico images
        IM = QLSIprocess(Itf,IL);

        % display the theoretical and in Silico images
        dynamicFigure('gb',IM0,'gb',IM)

    .. image:: /images/NPinSilico.png
        :width: 700


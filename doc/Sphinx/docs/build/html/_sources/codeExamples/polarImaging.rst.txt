Polarisation imaging
++++++++++++++++++++

.. dropdown:: **Polarisation imaging** |subTitle|  Code to process QLSI data acquired with a polar-camera |/subTitle|
    :open:


    .. code-block:: matlab

        %% Build the setup
        ME=Medium('water','glass');
        OB=Objective(100,1.3,'Olympus');
        Cam = Camera(3.45e-6,1,1);
        Grat = CrossGrating('Gamma',39e-6);
        CGcam=CGcamera(Cam,Grat,1.07);
        MI=Microscope(OB,200,CGcam,'PhaseLIVE');
        CGcam.setDistance(0.5e-3);

        lambda=488e-9;
        IL=Illumination(lambda,ME);

        %% Import files
        folder = "data/polarImages";

        Itf = importItfRef(folder,MI);
        Itf.crop("Size",2048);

        Itfmulti = Itf.splitPolars();
        IMmulti = QLSIprocess(Itfmulti,IL);

        polarImages = IMmulti.CGMpolar();

        %% display final figure

        figure,
        subplot(2,2,1)
        imagegb(polarImages.theta0)
        set(gca,'Colormap',hsv)
        title("\theta_0")
        subplot(2,2,2)
        imagegb(polarImages.phibar)
        title("\bar\phi")
        subplot(2,2,3)
        imageph(polarImages.dphi)
        title("\delta\phi")
        subplot(2,2,4)
        imagegb(polarImages.rgbImage)
        colormap(gca,hsv)
        fullscreen
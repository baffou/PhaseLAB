.. dropdown:: **sigmaTheo** |subTitle| returns the theoretical noise standard deviation of the OPD image. |/subTitle|

    .. code-block:: matlab

        MI.sigmaTheo()


    returns the theoretical noise standard deviation expected on the OPD image with this particular microscope, according to ref [#OC521_128577]_ .


    .. code-block:: matlab
        :caption: code example

        >> OB = Objective(100,1.3,'Olympus'); 
        >> MI = Microscope(OB,200,'Silios_mono');
        >> MI.sigmaTheo

        ans =

            4.9235e-10



    .. [#OC521_128577] *Cross-grating phase microscopy (CGM): In-silico experiment (insilex) algorithm, noise and accuracy*, B. Marthy, G. Baffou, **Optics Communications** 521, 128577 (2022)

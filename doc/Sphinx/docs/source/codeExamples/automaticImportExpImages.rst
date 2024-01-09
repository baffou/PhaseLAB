Auto import experimental images
+++++++++++++++++++++++++++++++

.. dropdown:: **Automatically import experimental images** |subTitle|  Code to automatically import experimental interferograms |/subTitle|
    :open:


    .. code:: matlab

        %% code to import an experimental interferogram, process it, and display the QLSI images

        MI=Microscope(OB,180,'Silios_mono','PhaseLIVE'); % Create the Microscope object, and tell the imaging software
        IL = Illumination(532e-9);          % Create the Illumination object
        Itf = imread('data/Itf.tif');       % Import the main interferogram
        Ref = imread('data/Ref.tif');       % Import the reference interferogram
        Im = importItfRef('data', MI);      % Import the interferogram and their references

        % The code knows how to import the images, because the imaging software was indicated (here 'PhaseLive').



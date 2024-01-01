Import experimental images
++++++++++++++++++++++++++

.. dropdown:: **Import experimental images** |subTitle|  Code to import an experimental interferogram, process it, and display the QLSI images |/subTitle|
    :open:


    .. code:: matlab

        %% code to import an experimental interferogram, process it, and display the QLSI images

        MI=Microscope(OB,180,'Silios_mono');% Create the Microscope object
        IL = Illumination(532e-9);          % Create the Illumination object
        Itf = imread('data/Itf.tif');       % Import the main interferogram
        Ref = imread('data/Ref.tif');       % Import the reference interferogram
        Im = Interfero(Itf,MI);             % Make the interferogram object
        Im0 = Interfero(Ref,MI);            % Make the reference interferogram object
        Im.Reference(Im0);                  % Assign the reference to the interferogram
        IM = QLSIprocess(Im,IL);            % Process the QLSI images
        IM.figure;                          % Display the QLSI images

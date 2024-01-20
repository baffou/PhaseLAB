Numerical refocusing
++++++++++++++++++++

.. dropdown:: **Numerical refocusing** |subTitle|  Code to numerically modify the focus of the image |/subTitle|
    :open:


    .. code:: matlab

        %% Code that imports an experimental image (of long Geobacillus bacteria), creates a series of im

        ME=Medium('water','glass');
        OB=Objective(100,0.7,'Olympus');
        MI=Microscope(OB,200,'sC8-944','PhaseLIVE');
        lambda=531e-9;
        IL=Illumination(lambda,ME);

        %% IMPORT THE IMAGES
        folder='GeobLongFilaments';
        Im =importItfRef(folder,MI);

        %% INTERFEROGRAM PROCESSING
        IM=Im.QLSIprocess(IL);

        %% list of defocus values in µm
        zList = -20:10;
        No=length(zList);

        IMlist=ImageQLSI(No);

        for io = 1:No
            IMlist(io) = copy(IM(1));
            IMlist(io) = IMlist(io).propagation(zList(io)*1e-6);
            IMlist(io).comment = [num2str(zList(io)) ' µm'];
        end

        % select the area supposed to correspond to a zero wavfront value
        IMlist.level0(Center="Manual",Size="Manual");

        % crop the image
        IMlist.crop(Size=2000);

        % build a movie from the series of images:
        IMlist.makeMoviedx('/Users/perseus/Documents/im.avi', ...
            persp=0,theta=0, phi=0, ...
            zrange = [-80, 100])



    .. raw:: html

        <video width="448" height="379  " autoplay loop muted>
            <source src="http://guillaume.baffou.com/movies/GeobRefocus.mp4" type="video/mp4">
            Your browser does not support the video tag.
        </video>


Import experimental interferograms
==================================

Experimental images (interferograms) are imported as matrices, and embedded within *Interfero* objects. At least two images need to be imported: the *main* interferogram and the *reference* interferogram.

Manual import
-------------

Let us import the tiff interferograms, named *Itf.tiff* and *Ref.tiff*, located in the folder *data*:

 .. code-block:: matlab
    :linenos:

    Im = imread('data/Itf.tiff');  % load the main interferogram
    Im0 = imread('data/Ref.tiff'); % load the reference interferogram

    % Create the Interfero object
    Itf = Interfero(Im,MI);
    Ref = Interfero(Im0,MI);
    Itf.Reference(Ref);


Automatic import
----------------

If the images have been created using a well-defined acquisition software, the software can be specified when :ref:`creating the microscope <The_Microscope_class>`. And the import of the images gets simplified, using the function |importItfRef|. For instance here, one assumes that the images located in the folder *data* have been acquired using |PhaseLIVE|:

.. code-block:: matlab
    :linenos:

    folder = 'data';
    MI = Microscope(100, 180, 'PhaseLIVE');
    Itf = importItfRef(folder, MI);

In this example, in line 3, the interferogram is defined, and the reference image is automatically downloaded from the proper file, and incorporated within the ``Itf`` object (``Itf.Ref``). If several images are contained in the *data* folder, then they are all imported at once, and ``Itf`` becomes an object array.

If the number of images is particularly large, like several 100s, then one can import only a link to the saved file, so that the RAM memory does not get saturated. The synthax is the following:

.. code-block:: matlab
    :linenos:

    Itf = importItfRef(folder, MI, 'remote', true);

Also, one can import a subset of the images with the keywork *selection*:

.. code-block:: matlab
    :linenos:

    Itf = importItfRef(folder, MI, 'remote', true, 'selection', [1 10 20:50]);
    Itf = importItfRef(folder, MI, 'remote', true, 'selection', 1/20);

Line 1 imports the images 1, 10 and all the images from 20 to 50, while line 2 imports 1 image every 20 images (1, 21, 41, etc).


Finally, it is common to have several series of images within the same folder. For instance, when using |PhaseLIVE|, one can choose a prefix for the saved images. Here is a list of interferograms, all saved in the same folder, where the prefixes were successively *ITF* and *ITF2*:

| *ITF_0001.tif*
| *ITF_0002.tif*
| *ITF_0003.tif*
| *ITF_0004.tif*
| *ITF2_0001.tif*
| *ITF2_0002.tif*
| *ITF2_0003.tif*
| *REF_20210924_11h_38min_405sec.tif*
| *REF_20210924_11h_52min_168sec.tif*

By default, |PhaseLAB| will import them all, without difficulty, but one may want to specifically import the *ITF2*-tagged interferograms for instance. In this case, here is the command:

.. code-block:: matlab
    :linenos:

    Itf = importItfRef(folder, MI, 'nickname', 'ITF2');

For more details on the |importItfRef| function, refer to :ref:`The_importItfRef_function` section.

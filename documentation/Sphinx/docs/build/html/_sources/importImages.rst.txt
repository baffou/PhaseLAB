.. include:: substitutions.rst


Import experimental images
==========================

Experimental images (interferograms) are imported as matrices, embedded in *Interfero* objects. There are at least two images to import: the object interferogram and the reference interferogram.

Manual import
-------------

Let us import the tiff images, named *Itf.tiff* and *Ref.tiff*, located in the folder *data*:

 .. code-block::
    :linenos:

    Im = imread('data/Itf.tiff');
    Im0 = imread('data/Ref.tiff');

    Itf = Interfero(Im,MI);
    Ref = Interfero(Im0,MI);
    Itf.Reference(Ref);


Automatic import
----------------

If the images have been created using a well-defined acquisition software, the software can be specified when creating the microscope. And the importation of the images gets simplified, using the function :py:func:`importItfRef`. For instance here, one assumes that the images located in the folder data have been saved using PhaseLIVE:

.. code-block::
    :linenos:

    folder = 'data';
    MI = Microscope(100, 180, 'PhaseLIVE');
    Itf = importItfRef(folder, MI);

In this example, in line 3, the interferogram is defined, and the reference image is automatically dowloaded from the proper file, and incorporated within the ``Itf`` object (``Itf.Ref``). If several images are contained in the *data* folder, then they are all imported at once, and ``Itf`` becomes an object array.

If the number of images is particularly large, like several 100s, then one can import only a link to the saved file, so that the RAM memory does not get saturated. The synthax is the following:

.. code-block::
    :linenos:

    Itf = importItfRef(folder, MI, 'remote', true);

Also, one can import a subset of the images with the keywork *selection*:

.. code-block::
    :linenos:

    Itf = importItfRef(folder, MI, 'remote', true, 'selection', [1 10 20]);
    Itf = importItfRef(folder, MI, 'remote', true, 'selection', 1/20);

Line 1 imports the images 1, 10 and 20, while line 2 imports 1 image every 20 images.

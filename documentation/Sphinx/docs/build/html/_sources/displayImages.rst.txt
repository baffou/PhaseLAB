.. include:: substitutions.rst
    
Display experimental images
---------------------------

imagesc(), imageph(), imagebw(), imagegb, imagejet()
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Once the Image QLSI objects have been created, they contained all the information regarding the QLSI images. In particular, the OPD and intensity images (matrices) can be accessed by writing ``IM.OPD`` and ``IM.T``.

The images can be displayed using any standard function of Matlab. We recommend :py:func:`imagesc` this way:

.. code-block::
    :linenos:

    figure
    imagesc(IM.OPD)
    set(gca,'DataAspectRatio'n[1 1 1])
    colormap(phase1024)
    colorbar

Equivalently, the :py:func:`imageph` function is defined, which embeds all these code lines:

.. code-block::
    :linenos:

    figure
    imageph(IM.OPD)

Other similar functions are defined, each using a different colorscale, namely

.. list-table:: imageX functions for displaying images
   :widths: 30 30
   :header-rows: 1
   :align: center

   * - Function name
     - Associated colorscale
   * - :py:func:`imagegb()`
     - parula
   * - :py:func:`imageph()`
     - sepia
   * - :py:func:`imagebw()`
     - gray
   * - :py:func:`imagejet()`
     - jet



dynamicFigure()
^^^^^^^^^^^^^^^

:py:func:`dynamicFigure` is a function that can display more than one type of image in one figure (wavefront and intensity for instance). It also enables the navigation thoughout a series of images using the left- and right-arrow keys of the keyboard.

For instance:

.. code-block::
    :linenos:

    dynamicFigure('ph', IMlist)

displays the first figure of the ImageQLSI array. By pressing the right-arrow key, one can move to the next image.

.. figure:: images/displayFigure1.jpg
   :width: 400
   :align: center

ONe ca also display more than one image per figure. For instance, to display both wavefront and intensity, the synthax is:

.. code-block::
    :linenos:

    dynamicFigure('ph', IMlist,'bw', {IMlist.T})
    linkAxes

Don't forget the braces when calling the property of the object. The keywork 'bw' just means here display in gray scale. The command ``linkAxes`` is optional. It links the two images so that any rescaling of the images using the zoom tool applies to both images.

.. figure:: images/displayFigure2.jpg
   :width: 400
   :align: center

There is no limit in the number of images that can be displayed. On can for instance write:

.. code-block::
    :linenos:

    dynamicFigure('ph', IMlist,'bw', {IMlist.T},'bw', {IMlist.DWx},'bw', {IMlist.DWy})
    linkAxes

.. figure:: images/displayFigure4.png
   :width: 600
   :align: center



to display the wavefront gradients as well.

To display a figure full screen, using the command::

    fullScreen


One can also use this function to display interferograms (object and reference):

.. code-block::
    :linenos:
    
    dynamicFigure('bw', {Itf.Itf}, 'bw', {Itf.Ref.Itf})
    linkAxes
    fullscreen
    


.figure()
^^^^^^^^^^^^^^^^^^^

The class ``ImageQLSI`` has a method called :py:func:`figure`, aimed to display the wavefront and intensity images of an ImageQLSI object, or object array, on a GUI. The possible synthaxes are::

    IM.figure
    IM.figure()
    app = IM.figure();

It displays an advanced Matlab GUI where the wavefront and intensity images are displayed, along with a set of tools, for data processing and rendering. The use of this QUI interface is described later on.




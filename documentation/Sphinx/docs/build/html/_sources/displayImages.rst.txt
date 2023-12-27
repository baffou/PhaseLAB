Display experimental images
===========================

The functions: imagesc, imageph, imagebw, imagegb, imagejet
-----------------------------------------------------------
Once the Image QLSI objects have been created, they contained all the information regarding the QLSI images. In particular, the OPD and intensity images (matrices) can be accessed by writing ``IM.OPD`` and ``IM.T``.

The images can be displayed using any standard function of Matlab. We recommend :py:func:`imagesc` this way:

.. code-block::
    :linenos:

    figure
    imagesc(IM.OPD)
    set(gca,'DataAspectRatio',[1 1 1])
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



.. include:: /functions/dynamicFigure.rst



The figure() method
-------------------

The classes ``ImageQLSI`` and ``ImageEM`` have a common method called :py:func:`figure`, aimed to display the wavefront and intensity images of an ImageQLSI object, or object array, on a GUI. The possible synthaxes are::

    IM.figure()
    app = IM.figure();

It displays an advanced Matlab GUI where the wavefront and intensity images are displayed, along with a set of tools, for data processing and rendering. The use of this GUI interface is detailed in :ref:`The GUI of PhaseLAB <The_PhaseLAB_GUI>`.


The opendx() method
-------------------

The classes ``ImageQLSI`` and ``ImageEM`` have a common method called :py:func:`opendx`, aimed to display the wavefront and intensity images with aa 3D rendering. The synthax is:

.. code-block:: matlab

    IM.opendx()
    IM.openndx(Name, Value)

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






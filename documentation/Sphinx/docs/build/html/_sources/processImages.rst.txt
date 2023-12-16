.. include:: substitutions.rst
    
Process experimental images
===========================

Once the *Interfero* object, or object array, is created, the interferograms can be converted into intensity and wavefront images using the :py:func:`QLSIprocess` method of the class *Interfero*. Here is the synthax:

.. code-block::
    :linenos:

    IM = QLSIprocess(Itf,IL);

``IM`` is an *ImageQLSI* object. A large number of keywords can be appended in this method. The comprehensive list if provided in the class section. To name just a few, one can use the keyword *saveGradients* to make sure the gradients are saved, and embedded in ``IM``:


.. code-block::
    :linenos:

    IM = QLSIprocess(Itf,IL,'saveGradients',true);
    dynamicFigure('ph', IM.DWx, 'ph', IM.DWy)

One can also choose between high-definition or low-definition image processing, using the keyword*resolution*:

.. code-block::
    :linenos:

    IM_high = QLSIprocess(Itf,IL,'resolution','high');
    IM_low = QLSIprocess(Itf,IL,'resolution','low');

The QLSI algorithm involves a crop in the Fourier space, centered on the 1st diffraction orders. The crop is made automatically. However, one may want to click oneself on the 1st diffraction order in the Fourier space. In that case, one has to use the keyword *auto* and set it to ``false``:

.. code-block::
    :linenos:

    IM = QLSIprocess(Itf,IL,'auto',false);

In this case, an figure is displayed, waiting for the user to click, several times:

1. The first figure displays the circular crop around the zero order. If the radius is ok, press enter, if not,click on a point of the image to define a more appropriate radius.
2. The zoom mode is turned on, and the user must zoom in to help clicking on a 1st order spot. When the zoom is ok, press enter.
3. Click on a first order pixel.


.. figure:: images/QLSIprocessFigure_1.jpg
   :width: 400
   :align: center
   
   Click to define the radius of the crop, or press enter to leave the default value.


.. figure:: images/QLSIprocessFigure_2.jpg
   :width: 400
   :align: center

   Click on a first order spot.

When a computation have been done for a given interferogram, the crop parameters in the Fourier space are saved within the Interfero object, and any other Interfero image associated with the same reference will use these predefined crop parameters.





















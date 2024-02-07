.. _process_experimental_images:

Process experimental images
===========================

Once the |Interfero| object (array) is created, the interferogram(s) can be converted into intensity and wavefront images using the |c| :ref:`QLSIprocess <The_QLSIprocess_method>` |/c| method of the class |Interfero|. Here is the synthax:

.. code-block:: matlab
    :linenos:

    IM = QLSIprocess(Itf,IL);

|IM| is an |ImageQLSI| object (see :ref:`The_ImageQLSI_class` section)

A large number of keywords can be specified in the QLSIprocess method. The comprehensive list is provided in :ref:`The QLSIprocess method <The_QLSIprocess_method>` section. To name just a few, one can use the keyword :matlab:`'saveGradients'` to make sure the gradients are saved, and embedded within |IM|:

.. code-block:: matlab
    :linenos:

    IM = QLSIprocess(Itf,IL,'saveGradients',true);
    dynamicFigure('ph', IM.DWx, 'ph', IM.DWy)

One can also choose between high-definition or low-definition image processing, using the keyword :matlab:`'resolution'`:

.. code-block:: matlab
    :linenos:

    IM_high = QLSIprocess(Itf,IL,'resolution','high');
    IM_low = QLSIprocess(Itf,IL,'resolution','low');

The QLSI algorithm involves a crop in the Fourier space, centered on the 1\ |st|  diffraction orders. The crop is made automatically. However, one may want to click oneself on the 1\ |st| diffraction order in the Fourier space. In that case, one has to use the keyword :matlab:`'auto'` and set it to ``false``:

.. code-block:: matlab
    :linenos:

    IM = QLSIprocess(Itf,IL,'auto',false);

In this case, a figure is displayed, waiting for the user to click, several times:

1. The first figure displays the circular crop around the zero order. If the radius is ok, press enter, if not, click on a point of the image to define a more appropriate radius.
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

When a computation has been done for a given interferogram, the crop parameters in the Fourier space are saved within the |Interfero| object, and any other |Interfero| image associated with the same reference will use these predefined crop parameters.

For more information on how to process |Interfero| objects, refer to :ref:`The QLSIprocess method <The_QLSIprocess_method>` section.





















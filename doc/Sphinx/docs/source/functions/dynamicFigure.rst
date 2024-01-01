The dynamicFigure function
--------------------------

:py:func:`dynamicFigure` is a function that can display more than one type of image in one figure (wavefront and intensity for instance). It also enables the navigation thoughout a series of images using the left- and right-arrow keys of the keyboard.

For instance:

.. code-block:: matlab
    :linenos:

    dynamicFigure('ph', IMlist)

displays the first figure of the *ImageQLSI* array.

.. figure:: /images/displayFigure1.jpg
   :width: 400
   :align: center

One can also display more than one image per figure. For instance, to display both wavefront and intensity, the synthax is:

.. code-block:: matlab
    :linenos:

    dynamicFigure('ph', IMlist,'bw', {IMlist.T})
    linkAxes

Don't forget the braces when calling the property of the object. The keywork 'bw' just means here display in gray scale. The command ``linkAxes`` is optional. It links the two images so that any rescaling of the images using the zoom tool applies to both images.

.. figure:: /images/displayFigure2.jpg
   :width: 700
   :align: center

There is no limit in the number of images that can be displayed. On can for instance write:

.. code-block:: matlab
    :linenos:

    dynamicFigure('ph', IMlist,'bw', {IMlist.T},'bw', {IMlist.DWx},'bw', {IMlist.DWy})
    linkAxes

.. figure:: /images/displayFigure4.png
   :width: 600
   :align: center


to display the wavefront gradients as well.

To display a figure full screen, append the command::

    fullScreen


One can also use this function to display interferograms (main and reference):

.. code-block:: matlab
    :linenos:
    
    dynamicFigure('bw', {Itf.Itf}, 'bw', {Itf.Ref.Itf})
    linkAxes
    fullscreen

This function also work if ``IM`` of ``Itf`` in an object array. In this, case the first object of the series is primarily displayed, and then, by pressing the right-arrow or left-arrow keys, one can navigate to the next or previous images.
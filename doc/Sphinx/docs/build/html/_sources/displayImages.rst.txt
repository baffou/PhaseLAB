Display experimental images
===========================

The functions: |c| imagesc |/c|, |c| imageph |/c|, |c| imagebw |/c| , |c| imagegb |/c|, |c| imagejet |/c| 
---------------------------------------------------------------------------------------------------------

Once the |ImageQLSI| objects have been created, they contain all the information regarding the QLSI images. In particular, the OPD and intensity images (matrices) can be accessed by writing ``IM.OPD`` and ``IM.T``.

The images can be displayed using any standard function of Matlab. We recommend using the native ``imagesc`` matlab function, this way:

.. code-block::
    :linenos:

    figure
    imagesc(IM.OPD)
    set(gca,'DataAspectRatio',[1 1 1]) % avoids image distorsion
    colormap(Sepia)
    colorbar

To avoid repeating all these code lines each time one wants to display the OPD images, all these code lines have been embeddedd within the ``imageph`` function:

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
   * - ``imagegb``
     - parula
   * - ``imageph``
     - sepia
   * - ``imagebw``
     - gray
   * - ``imagejet``
     - jet



.. include:: /functions/dynamicFigure.rst



The |c| figure |/c| method
--------------------------

The classes |ImageQLSI| and |ImageEM| have a common method called ``figure``, aimed to display the wavefront and intensity images of an ImageQLSI object, or object array, on a GUI. The possible synthaxes are:

.. code-block:: matlab

    IM.figure()

or

.. code-block:: matlab
    
    app = IM.figure();

It displays an advanced Matlab GUI where the wavefront and intensity images are displayed, along with a set of tools, for data processing and rendering. The use of this GUI interface is detailed in :ref:`The GUI of PhaseLAB <The_PhaseLAB_GUI>`.


The |c| opendx |/c| method
--------------------------

The classes |ImageQLSI| and |ImageEM| have a common method called ``opendx``, aimed to display the wavefront and intensity images with a 3D rendering. The synthax is:

.. code-block:: matlab

    IM.opendx()
    IM.opendx(Name, Value)

Here is an example of 3D rendering using the opendx method, compared with the rendering of the ``imageph`` function:



.. tabs::

   .. tab:: |c| opendx |/c| 3D rendering

        .. figure:: /images/opendx_image.png
            :width: 700
            :align: center

   .. tab:: |c| imageph |/c| Sepia rendering

        .. figure:: /images/sepia_image2.png
            :width: 700
            :align: center


For more information on the ``opendx`` method, see :ref:`The opendx method <The_opendx_method>` section.

Color scales
------------

All the native color scale of Matlab can naturally be used when displaying |PhaseLAB| images. Also, in the |c| /src/colorMaps |/c| folder, there are predefined colormaps. To display them, just execute the following command, and window will appear with all of them:

.. code-block::

    displayColormaps()


.. figure:: /images/displayColorMaps.png
    :width: 600
    :align: center

To use any of them, use the ``colormap`` command:

.. code-block:: matlab

    colormap(Pradeep)

where the input is simply the name of the desired color map.


Color scale generator
---------------------

colorMapGenerator is |PhaseLAB| function aim to easily create user-designed color maps. Here is an example:

.. code-block:: matlab
    :linenos:

    colorList = ["000000";"560000";"AD3200";"FF8B00";"FFD900";"FFFF5B";"FFFFFF"];
    % colorList = ["ffffff";"d9d1a7";"b4913e";"805b28";"492d15";"000000"];
    % colorList = ["100080";"6500dc";"9a00c4";"d21536";"ff8000";"ffe700";"ffffff"];

    posList = [0, 17, 33, 50, 66, 84, 100];

    colMap = colorScaleGenerator(colorList,posList,256);

    figure
    imagegb(meshgrid(1:1024,1:100))
    colormap(colMap)

   

.. figure:: /images/genColorMapEx.png
    :width: 300
    :align: center

In line 1, a series of 7 colors is stored in a string array, in HEX format.

Line 2 and 3 are other examples of color arrays

Line 5 defines a vector that gathers the positions of the color along an axis going from 0 to 100.

Line 7 uses the ``colorScaleGenerator`` function to create a 256x3 color matrix, in the format of a colormap variable to be used as an in put of the ``colormap``  function, as shown in line 11.


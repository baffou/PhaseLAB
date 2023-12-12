Build the optical setup
-----------------------

In CGM, the grating-camera distance is the only required knowledge to be able to reconstruct a wavefront profile from a recorded interferogram. One does not need to know the wavelength or the microscope magnification. However, in the first part of a PhaseLAB, we shall nevertheless indicate all the parameters of the microscope, because some postprocessing tools require the knowledge of some general features of the microscope.


In PhaseLAB, a microscope is an object, from the class ``Microscope``. We usually name it ``MI``. We define it using the constructor method ``Microscope``. A microscope excludes the illumination. An illumation is a separated object, from the class ``Illumination``, usually called ``IL``. Let us explain below how to define them.


Defining the Illumination
^^^^^^^^^^^^^^^^^^^^^^^^^

Here is the simplest definition of an Illumination object::

    >> IL = Illumination(532e-9);

where the argument is the wavelength of the illumination.

The ``IL`` variable contains all the properties of the illumination. Since only one property of the microscope has been defined with this code line, the wavelength, all the other properties have been set to default values. To visualize all the ``IL`` properties, just enter ``LI``::

    >> IL

    IL = 

    Illumination with properties:

        lambda: 5.3200e-07
             I: 1
        direct: [0 0 1]
         polar: [1 0 0]
            NA: 0

5 public properties are displayed. For instance, the wavelength we just specified is the ``lambda`` property. One can access this parameter by writing ``IL.lambda``. The other parameters, ``I``, ``direct``, ``polar``,  and ``NA``, are used when using the simulation functionalites of the PhaseLAB toolbox. To process experimental images, they are ignored, and only the wavelength matters.

Defining the Microscope
^^^^^^^^^^^^^^^^^^^^^^^
Here is the simplest definition of a Microscope object::

    >> MI = Microscope(100);

where the argument is the magnification of the microscope.

The ``MI`` variable contains all the properties of the microscope. Since only one property of the microscope has been defined with this code line, the microscope magnification, all the other properties have been set to default values. To visualize all the microscope properties, just display ``MI``::

    >> MI

       MI = 

            Microscope with properties:

                Objective: [1×1 Objective]
                    CGcam: [1×1 CGcamera]
                    f_TL: 180
                software: ''
                        M: -100
                pxSize: 6.5000e-08
                    zo: 0
                    T0: []

8 public properties are displayed. For instance, the magnification we just specified is the ``M`` property. These is a negative sign because a microscope's image is naturally inverted. The property ``f_tl`` is the focal length of the tube lens, by default 180 mm (Olympus default value). ``pxSize`` is another important parameter. It tells what the pixel size of the image is.


The ``Objective`` and ``CGcam`` properties are both objects, respectively from the classes ``Objective`` and ``CGcamera``.

Let us display the Objective object and its properties::

    >> MI.Objective

    ans = 

    Objective with properties:

            Mobj: 100
            NA: 1
        objBrand: 'Olympus'
            mask: [0×0 PCmask]

The properties ``Mobj``is set to 100, the value we specified when building the microscope. ``NA`` is the numerical aperture of the microscope. This property is ignored when dealing with experimental images. It is only used when running numerical simulation of images. The ``objBrand`` property specifies the brand of the objective lens. It is important to specify in the case the objective brand is not the same as the microscope brand. The magnificatio written on the objective lens assumes a specific focal length of the tube lens. And from one manufacturer to another, the convention differs. Here is a table recalling the conventions:

.. list-table:: Tube length (TL) focal lengths for each microscope manufacturer
   :widths: 30 30
   :header-rows: 1
   :align: center

   * - Microscope brand
     - TL focal length
   * - Leica
     - 200 mm
   * - Nikon
     - 200 mm
   * - Olympus
     - 180 mm
   * - Zeiss
     - 165 mm



Defining a Camera
^^^^^^^^^^^^^^^^^

Compact camera
""""""""""""""


The main package of the folder contains several subfolders. One of them, called *CGcameras*, contains of the ascii (.txt) files gathering the properties of QLSI cameras.  For instance, the commercial cameras from Silios and Phasics companies can be selected. Let us pich the Silios one, called *Silios_mono*. For this purpose, one can use the constructor of the CGcamera class with the name of the camera as the only input::

    CGcam = CGcamera('Silios_mono');

and then incorporate this camera in the microscope using::

    MI = Microscope(100, 180, CGcam);

Here are the list of predefined cameras in the *CGcameras* directory:

.. list-table:: List of predefined cameras in PhaseLAB
   :widths: 30 100
   :header-rows: 1
   :align: center

   * - File name
     - Description
   * - sC8-830
     - SID4-sC8 camera we own.
   * - sC8-940
     - SID4-sC8 camera we own.
   * - Sid4Element-Sona
     - Relay lens from Phasics, when associated with a Sona camera
   * - Sid4Element
     - Relay lens from Phasics, when associated with a Zyla camera
   * - Silios_mono
     - Camera from Silios

One can also define a new CGcamera configuration file. Here is what a configuration file look like

.. code-block:: python
    :caption: The Silios_mono.txt file.

    camera pixel size:	5.5e-6
    Gamma:	33e-6
    Nx:2048
    Ny:2048
    MHM angle
    distance:	0.75e-3
    CGdepth: 550e-9
    CGangle: 57.0078

These parameters represent respectively:

* camera pixel size: The camera pixel size (i.e. dexel size)
* Gamma: The Gamma factor
* Nx: The number of columns of the sensor
* Ny: The numer of rows of the sensor
* distance: the grating-camera distance
* CGdepth: The etching distance of the cross-grating
* CGangle: the rotation angle of the grating



Home made camera including a relay-lens
"""""""""""""""""""""""""""""""""""""""


.. code-block:: python
   :emphasize-lines: 3,5

   def some_function():
       interesting = False
       print('This line is highlighted.')
       print('This one is not...')
       print('...but this one is.')
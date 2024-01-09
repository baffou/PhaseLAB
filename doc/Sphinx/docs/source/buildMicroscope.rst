Build the optical setup
=======================


In |PhaseLAB|, the setup is composed of two objects:

- a |Microscope| object

    We usually name the |Microscope| object |MI|. It gathers all the parameters related to the objective lens, camera, cross-grating, relay lens, etc. 

- an |Illumination| object. 

    The |Illumination| object is usually called |IL|. It gathers the information on the incident light illumination (wavelength, polarization, direction, etc).



Defining the Illumination
-------------------------

Here is the simplest definition of an |Illumination| object:

.. code-block:: matlab

    >> IL = Illumination(532e-9);

where the argument is the wavelength of the illumination.

The |IL| variable contains all the properties of the illumination. Since only one property of the microscope has been defined with this code line, the wavelength, all the other properties have been set to default values. To visualize all the |IL| properties, just enter |IL| in the Matlab command window:

.. code-block:: matlab

    >> IL

    IL = 

        Illumination with properties:

        lambda: 5.3200e-07
        I: 1
        direct: [0 0 1]
        polar: [1 0 0]
        NA: 0

5 public properties are displayed. For instance, the wavelength we just specified is the :matlab:`lambda` property. One can access this parameter by writing :matlab:`IL.lambda`. The other parameters, :matlab:`I`, :matlab:`direct`, :matlab:`polar`,  and :matlab:`NA`, are used when using the simulation functionalites of the |PhaseLAB| toolbox. To process *experimental* images, they are ignored, and only the wavelength matters. When dealing with simulated images, however, one can modify these parameters. Here are some examples:

.. code-block:: matlab

    IL.polar = [0 1 0];
    IL.NA = 0.7;

For more information on how to build an |Illumination| object, refer to :ref:`The_Illumination_class` section.

Defining the Microscope
-----------------------

Here are typical code lines to define the microscope:

.. code-block:: matlab

    >>  OB = Objective(100,1.3,'Olympus');
    >>  MI = Microscope(OB,'Nikon','Silios_mono','PhaseLIVE')

    MI = 

    Microscope with properties:

        Objective: [1×1 Objective]
        CGcam: [1×1 CGcamera]
        f_TL: 200
        software: 'PhaseLIVE'
        M: -111.1111
        pxSize: 4.9500e-08
        zo: 0
        T0: []

An |Objective| object is firstly defined. It enables the specification of the magnification, the numerical aperture and the objective brand. The 3rd (optional) input is the objective brand. If not specified, the default value is :matlab:`'Olympus'`.


Then, a |Microscope| object is defined. It takes an |Objective| object as a first input, the microscope brand (or the focal length of the tube lens) as the second input, and optionally the name of the QLSI camera and the software used to acquire the images.

For more information on how to build the microscope, see :ref:`The_Microscope_class` section.

Defining the QLSI Camera
------------------------

The QLSI camera is represented by a |CGcamera| object, and is contained within the |Microscope| object. Here is how it looks:

.. code-block:: matlab

    >> MI.CGcam

    ans = 

        CGcamera with properties:

        Camera: [1×1 Camera]
            RL: [0×0 RelayLens]
            CG: [1×1 CrossGrating]
        fileName: 'Silios_mono'
            CGpos: 7.5000e-04
            dxSize: 5.5000e-06
            zeta: 3.0000
            zoom: 1


Many parameters define a QLSI camera. But no need to enter all of them, one by one. There are predefined QLSI cameras in |PhaseLAB|. Here is the list:

.. list-table:: List of predefined cameras in PhaseLAB
    :widths: 30 100
    :header-rows: 1
    :align: center

    * - File name
      - Description
    * - |c| sC8-830 |/c|
      - SID4-sC8 camera we own.
    * - |c| sC8-940 |/c|
      - SID4-sC8 camera we own.
    * - |c| Sid4Element-Sona |/c|
      - Relay lens from Phasics, when associated with a Sona camera
    * - |c| Sid4Element |/c|
      - Relay lens from Phasics, when associated with a Zyla camera
    * - |c| Silios_mono |/c|
      - Camera from Silios

Implementing a QLSI camera is done when building the microscope, by specifying a 3rd input to the constructor with the name of the QLSI camera:

.. code-block:: matlab

    MI = Microscope(OB,'Nikon','Silios_mono')


If your camera is not in the list, you can build your own QLSI camera (i.e., :matlab:`CGcam` object) step by step, this way:

.. code-block:: matlab

    Grating = CrossGrating(Gamma=39e-6,lambda0=630e-9);  % define the cross-grating
    Cam = Camera('Zyla');                                % define the camera
    relayLensZoom = 1.11;                                % set the zoom of the relay-lens
    CGcam = CGcamera(Cam, Grating, relayLensZoom);       % define the QLSI camera
    MI = Microscope(100, 'Olympus', CGcam);              % defines the microscope

More information on the construction of custom |CrossGrating|, |Camera| and |CGcamera| objects can be found in the sections :ref:`The_Camera_class`, :ref:`The_CGcamera_class`, and :ref:`The_CrossGrating_class`.


Summary
-------


.. tabs::

    .. tab:: Simple microscope construction

        .. code-block:: matlab

            IL = Illumination(630e-9);                               % define the illumination
            MI = Microscope(100, 'Nikon', 'Silios_mono', 'PhaseLIVE');% define the microscope

    .. tab:: Advanced microscope construction

        .. code-block:: matlab

            IL = Illumination(630e-9);                         % define the illumination
            Grating = CrossGrating(Gamma=39e-6,lambda0=630e-9);% define the cross-grating
            Cam = Camera('Zyla');                              % define the camera
            relayLensZoom = 1.11;                              % set the zoom of the relay-lens
            CGcam = CGcamera(Cam, Grating, relayLensZoom);     % define the QLSI camera
            OB = Objective(100, 1.3, 'Olympus')                % define the objective lens
            MI = Microscope(OB, 'Nikon', CGcam, 'PhaseLIVE');  % defines the microscope

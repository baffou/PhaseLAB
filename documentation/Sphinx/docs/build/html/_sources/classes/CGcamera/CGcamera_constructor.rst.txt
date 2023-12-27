Constructor
-----------

.. dropdown:: **Constructor**

    .. raw:: html
      
        <p class="title">Synthax</p>

    .. code-block:: matlab
        :caption: Prototypes

        % possible forms
        obj = CGcamera();
        obj = CGcamera(camName);
        obj = CGcamera(CGcamName);
        obj = CGcamera(camName,CGname);
        obj = CGcamera(camName,CGname,zoom);

        % examples
        obj = CGcamera('Zyla');
        obj = CGcamera('Silios_mono');
        obj = CGcamera('Zyla', 'F3');
        obj = CGcamera('Zyla', 'P2', 1.11);

    .. raw:: html
        
        <div class="title">Description</div>

    :matlab:`obj = CGcamera()` creates an empty *CGcamera* object.

    |hr|


    :matlab:`obj = CGcamera(camName)` creates a *CGcamera* object that consists only of a camera (no relay-lens, no cross-grating). ``camName`` is a *char* that defines the camera. The camera names must correspond to the names of the files contained in the folder **cameras**. For instance, :matlab:`obj = CGcamera('Zyla');`.

    |hr|


    :matlab:`obj = CGcamera(CGcamName)` creates a *CGcamera* object from the name of a QLSI device. The CGcamera names must correspond to the names of the files contained in the folder **CGcameras**. For instance, :matlab:`obj = CGcamera('Silios_mono');`.

    |hr|


    :matlab:`obj = Interfero(camName, CGname)` creates a *CGcamera* object ``obj`` from the specification of a camera and a cross-grating. ``camName`` is the *char* name of the camera, and ``CGname`` is the *char* name of the cross-grating. The possible names of the camera and cross-grating are the names of the files contained in the folder **cameras** and **CG**. For instance, :matlab:`obj = CGcamera('Zyla','P4');`.

    |hr|

    :matlab:`obj = Interfero(camName, CGname, zoom)` creates a *CGcamera* object ``obj`` from the specification of a camera, a cross-grating, and a zoom. ``camName`` is the *char* name of the camera, ``CGname`` is the *char* name of the cross-grating, and ``zoom`` is a number that corresponds to the zoom of a relay lens. The possible names of the camera and cross-grating are the names of the files contained in the folder **cameras** and **CG**. For instance, :matlab:`CGcam = CGcamera('Zyla','P4');`. The specification of a zoom value leads to the creation of a non-empty ``RL`` attributes in the *CGcamera* object.

    .. raw:: html
        
        <p class="title">Create a custom CGcameras</p>
 

CGcamera spec files
-----------------------------

The folder **CGcameras** contains *.txt* files associated to each predefined camera, namely:

- *sC8-830.txt*

    A sC8 camera from Phasics we own at the Institut Fresnel, with the reference number 830.

- *sC8-944.txt*

    A sC8 camera from Phasics we own at the Institut Fresnel, with the reference number 944.

- *Sid4-CRHEA*

    A Sid4-HR camera from Phasics own by the CRHEA in Nice, France.

- *Sid4-Element-Sona*

    Our Sid4-Element from Phasics, associated with a Sona camera from Andor

- *Sid4Element*

    Our Sid4-Element from Phasics, associated with a Zyla 5.5 camera from Andor

- *Silios_mono*

    The wavefront camera from Silios

Each spec file contains all the characteristics of the camera. Here is for instance a copy of the Silios_mono.txt file:

.. code-block::

    dexel size: 5.5e-6
    Gamma: 33e-6
    Nx: 2048
    Ny: 2048
    distance: 0.75e-3
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


If other QLSI cameras are being used, new custom files can be made, following this pattern and placed in the **CGcamera** folder,










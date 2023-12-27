Constructor
-----------

.. dropdown:: **Constructor**

    .. raw:: html
      
        <p class="title">Synthax</p>

    .. code-block:: matlab
        :caption: Prototypes

        % possible forms
        obj = Camera();
        obj = Camera(camName);
        obj = Camera(dxSize,N);
        obj = Camera(dxSize, Nx, Ny); 

        % examples
        obj = Camera('Zyla');
        obj = Camera(5.5e-6, 2048);
        obj = Camera(5.2e-6, 2160, 2048);

    .. raw:: html
        
        <div class="title">Description</div>

    :matlab:`obj = CGcamera()` creates an empty *Camera* object.

    |hr|


    :matlab:`obj = Camera(camName)` creates a *Camera* object, where ``camName`` is a *char* that defines the camera. The camera names must correspond to the names of the files contained in the folder **cameras**. For instance, :matlab:`obj = Camera('Zyla');`.

    |hr|


    :matlab:`obj = Camera(dxSize,N);` creates a *Camera* object ``obj`` with a dexel size ``dxSize`` and with a ``N`` x ``N`` sensor size.

    |hr|

    :matlab:`obj = Camera(dxSize,Nx,Ny);` creates a *Camera* object ``obj`` with a dexel size ``dxSize`` and with a ``Nx`` x ``Ny`` sensor size.

    .. raw:: html
        
        <p class="title">Create a custom CGcameras</p>
 

Camera spec files
-----------------------------

The folder **Cameras** contains *.json* files associated to each predefined camera, namely:

- *FirstLight.json*

    A camera from the FirstLight company.

- *Pixelink*

    The M20 Pixelink camera.

- *Retiga*

    A Retiga camera (the one used in the Sid4Bio cameras from Phasics)

- *Silios*

    The 2-color camera we own from SILIOS.

- *Sona*

    The Sona camera crom Andor.

- *Zyla.json*

    The Zyla 5.5 from Andor (the one used in the sC8 cameras from Phasics)


Each spec file contains all the characteristics of the camera. Here is for instance a copy of the Zyla.json file:

.. code-block:: json

    {"class":"Camera",
    "model": "Zyla",
    "dxSize": 6.5e-6,
    "Nx": 2560,
    "Ny": 2160,
    "fullWellCapacity": 25000,
    "offset":100,
    "colorChannels":1
    }

All these parameters are respectively the class (*Camera*), the model, the dexel size, the number of columns, the number of rows, the full well capacity, the constructor offset (in counts) and the number of color channels.














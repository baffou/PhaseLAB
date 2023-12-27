Constructor
-----------

.. dropdown:: **Constructor**

    .. raw:: html
      
        <p class="title">Synthax</p>

    .. code-block:: matlab
        :caption: Prototypes

        % possible forms
        obj = CrossGrating();
        obj = CrossGrating(name);
        obj = CrossGrating(Gamma=val1,depth=val2);
        obj = CrossGrating(Gamma=val1,lambda0=val2);
 
        % examples
        obj = CrossGrating();
        obj = CrossGrating('F2');
        obj = CrossGrating('Gamma',39e-6,'depth',554e-9);
        obj = CrossGrating('Gamma',39e-6,'lambda0',600e-9);

    .. raw:: html
        
        <div class="title">Description</div>

    :matlab:`obj = CrossGrating()` creates an empty *CrossGrating* object.

    |hr|

    :matlab:`obj = CrossGrating(name)` creates a *CrossGrating* object, where ``name`` is a *char* that defines the grating. The grating names must correspond to the names of the .json files contained in the folder **CG**. For instance, :matlab:`obj = Camera('F2');`.

    |hr|

    :matlab:`obj = CrossGrating(Gamma=val1,depth=val2);` creates a *CrossGrating* object with a pitch specified by ``Gamma`` and the etching depth by ``'depth'``.

    |hr|

    :matlab:`obj = CrossGrating(Gamma=val1,depth=val2);` creates a *CrossGrating* object with a pitch specified by ``Gamma`` and the nominal wavelength ``'lambda0'``. Either the depth or lambda0 can be specified. The two are linked via the relation ``lambda0 = 2*depth*(RI-1)``.
 

CrossGrating spec files
-----------------------------

The folder **CG** contains *.json* files associated to each predefined cross-grating. Here is for instance a copy of the *F2.json* file:

.. code-block:: json

    {"class":"CrossGrating",
    "Gamma": 39e-6,
    "name": "F2",
    "depth": 554e-9,
    "RI": 1.46,
    "lambda0": 509.68e-9
    }

All these parameters are respectively the class, the pitch, the reference, the etching depth, the refractive index of the grating glass, and the nominal wavelength.

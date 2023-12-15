.. include:: substitutions.rst


The Microscope class
--------------------

Properties
^^^^^^^^^^

.. list-table:: Public properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - default
     - description
   * - ``Objective``
     - *Objective*
     - 
     - Objective lens
   * - ``CGcam``
     - *CGcamera*
     - 
     - QLSI camera
   * - ``f_TL``
     - *double*
     - 180
     - Objective lens
   * - ``software``
     - *char*
     - 
     - software used with the microscope ('PhaseLIVE', 'Sid4Bio')
   * - ``zo``
     - *double*
     - 0
     - defocus


.. list-table:: Dependent properties
   :widths: 30 30 30 100 
   :header-rows: 1
   :align: center

   * - name
     - type
     - dependence
     - description
   * - ``M``
     - double
     - ``= -this.Mobj*m.f_TL/this.f_brand``
     - magnification of the microscope
   * - ``pxSize``
     - double
     - ``= abs( this.CGcam.dxSize()/this.M );``
     - pixel size of the image



Constructor
^^^^^^^^^^^
.. code-block:: python
    :caption: Prototypes

    Microscope(M)
    Microscope(OB)
    Microscope(OB,f_TL)
    Microscope(OB,f_TL,CGcam)
    Microscope(OB,f_TL,Cam)
    Microscope(OB,f_TL,CGcam,software)

where ``M`` is the objective magnification, ``OB`` is an *Objective* object, ``f_TL`` is the focal length of the tube lens, ``CGcam`` is a *CGcamera* object, ``Cam`` is a *Camera* object and ``software`` is the software used to acquire data (must belong to *{'Sid4Bio','PHAST','CG','PhaseLIVE','other'}*).

Methods
^^^^^^^

camList()
"""""""""

Displays the list of predefined camera names.

.. code-block:: python

    >> MI.camList

    ans =

        5x1 cell array

        {'Sid4Element-Sona'}
        {'Sid4Element'     }
        {'Silios_mono'     }
        {'sC8-830'         }
        {'sC8-944'         }


This list gives the possible values of the ``CGcam`` input in the Microscope constructor.


Mobj()
""""""

.. code-block:: python

    MI.Mobj()

returns ``MI.Objective.Mobj``, the magnification written on the objective lens.


NA()
""""

.. code-block:: python

    MI.NA()

returns ``MI.Objective.NA``, the numerical aperture of the objective.


objBrand()
""""""""""

.. code-block:: python

    MI.objBrand()

returns ``MI.Objective.objBrand``, the brand of the objective.


sigmaTheo()
"""""""""""


.. code-block:: python

    MI.sigmaTheo()


returns the theoretical noise standard deviation expected on the OPD image with this particular microscope, according to ref [#OC521_128577]_ .


.. code-block:: python
    :caption: code example

    >> OB = Objective(100,1.3,'Olympus'); 
    >> MI = Microscope(OB,200,'Silios_mono');
    >> MI.sigmaTheo

    ans =

        4.9235e-10



.. [#OC521_128577] *Cross-grating phase microscopy (CGM): In-silico experiment (insilex) algorithm, noise and accuracy*, B. Marthy, G. Baffou, **Optics Communications** 521, 128577 (2022)

Constructor
-----------

.. dropdown:: **Constructor**

    .. raw:: html
      
        <p class="title">Synthax</p>

    .. code-block:: matlab
        :caption: Prototypes

        % possible forms
        obj = Dipole();
        obj = Dipole(mat, radius);
        obj = Dipole(mat, radius, z);

        % examples
        obj = Dipole('Au', 20e-9);
        obj = Dipole('SiO2', 50e-9', 200e-9);

    .. raw:: html
        
        <div class="title">Description</div>

    :matlab:`obj = Dipole()` creates an empty *Dipole* object.

    |hr|


    :matlab:`obj = Dipole(mat, radius)` creates a *Dipole* object that corresponds to a nanosphere of radius ``radius``and material ``mat``.

    |hr|

    :matlab:`obj = Dipole(mat, radius, z)` creates a *Dipole* object that corresponds to a nanosphere of radius ``radius``and material ``mat``, shited to the position ``z`` along the $z$ axis.

.. dropdown:: **propagation** |subTitle| Applies a variation of the microscope focus on the images. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        % general form
        obj.propagation(z)
        objList.propagation(z)
        obj2 = obj.propagation(z);

        % examples
        obj.propagation(-1e-6)
        obj2 = obj.propagation(0.2e-6);

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.propagation(z)`` computes the new ``T`` and ``OPD`` images when a variation ``z`` of the focus of the microscope is numerically applied.

    |hr|

    Objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output ``obj2`` is used, ``obj2 = obj.propagation(z)``, then the object is not modified, and is duplicated.
    



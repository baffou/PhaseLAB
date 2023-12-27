.. dropdown:: **propagation** |subTitle| propagates the field along the *z* direction. |/subTitle|

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

    ``obj.propagation(z)`` computes the new E field and incident E field after a propagation distance ``z``.

    |hr|

    *ImageEM* object vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output ``obj2`` is used, ``obj2 = obj.propagation(z)``, then the object is not modified, and is duplicated.
    



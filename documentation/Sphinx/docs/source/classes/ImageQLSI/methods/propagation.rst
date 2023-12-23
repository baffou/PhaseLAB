.. dropdown:: **propagation** |subTitle| Applies a variation of the microscope focus on the *ImageQLSI* object. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.propagation(z)
        objList.propagation(___);
        obj2 = obj.propagation(___);

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.propagation(z)`` computes the new ``T`` and ``OPD`` images when a variation ``z`` of the focus of the microscope is numerically applied.

    .. include:: ../hr.txt

    *ImageQLSI* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    .. include:: ../hr.txt

    If an output ``obj2`` is used, ``obj2 = obj.propagation(z)``, then the object is not modified, and is duplicated.
    



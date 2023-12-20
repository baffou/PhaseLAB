.. dropdown:: **rot90**
    
    Rotate the images of the object by multiples of 90°.

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.rot90();
        obj.rot90(k);
        objList.rot90(___);
        obj2 = obj.rot90(___);
        
    .. raw:: html
      
        <p class="title">Description</p>

    
    ``obj.rot90()`` rotates the images of the object by 90°, counterclockwise.
    
    .. include:: ../hr.txt

    ``obj.rot90(k)`` rotates the images of the object by :math:`k\times90°`, counterclockwise. ``k`` must be an integer and can be negative.

    .. include:: ../hr.txt

    *ImageQLSI* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    .. include:: ../hr.txt

    If an output ``obj2`` is used, then the object is not modified, and duplicated.
    


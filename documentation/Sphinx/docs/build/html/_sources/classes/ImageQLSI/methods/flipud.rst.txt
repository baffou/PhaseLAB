.. dropdown:: **flipud**
    
    Flips the images of the object about the horizontal axis (flips up-down).

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.flipud();
        objList.flipud();
        obj2 = obj.flipud();
        
    .. raw:: html
      
        <p class="title">Description</p>

    .. include:: ../hr.txt

    *ImageQLSI* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    .. include:: ../hr.txt

    If an output ``obj2`` is used, then the object is not modified, and duplicated.
 
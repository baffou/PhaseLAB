.. dropdown:: **fliplr** |subTitle| Flips the images of the object about the vertical axis (flips left-right). |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.fliplr();
        objList.fliplr();
        obj2 = obj.fliplr();
        
    .. raw:: html
      
        <p class="title">Description</p>

    |hr|

    *ImageQLSI* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output ``obj2`` is used, then the object is not modified, and duplicated.
 
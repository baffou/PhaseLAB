.. dropdown:: **flipud** |subTitle| Flips the images of the object about the horizontal axis (flips up-down). |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.flipud();
        objList.flipud();
        obj2 = obj.flipud();
        
    .. raw:: html
      
        <p class="title">Description</p>

    |hr|

    *ImageEM* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output ``obj2`` is used, then the object is not modified, and duplicated.
 
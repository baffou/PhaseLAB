.. dropdown:: **smooth** |subTitle| Applies a low-pass filter on the spatial frequencies of the image, as a means to blur the image. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.smooth()
        obj.smooth(n)
        obj2 = obj.smooth(___)
        objList.smooth(___)
        objList2 = objList.smooth(___)


    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.smooth()`` applies a low-pass filter on the spatial frequencies of the ``OPD`` image, as a means to remove the high frequencies and blur the OPD image. It actually simply applies a Gaussian-blurring on the ``OPD`` image using the *imgaussfilt* function with, by default, ``sigma = 10``.

    |hr|

    ``obj.smooth(n)`` applies a low-pass filter on the spatial frequencies of the image. ``n`` is the ``sigma`` parameter of the *imgaussfilt* function. The larger ``n``, the flatter the OPD image look.
    
    |hr|

    *ImageQLSI* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output is used, ``obj2``, then the object is not modified, and is duplicated.
    





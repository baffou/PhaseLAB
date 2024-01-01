.. dropdown:: **highPassFilter** |subTitle| Applies a high-pass filter on the spatial frequencies of the image, as a means to remove the lwo frequencies and highlight the details. |/subTitle|



    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.highPassFilter()
        obj.highPassFilter(n)
        obj2 = obj.highPassFilter(___)
        objList.highPassFilter(___)
        objList2 = objList.highPassFilter(___)


    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.highPassFilter()`` applies a high-pass filter on the spatial frequencies of the ``OPD`` image, as a means to remove the low frequencies and highlight the details. It actually removes a Gaussian-blurring of the image from the image. For this purpose, it uses the *imgaussfilt* function with, by default, ``sigma = 10``.

    |hr|

    ``obj.highPassFilter(n)`` applies a high-pass filter on the spatial frequencies of the image. ``n`` is the ``sigma`` parameter of the *imgaussfilt* function. The larger ``n``, the flatter the OPD image look.
    
    |hr|

    *ImageQLSI* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output is used, ``obj2``, then the object is not modified, and duplicated.
    





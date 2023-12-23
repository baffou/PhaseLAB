.. dropdown:: **binning** |subTitle| Performs 2x2 or 3x3 pixel binning of the images of the ImageQLSI object. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj.binning()
        obj.binning(n)
        obj2 = obj.binning(___);


    .. raw:: html
      
        <p class="title">Description</p>

    ``obj`` can by a vector of *ImageQLSI* objects. In that case, the treatment will be perform on all the objects of the list.

    ``obj.binning()`` performs, by default, a 3x3 binning of the images of ``obj``.

    .. include:: ../hr.txt

    ``obj.binning(n)`` performs, nxn binning of the images of ``obj``. Only works with ``n = 2`` or ``n = 3``.
    
    .. include:: ../hr.txt

    If an output argument is specified, ``obj`` is not modified, but duplicated.
    





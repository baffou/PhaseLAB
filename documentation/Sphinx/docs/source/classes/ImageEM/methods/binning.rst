.. dropdown:: **binning** |subTitle| Performs 2x2 or 3x3 pixel binning of the images of the ImageEM object. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj.binning()
        obj.binning(n)
        obj2 = obj.binning(___);


    .. raw:: html
      
        <p class="title">Description</p>

    ``obj`` can by a vector of *ImageEM* objects. In that case, the treatment will be perform on all the objects of the list.

    ``obj.binning()`` performs, by default, a 3x3 binning of the images of ``obj``.

    |hr|

    ``obj.binning(n)`` performs, :math:`n\times n` binning of the images of ``obj``. Only works with ``n = 2, 3, 4, 6``.
    
    |hr|

    If an output argument is specified, ``obj`` is not modified, but duplicated.
    





.. dropdown:: **removeOffset**
    
    Substract an number, or an image to the interferogram image.

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj.removeOffset()
        obj.removeOffset(val)
        obj2 = obj.removeOffset(___);


    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.removeOffset()`` removes from `Itf`, by default, the value of the pixel of weakest intensity in the `Itf` image.

    .. include:: ../hr.txt

    ``obj.removeOffset(val)`` remove ``val``, which can be a number, or a matrix of the same size as ``Itf``.
    
    .. include:: ../hr.txt

    If an output argument ``obj2`` is specified, ``obj`` is not modified, but duplicated.
    
    .. warning::

        It only removes the offset to the ``Itf`` attribute, not to the reference ``Ref.Itf``.



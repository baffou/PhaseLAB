.. dropdown:: clearFcrops |subTitle| Clear the FcropParameters settings of the reference *Interfero*. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj.clearFcrops()

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.clearFcrops()`` resets the value of ``obj.Ref.Fcrop``.

    ``obj.clearFcrops(val)`` remove ``val``, which can be a number, or a matrix of the same size as ``Itf``.
    
    |hr|

    ``obj`` can be a list (vector) of *Interfero* objects.
    
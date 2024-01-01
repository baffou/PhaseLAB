.. dropdown:: square |subTitle| Transforms rectangle interferograms to square interferograms by cropping. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.square()
        objList.square(___)
        obj2 = obj.square(___)

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.square()`` crops the images of the *Interfero* object so that they are square. To define the size of the square, the smallest image dimension is considered (``min([obj.Nx, obj.Ny])``).

    |hr|

    *Interfero* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output is specified, ``obj2``, then the object is not modified, but duplicated.
    





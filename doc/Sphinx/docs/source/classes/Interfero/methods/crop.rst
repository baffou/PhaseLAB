.. dropdown:: crop |subTitle| Crop the image and reference interferograms. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.crop()
        obj.crop(Name, Value)
        objList.crop(___)
        obj2 = obj.crop(___);

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.crop()`` crops the ``obj.Itf`` and ``obj.Ref.Itf`` images, identically. A figure window opens, inviting the user to click on the image to define a square area centered in the middle of the image.

    |hr|

    *Interfero* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output is used, ``obj2``, then the object is not modified, and is duplicated.
    

    .. raw:: html
      
        <p class="title">Name-value arguments</p>
  
    .. note::
    
        Specify optional pairs of arguments as ``Name1 = Value1, ..., NameN = ValueN``, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.

        Example:

        .. code-block:: matlab
            
            obj.crop(___,'Center','Manual','Size',300)
  
    The Name-Value arguments in the *crop* method are used to define how the reference area is chosen. This reference area is the one that will feature a no-tilt when the tilt correction will be applied. When some arguments are set to :matlab:`'Manual'`, a figure appears so that the user can select this area, in 1 or 2 clicks.

    - :matlab:`'Center'`

        With :matlab:`crop(___,'Center','Manual')`, the user has to first click on the center of the reference area. If the argument is set to :matlab:`'Auto'`, then this step is skipped, and the center is automatically set to the center of the image. Also, the user can indicate the coordinates of the center: :matlab:`crop(___,'Center',[x_c, y_c])`.

    - :matlab:`'Size'`

        With :matlab:`crop(___,'Size','Manual')`, once the center is defined (either manually or automatically), the user has to click on the figure to define the shape of the area, around the center point. The user can also indicate the dimensions of the reference area: :matlab:`crop(___,'Size',Npx)` for a square area, or  :matlab:`crop(___,'Size',[Nx, Ny])` for a rectangular area.

    - :matlab:`'twoPoints'`

        Instead of using the :matlab:`'Center'` and :matlab:`'Size'` keywords, one can also click on two opposite corners of the reference area, using :matlab:`crop(___,'twoPoints',true)`.

    - :matlab:`'params'`

        One can also direclty write the coordinates of the crops, using :matlab:`crop(___,'params', [x1, x2, y1, y2])`. In this case, no figure opens.


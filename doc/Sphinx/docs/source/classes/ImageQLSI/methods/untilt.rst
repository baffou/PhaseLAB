.. dropdown:: **untilt** |subTitle| Removes a tilt on the OPD image. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.untilt()
        obj.untilt(Name, Value)
        objList.untilt(___)
        obj2 = obj.untilt(___)

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.untilt()`` removes any possible tilt of the ``OPD`` image by calculating the (1,1) aand (1, -1) Zernike moments of the image, and subtracting the corresponding tilts to the image.

    By default, the moment are calculated on the whole image. The power of this methods lies on the fact that the moments can also be calculated on any sub-area of the image, if some Name-Value arguments are specified (see next section).

    |hr|

    *ImageQLSI* objects vectors can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output is used, ``obj2``, then the object is not modified, and is duplicated.
    

    .. raw:: html
      
        <p class="title">Name-value arguments</p>
  
    .. note::
    
        Specify optional pairs of arguments as ``Name1 = Value1, ..., NameN = ValueN``, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.

        Example:

        .. code-block:: matlab
            
            obj.untilt(___,'Center','Manual','Size',300)
  
    The Name-Value arguments in the *untilt* method are used to define how the reference area is chosen. This referenc area is the one that will feature a no-tilt when the tilt correction will be applied. When some arguments are set to :matlab:`'Manual'`, a figure appears so that the user can select this area, in 1 or 2 clicks.

    - :matlab:`'Center'`

        With :matlab:`untilt(___,'Center','Manual')`, the user has to first click on the center of the reference area. If the argument is set to :matlab:`'Auto'`, then this step is skipped, and the center is automatically set to the center of the image. Also, the user can indicate the coordinates of the center: :matlab:`untilt(___,'Center',[x_c, y_c])`.

    - :matlab:`'Size'`

        With :matlab:`untilt(___,'Size','Manual')`, once the center is defined (either manually or automatically), the user has to click on the figure to define the shape of the area, around the center point. The user can also indicate the dimensions of the reference area: :matlab:`untilt(___,'Size',Npx)` for a square area, or  :matlab:`untilt(___,'Size',[Nx, Ny])` for a rectangular area.

    - :matlab:`'twoPoints'`

        Instead of using the :matlab:`'Center'` and :matlab:`'Size'` keywords, one can also click on two opposite corners of the reference area, using :matlab:`untilt(___,'twoPoints',true)`.

    - :matlab:`'params'`

        One can also direclty write the coordinates of the bottom-left and top-right corners, using :matlab:`crop(___,'params', [x1, x2, y1, y2])`. In this case, no figure opens.



     


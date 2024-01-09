.. dropdown:: **crop** |subTitle| Crop the images of the object. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj.crop()
        obj.crop(Name, Value)
        objList.crop(___)
        obj2 = obj.crop(___);
        [obj2, params] = obj.crop(___);

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.crop()`` crops the :math:`E` fields of the object and of the ``Ref`` object, identically. A figure window opens, inviting the user to click on the image to define a square area centered in the middle of the image.

    |hr|

    Objects *vectors* can also be used with this method. The transformation applies then to all the objects of the vector.

    |hr|

    If an output is used, ``obj2``, then the object is not modified, but duplicated.

    |hr|

    If a second output is specified, then the crop parameters are returned as a 4-vector ``params = [x1, x2, y1, y2]``;
    

    .. raw:: html
      
        <p class="title">Name-value arguments</p>
  
    .. note::
    
        Specify optional pairs of arguments as ``Name1 = Value1, ..., NameN = ValueN``, where ``Name`` is the argument name and ``Value`` is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.

        Example:

        .. code-block:: matlab
            
            obj.crop(___,'Center','Manual','Size',300)
  

    - :matlab:`'Center'`

        With :matlab:`crop(___,'Center','Manual')`, the user has to first click on the center of the reference area. If the argument is set to :matlab:`'Auto'`, then this step is skipped, and the center is automatically set to the center of the image. Also, the user can indicate the coordinates of the center using :matlab:`crop(___,'Center',[x_c, y_c])`.

    - :matlab:`'Size'`

        With :matlab:`crop(___,'Size','Manual')`, once the center is defined (either manually or automatically), the user has to click on the figure to define the shape of the area, around the center point. The user can also indicate the dimensions of the reference area using :matlab:`crop(___,'Size',Npx)` for a square area, or  :matlab:`crop(___,'Size',[Nx, Ny])` for a rectangular area.

    - :matlab:`'twoPoints'`

        Instead of using the :matlab:`'Center'` and :matlab:`'Size'` keywords, one can also click on two opposite corners of the reference area, using :matlab:`crop(___,'twoPoints',true)`.

    - :matlab:`'params'`

        One can also direclty write the coordinates of the crops, using :matlab:`crop(___,'params', [x1, x2, y1, y2])`. In this case, no figure opens.

    Here is an example of a code that crops a first object manually, and applies automatically the same crop to a second object:

    .. code-block:: matlab

        [IMc(1) params] = IM(1).crop('Center', 'Manual', 'Size', 'Manual');
        IMc(2) = IM(2).crop('params', params);
    
    Note that this code is equivalent to:

    .. code-block:: matlab

        IMc = IM.crop('Center', 'Manual', 'Size', 'Manual');





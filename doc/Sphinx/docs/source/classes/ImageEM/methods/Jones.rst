.. dropdown:: **Jones** |subTitle| apply Jones matrices to the E field of the images. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        % general forms
        obj = obj0.Jones([a, b; c, d]);
        obj = obj0.crop(Name, Value);

        % examples
        obj2 = obj.Jones([1 0; 0 0]);
        obj2 = obj.Jones('P', 0, 'HWP', 45, 'QWP', 45);
        

    .. raw:: html
      
        <p class="title">Description</p>

    The Jones function models the application of polarizers and wave plates to the image, with a Jones matrix formalism. For a given E field :math:`E = (E_x, E_y)`, the new E field :math:`E'` reads

    .. math::

        \begin{bmatrix}
        E_x' \\
        E_y'
        \end{bmatrix}
        =
        \begin{bmatrix}
        a & b \\
        c & d
        \end{bmatrix}
        \cdot
        \begin{bmatrix}
        E_x \\
        E_y
        \end{bmatrix}

    :math:`[a, b; c, d]` is the Jones matrix. For instance, for a polarize along the x axis, it reads

    .. math::
        
        P =
        \begin{bmatrix}
        1 & 0 \\
        0 & 0
        \end{bmatrix}

    For a half wave plate with fast axis along *x*, it reads

    .. math::
        
        H =
        \begin{bmatrix}
        1 & 0 \\
        0 & -1
        \end{bmatrix}

    And for a half wave plate rotated by an angle :math:`\theta`, it reads

    .. math::

        H(\theta) =
        \begin{bmatrix}
        cos 2\theta &  sin 2\theta \\
        sin 2\theta & -cos 2\theta
        \end{bmatrix}


    |hr|

    ``obj = obj0.Jones([a, b; c, d]);`` applies the Jones matrix to every pixel of the E field, and incident E field of the *ImageEM* object.

    |hr|

    ``obj = obj0.Jones(Name, Value);`` applies the optical component ``Name`` placed at an angle ``Value``. Several name-value pairs can be used: ``Name1 = Value1, ..., NameN = ValueN``. They will be applied to the images in the order they are specified.
    
    Here are the possible ``'Name'``:

    - :matlab:`'P'`

        Models the application of a linear polarizer. The associated value is the angle of the polarizer.

    - :matlab:`'HWP'`

        Models the application of a half wave plate. The associated value is the angle of the fast axis of the wave plate.

    - :matlab:`'QWP'`

        Models the application of a quarter wave plate. The associated value is the angle of the fast axis of the wave plate.

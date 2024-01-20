.. dropdown:: **MakeMoviedx** |subTitle| Make a movie from a series of image objects |/subTitle|


    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        % prototypes
        objList.makeMoviedx(videoName)
        objList.makeMoviedx(videoName, Name, Value)

        % examples
        objList.makeMoviedx('movie/bacteria.avi')
        objList.makeMoviedx('movie/bacteria.avi', )
        objList.makeMoviedx('movie/bacteria.avi','theta',0,'phi',0,'rate',2,'zrange',[-10 10])


    .. raw:: html
      
        <p class="title">Description</p>

    The ``MakeMoviedx`` method creates an .avi movie from an |ImageEM| or |ImageQLSI| object array. Two inputs are required, the image object array ``IM`` and the path/name of the movie file to be created ``videoname``. It calls the method :ref:`The_opendx_method`, from the same class.

    |hr|

    Many Name-value options can be specified to change the rendering.

    - :matlab:`'persp'`  (default: ``1``)

        With :matlab:`'persp'` set to ``1``, the video uses the ``opendx`` method to create a nnince 3D rendering of the image. Set this option to ``0`` to cancel this effect.
    
    - :matlab:`'phi'`  (default: ``45``) and ``'theta'``  (default: 45)

        Position of the camera in :matlab:`(\theta, \phi)`

    - :matlab:`'ampl'`  (default: ``45``) and :matlab:`'theta'`  (default: 3)

        sets the magnitude of the 3D relief

    - :matlab:`'zrange'`

        2-vector setting the limits of the *z* axis.

    - :matlab:`'colorMap'` (default: ``Parula``)

        Color map.

    - :matlab:`'title'`

        Title to display on the movie, if any.

    - :matlab:`'factor'` (default: ``1``)

        Correction factor to the |OPD|, for instance 5.55e-3 to convert the |OPD| into |DM|.

    - :matlab:`'label'` (default: :matlab:`'Optical path difference (nm)'`)

        Label to put on the color scale.

    - :matlab:`'imType'` (default: :matlab:`'OPD'`)

        Cell array of the properties of the object to be displayed: :matlab:`'OPD'`, :matlab:`'T'`, :matlab:`'DWx'`, :matlab:`'DWy'`, :matlab:`'Ph'`.

    - :matlab:`'axisDisplay'` (default: ``true``)

        Display the axes or not.

    

.. dropdown:: **opendx** |subTitle| Display a 3D rendering of the image |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        % prototypes
        opendx(obj)
        opendx(obj, Name, Value)

        % examples
        opendx(IM)
        objList.makeMoviedx(IM, 'theta', 10, 'phi', 30, 'zrange', [-10 120]*1e-9, 'ampl', 4)

    .. raw:: html
      
        <p class="title">Description</p>

    The ``opendx`` method diplay images from |ImageEM| or |ImageQLSI| objects.

    |hr|

    Many Name-value options can be specified to change the rendering.

    - ``'rate'`` (default: ``25``)

        Frame rate of the avi file in :abbr:`fps (frame per second)`.

    - ``'persp'``  (default: 1)

        With ``'persp'`` set to ``1``, the video uses the ``opendx`` method to create a nnince 3D rendering of the image. Set this option to ``0`` to cancel this effect.
    
    - ``'phi'``  (default: 45) and ``'theta'``  (default: 45)

        Position of the camera in :math:`(\theta, \phi)`

    - ``'ampl'``  (default: 45) and ``'theta'``  (default: 3)

        sets the magnitude of the 3D relief

    - ``'zrange'``

        2-vector setting the limits of the *z* axis.

    - ``'colorMap'`` (default: Parula)

        Color map.

    - ``'title'``

        Title to display on the movie, if any.

    - ``'factor'`` (default: 1)

        Correction factor to the |OPD|, for instance 5.55e-3 to convert the |OPD| into |DM|.

    - ``'label'`` (default: 'Optical path difference (nm)')

        Label to put on the color scale.

    - ``'imType'`` (default: 'OPD')

        Cell array of the properties of the object to be displayed: ``'OPD'``, ``'T'``, ``'DWx'``, ``'DWy'``, ``'Ph'``.

    - ``'axisDisplay'`` (default: true)

        Display the axes or not.

    - ``'frameTime'``

        Equals the exposure time. Should be specified for the time to appear on the movie. If empty, no time indication is displayed on the movie.

    - ``'timeUnit'`` {mustBeMember(opt.timeUnit,{'s','min','h'})}= 's'

        If ``'frameTime'`` is indicated, then one can also indicate the preferred time unit to be displayed with the option ``'timeUnit'``.

    - ``'timeFontSize'`` 

        If the font size of the time time indication on the movie is not appropriate, it can be set with the ``'timeFontSize'`` option.

    

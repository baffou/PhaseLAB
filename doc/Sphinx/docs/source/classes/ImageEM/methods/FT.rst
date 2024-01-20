.. dropdown:: **FT** |subTitle| Return the Fourier transform of the E field. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        I = obj.FT();
        
    .. raw:: html
      
        <p class="title">Description</p>

    |hr|

    ``I = obj.FT()`` returns the square of the norm ``I`` of the Fourier transform of the :math:`E` field:

    .. math::

        I = \vert \mathcal{F}[Ex]\vert^2 + \vert\mathcal{F}[Ey]\vert^2

 
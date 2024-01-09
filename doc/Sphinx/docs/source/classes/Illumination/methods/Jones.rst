.. dropdown:: **Jones** |subTitle| Applies a Jones matrix to an *Illumination* object. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        % prototype
        IL.Jones(Name, Value)

        % example
        IL.Jones('P', 45, 'QWP',90, 'HWP',30, ...)

    .. raw:: html
      
        <p class="title">Description</p>

    | Applies optical plates to the illumination beam, according to the Jones matrix formulation. The names can be:
    | :matlab:`'QWP'``: Quarter waveplate
    | :matlab:`'HWP'`: Half waveplate
    | :matlab:`'P'`: Linear polarizer
    | and the values are the rotation angles of the wave plates.

    The order of the Name-Value arguments matters. They will be applied to the Illumination from left to right.

    For instance, here is a circularly polarized light that passes through a lambda/4 wave plate and that becomes a linearly polarized light along :math:`x`:

    .. code-block:: matlab

        >> IL = Illumination(532e-9);
        >> IL.polar = [1 1i 0];
        >> IL.Jones('QWP',45)
        >> disp(IL.polar)

        0.7071 + 0.7071i   0.0000 + 0.0000i   0.0000 + 0.0000i

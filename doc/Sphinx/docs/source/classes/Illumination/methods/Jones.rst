.. dropdown:: **Jones** |subTitle| Applies a Jones matrix to an *Illumination* object. |/subTitle|

    .. code-block:: matlab

        IL.Jones('P', 45, 'QWP',90, 'HWP',30, ...)

    | Applies optical plates to the illumination beam, according to the Jones matrix formulation. The inputs are the rotation angles of the wave plates.
    | :matlab:`'QWP'``: Quarter waveplate
    | :matlab:`'HWP'`: Half waveplate
    | :matlab:`'P'`: Linear polarizer


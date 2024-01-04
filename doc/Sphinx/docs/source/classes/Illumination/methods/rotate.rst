.. dropdown:: **rotate** |subTitle| Rotate the incident illumination. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>

    .. code-block:: matlab

        % prototype
        IL.rotate(Name, Value)


        % examples
        IL.rotate('z',30)
        IL.rotate('x',45,'y',30,'z',10)

    .. raw:: html
      
        <p class="title">Description</p>
    
    This method rotates the ``polar`` and ``direct`` vector around the specified axes, :math:`x`, :math:`y`, and/or :math:`z`. The values are the angles in degrees. The order of the inputs matters.

    For instance, here is a :math:`x`-polarized light that is rotate by 45° around :math:`z`:

    .. code-block:: matlab

        >> IL = Illumination(532e-9);
        >> IL.polar = [1 0 0];
        >> IL.rotate('z',45)
        >> disp(IL.polar)

        0.7071    0.7071         0

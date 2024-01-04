
.. dropdown:: **crop** |subTitle| set the sensor dimension. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        % prototypes
        obj.crop(N);
        obj.crop(Nx, Ny);

        % examples
        obj.crop(200);
        obj.crop(400, 300);


    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.crop(N)``  sets the sensor dimension to a square of ``N*N`` pixels.

    ``obj.crop(Nn, Ny)``  sets the sensor dimension to a rectangular area with ``Nx`` columns and ``Ny`` rows.

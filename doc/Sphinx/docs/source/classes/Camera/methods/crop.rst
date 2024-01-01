
.. dropdown:: crop |subTitle| reduce the sensor dimension. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        obj.crop(N);
        obj.crop(Nx, Ny);

    .. raw:: html
      
        <p class="title">Description</p>

    ``obj.crop(N)``  reduces the sensor dimension to a square of ``N*N`` pixels.

    ``obj.crop(Nn, Ny)``  reduces the sensor dimension to a rectangular area with ``Nx`` columns and ``Ny`` rows.

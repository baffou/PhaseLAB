Image postprocessing
++++++++++++++++++++

.. dropdown:: **Image postprocessing** |subTitle|  Examples of QLSI images postprocessing |/subTitle|
    :open:

    .. code:: matlab

        %% code that performs successive image processings

        % crop of the image
        IM0.crop('Size', 300, 'Center', 'Manual')

        % flattening of the background
        IM0.flatten(3)

        % numerical refocusing by 0.5 µm
        IM0.propagation(0.5e-6)

        % flip the image upside down
        IM0.flipud()

        % high-pass filter
        IM0.highPassFilter(20)

        %image diplay
        dynamicFigure('ph',IM0,'bw',{IM0.T})

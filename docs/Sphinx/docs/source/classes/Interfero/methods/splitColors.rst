.. dropdown:: splitColors |subTitle| Extract the two color interferograms from one interferogram acquired with a 2-color camera. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        Itf_multi = splitColors(Itf);

    .. raw:: html
      
        <p class="title">Description</p>

    This method extracts the different color channels of an *Interfero* object, into an array of *Interfero* objects ``Itf_multi``. If ``Itf`` is an array of :math:`N` |Interfero| objects, then ``Itf_multi`` is an array of :math:`N\times2` |Interfero| objects, where each column is a color.

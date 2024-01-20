.. dropdown:: splitPolars |subTitle| Extract the 4 interferograms corresponding to the 4 polarizations of a polarized camera. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        Itf_multi = splitPolars(Itf);

    .. raw:: html
      
        <p class="title">Description</p>

    This method extracts the different polarisation channels of an *Interfero* object, into an array of *Interfero* objects ``Itf_multi``. If ``Itf`` is an array of :math:`N` |Interfero| objects, then ``Itf_multi`` is an array of :math:`N\times4` |Interfero| objects, where each column is associated to one of the 4 polarisation 0, 45, 90, and 135°.

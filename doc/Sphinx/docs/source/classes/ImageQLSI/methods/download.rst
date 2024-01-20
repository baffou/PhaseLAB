.. dropdown:: **download** |subTitle| Import on the RAM of the computer an object that is in 'remote' mode. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    

    .. code-block:: matlab

        obj2 = obj.download();


    .. raw:: html
      
        <p class="title">Description</p>

    Import on the RAM of the computer an object that is in 'remote' mode, i.e., where the ``T`` and ``OPD`` properties are stored in the hard disk drive. This happens when creating an *ImageQLSI* object using :matlab:`obj = QLSIprocess(___, 'remote', true);`.




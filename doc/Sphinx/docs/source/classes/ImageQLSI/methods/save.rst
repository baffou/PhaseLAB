.. dropdown:: **save** |subTitle| Export the T and OPD images as jpg and txt files. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab
        
        % general patterns
        obj.save(folder)
        obj.save(folder, Names)

        % Examples,
        obj.save('savedData', 'T')
        obj.save('savedData', 'OPD')
        obj.save('savedData', 'T', 'OPD')
        obj.save('savedData', 'T', 'OPD', 'DWx', 'DWy', 'Ph')
        
    .. raw:: html
      
        <p class="title">Description</p>

    Export the intensity, wavefront, phase and/or gradient images of the *ImageQLSI* object into a folder, as .txt and .jpg files. To indicate which images are saved, a list a keywords has to be indicated as separated arguments, corresponding to the names of the properies.



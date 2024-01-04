.. dropdown:: **imageHSV** |subTitle| display a mix of the T an OPD images according to a HSV colorscale pattern. |/subTitle|

    .. raw:: html
      
        <p class="title">Synthax</p>
    
    .. code-block:: matlab

        imageHSV(obj);

    .. raw:: html
      
        <p class="title">Description</p>

    The ``imageHSV`` method displays a mix of the intensity an |OPD| images according to a abbr:`HSV (hue, saturation, value)` pattern. Just like the RVB coding, HSV coding codes any color with 3 numbers:
    
    - *H* means *Hue* and represents the color on a chromatic circle

    - *S* means *Saturation*  and tells if the colors are vivid or pale.

    - *V* means *Value* and tells if the color is bright or dark.

    Here is a picture that explains the abbr:`HSV (hue, saturation, value)` color coding:

    .. figure:: /images/HSV.jpeg
        :width: 500
        :align: center
    
    .. raw:: html

        <p class="title">Example</p>

    The ``imageHSV`` method  assigns the |OPD| image to the Hue (the colorscale), and the intensity image to the Saturation (this way, areas with low intensity appear dark), and keeping the Value to 1.

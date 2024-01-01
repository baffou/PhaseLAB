function TagID = getPhaseTags()
%Returns the key/value pair linking a Tiff tag number and the physical value.
%
%See also WRITETIFFTAG, READTIFFTAG, IMFINFO
%
%Baptiste Marthy - 2021

    TagID = struct( ...                         %Writer (BM = BenchManager, PhL = PhaseLIVE)
        'CameraName',               36000,     ... %BM 
            'DexelSize',                36001, ... %BM
            'ExposureTime',             36002, ... %PhL
            'SensorTemperature',        36004, ... %PhL
        'GratingName',              37000,     ... %BM
            'GrexelSize',               37001, ... %BM
            'GratingSensorDistance',    37002, ... %BM
            'GratingWellDepth',     37003, ...     %720nm P02 et P04 = 588nm
            'GratingAngle'             ,37004, ... %BM
        'ReimagerName',             38000,     ... %BM _ opt
            'Zoom',                     38001, ... %BM _ opt
        'ObjectiveName',            39000,     ... %BM
            'Brand',                    39001, ... %BM
            'Magnification',            39002, ... %BM
            'NumericalAperture',        39003, ... %BM
        'TubeLensFocale',           40001,     ... %BM
        'Wavelength',               40002,     ... %BM
        ...
        'AcquistionNumber',         41001,     ... %PhL _ optionnal
        'Timestamp',                41002,     ... %PhL _ optionnal
        'Reference',                  270,     ... %PhL -> Replace iamgeDescription tag', no auto update in readTiffTags.m
        'CameraResolution',         36003,     ... %PhL
        'FieldOfView',              41004      ... %PhL
        );
end
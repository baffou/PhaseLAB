function [output] = readTiffTag(pathToTheFile,outputFormat,enableWarning)
% READTIFFTAG Read the private tags written by PhaseLIVE inside a tiff file
%
% ARGUMENTS
%       pathToTheFile - absolute path to a tiff file
%       outputFormat - specify the format of the outpout - optionnal, Raw by default
%		    'Raw'      : output is a structure. Each field is a metadata
%           'PhaseLAB' :  output is a structure containing a Microscope & illumination object
%           'Console'  : output is empty. The metadata are printed in a formatted way in the console
%           'Cell'     : output is a cell array, used to manipulate tiff tags
%       enableWarning - bool - optionnal, true by default
%           true : Allow the trigger of warnings if metadatas are missing for PhaseLAB object construction
%           false : No warning won't be triggered
%
% SAMPLE:
%   metadatas = readTiffTag(myTIFF); %the tiff tags are contained in the metadatas struct. 
%   expTime = metedatas.ExposureTime; %If relevant, retrieve the exposure time during the image acquisition
%
%   myObjects = readTiffTag(myTIFF, 'PhaseLAB'); %Creates a Microscope and Illumination PhaseLAB objects
%   Interfero.MI = myObjects.Microscope; %Assign the microscope object in the Interfero object
%
%   readTiffTag(myTIFF,'Console'); %Display the tiff metadata in the matlab console
%
%   tags = readTiffTag(myTIFF, 'Cell');
%   writeTiffTag(anotherTIFF, aPath, tags{:}); %Copy the tags from myTIFF to anotherTIFF
%
% See also READTIFFTAG, WRITETIFFTAG, GETPHASETAGS.
%
% Baptiste Marthy - 2021

    arguments
        pathToTheFile char {mustBeFile}
        outputFormat {mustBeMember(outputFormat,{'Raw','PhaseLAB','Console','Cell'})} = 'Raw'
        enableWarning logical = true
    end

    fileInfo = imfinfo(pathToTheFile);
    
    if isfield(fileInfo,'UnknownTags')
        Tags = fileInfo.UnknownTags;

        PhLTags = getPhaseTags();
        PhLTagsStrings = fieldnames(PhLTags);
        PhLTagsID = cell2mat(struct2cell(PhLTags));

        TiffTagsID = [Tags.ID];
        TiffTagsValue = {Tags.Value};

        TiffTagsString = cell(1,length(Tags));

        for k=1:length(Tags)
            TiffTagsString{k} = PhLTagsStrings{TiffTagsID(k) == PhLTagsID};
        end

    else
        Tags = [];
        TiffTagsID = [];
        TiffTagsValue = [];
        TiffTagsString = [];
    end

    if isfield(fileInfo,'ImageDescription')
        TiffTagsID(length(Tags) + 1) = 270;
        TiffTagsString{length(Tags) + 1} = 'Reference';
        TiffTagsValue{length(Tags) + 1} = fileInfo.ImageDescription;
    end

    switch outputFormat
        case 'Raw'
            StringValuePaires = cell(1,2*length(TiffTagsID));
            for z = 1:length(TiffTagsID)
                StringValuePaires{2*z-1} = TiffTagsString{z};
                StringValuePaires{2*z  } = TiffTagsValue{z};
            end
            output = struct(StringValuePaires{:});

        case 'Cell'
            StringValuePaires = cell(1,2*length(TiffTagsID));
            for z = 1:length(TiffTagsID)
                StringValuePaires{2*z-1} = TiffTagsString{z};
                StringValuePaires{2*z  } = TiffTagsValue{z};
            end
            output = StringValuePaires;

        case 'PhaseLAB'
            %----OB Creation 
            % Magnification (39002) + NA (39003) Needed + Brand (39001) opt
            ObjArg = [];
            ObjArg = [ObjArg {TiffTagsValue{39002 == TiffTagsID}}]; %#ok<*CCAT1> 
            ObjArg = [ObjArg {TiffTagsValue{39003 == TiffTagsID}}];
            if length(ObjArg) == 2
                ObjArg = [ObjArg {TiffTagsValue{39001 == TiffTagsID}}]; %Try to add opt Brand
                output.Objective = Objective(ObjArg{:});
            else
                output.Objective = []; %No sufficient data to build obj
                if enableWarning
                    warning('Tiff tags are incompletes: unable to build Objective objects');
                end
            end


            %----CrossGrating creation 
            % Gamma = 2*GratingPixelSize (37001) + GratingName (37000) opt
            CrossGratingArg = [];
            CrossGratingArg = [CrossGratingArg {'Gamma'} {2 * TiffTagsValue{37001 == TiffTagsID}}]; %Gamma is needed when Grating pixel size is saved
            if ~isempty(CrossGratingArg)
%                 CrossGratingArg = [CrossGratingArg {TiffTagsValue{37000 == TiffTagsID}}];
                CrossGratingObject = CrossGrating(CrossGratingArg{:});
            else
                CrossGratingObject = [];
            end

            %----Camera creation 
            % DexelSize (36001) + Nx FieldOfView(1) (36003) + Ny FieldOfView(2) (36003)
            CameraArg = [];
            CameraArg = [CameraArg {TiffTagsValue{36001 == TiffTagsID}}];
            cameraSize = [];
            cameraSize = [cameraSize TiffTagsValue{36003 == TiffTagsID}];
            if ~isempty(cameraSize) && (length(cameraSize) == 2)
                CameraArg = [CameraArg {cameraSize(1)} {cameraSize(2)}];
            end
            if length(CameraArg) == 3
                CameraObject = Camera(CameraArg{:});
            else
                CameraObject = [];
            end

            %----Creation of CGCamera
            % Camera + CrossGrating + Zoom (38001) opt
            if ~isempty(CameraObject) && ~isempty(CrossGratingObject)
                CGCameraArg = [{CameraObject} {CrossGratingObject}];
                %Look for zoom
                CGCameraArg = [CGCameraArg {TiffTagsValue{38001 == TiffTagsID}}];

                CGCameraObject = CGcamera(CGCameraArg{:});
                CGCameraObject.CGangle = [TiffTagsValue{37004 == TiffTagsID}]; %Set the grating angle
                CGCameraObject.setDistance([TiffTagsValue{37002 == TiffTagsID}] * 1e-3); %Set the distance
                if isempty(CGCameraObject.CGpos)
                    CGCameraObject = [];
                end
            else
                CGCameraObject = [];
            end

            %MI Creation - OB + Tube lens focale (40001) opt + CG Cam + Software
            if ~isempty(CGCameraObject) && ~isempty(output.Objective)
                MicroscopeArg = [{output.Objective}];
                MicroscopeArg = [MicroscopeArg {TiffTagsValue{40001 == TiffTagsID}}];
                MicroscopeArg = [MicroscopeArg {CGCameraObject}];
                MicroscopeArg = [MicroscopeArg {'PhaseLIVE'}];

                output.Microscope = Microscope(MicroscopeArg{:});
            else
                output.Microscope = []; %No sufficient data to build obj
                if enableWarning && isempty(CGCameraObject)
                    warning('Tiff tags are incompletes: unable to build CGCamera object');
                end
            end

            %IL Creation - Wavelength (40002)
            IlluminationArg = [];
            IlluminationArg = [IlluminationArg {1e-9 * TiffTagsValue{40002 == TiffTagsID}}];

            if ~isempty(IlluminationArg)
                output.Illumination = Illumination(IlluminationArg{:});
            else
                output.Illumination = [];
                if enableWarning
                    warning('Tiff tags are incompletes: unable to build CGCamera object');
                end
            end
            
            %Reference (270)
            output.Reference = [TiffTagsValue{270 == TiffTagsID}];

        case 'Console'
            output = [];

%             formattedDisplay(3,'IMAGING SYSTEM')

            [~,Value] = getTiffValue(36000,TiffTagsID,TiffTagsValue);
            formattedDisplay(2,'CAMERA',Value);
            [isTagPresent,Value] = getTiffValue(36001,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Dexel size [m]',Value, isTagPresent);
            [isTagPresent,Value] = getTiffValue(36002,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Exposure time [s]',Value, isTagPresent);
            [isTagPresent,Value] = getTiffValue(41003,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Camera full resolution',Value, isTagPresent,'Resolution');
            [isTagPresent,Value] = getTiffValue(41004,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Field of view',Value, isTagPresent, 'Field of view');
            fprintf('\n') 
            [~,Value] = getTiffValue(37000,TiffTagsID,TiffTagsValue);
            formattedDisplay(2,'GRATING',Value);
            [isTagPresent,Value] = getTiffValue(37001,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Grexel size [m]',Value, isTagPresent);
            [isTagPresent,Value] = getTiffValue(37002,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Distance from sensor [mm]',Value, isTagPresent);
            [isTagPresent,Value] = getTiffValue(37003,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Targeted wavelength [nm]',Value, isTagPresent);
            [isTagPresent,Value] = getTiffValue(37004,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Angle [°]',Value, isTagPresent);
            fprintf('\n')
            [isTagPresent,Value] = getTiffValue(38000,TiffTagsID,TiffTagsValue);
            formattedDisplay(2,'REIMAGER',Value, isTagPresent);
            [isTagPresent,Value] = getTiffValue(38001,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Zoom',Value, isTagPresent);
            fprintf('\n')
            [~,Value] = getTiffValue(39000,TiffTagsID,TiffTagsValue);
            formattedDisplay(2,'OBJECTIVE',Value);
            [isTagPresent,Value] = getTiffValue(39001,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Brand',Value, isTagPresent);
            [isTagPresent,Value] = getTiffValue(39002,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Magnification',Value, isTagPresent);
            [isTagPresent,Value] = getTiffValue(39003,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Numerical aperture',Value, isTagPresent);
            fprintf('\n')
            formattedDisplay(2,'OTHER');
            [isTagPresent,Value] = getTiffValue(40001,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Focale of the tube lens [mm]',Value, isTagPresent);
            [isTagPresent,Value] = getTiffValue(40002,TiffTagsID,TiffTagsValue);
            formattedDisplay(1,'Illumination wavelength [nm]',Value, isTagPresent);
            fprintf('\n')
            [isTagPresentAcq,ValueAcq] = getTiffValue(41001,TiffTagsID,TiffTagsValue);
            [isTagPresentTS,ValueTS] = getTiffValue(42001,TiffTagsID,TiffTagsValue);
            if isTagPresentAcq
                formattedDisplay(2,'PART OF ACQUISITION');
                formattedDisplay(1,'Acquistion number', ValueAcq);
                formattedDisplay(1,'Timestamp value [s]', ValueTS, isTagPresentTS);
                fprintf('\n')
            elseif isTagPresentTS
                formattedDisplay(2,'METRICS');
                formattedDisplay(1,'Timestamp value [s]', ValueTS, isTagPresentTS);
                fprintf('\n')
            end

    end

end

%small routine used in the case Console
function [bool,value] = getTiffValue(ID,TiffTagsID,TiffTagsValue)
    bool = ismember(ID,TiffTagsID);
    if bool
        value = TiffTagsValue{ID == TiffTagsID};
    else
        value = [];
    end
end

function formattedDisplay(level,msg,value,bool,specificFormat)
    arguments
        level
        msg
        value = []
        bool = 1
        specificFormat {mustBeMember(specificFormat,{'None','Resolution','Field of view'})} = 'None'
    end
    if bool
        switch level
            case 1
                ind = '    ';
            case 2
                ind = '  ';
            case 3
                ind = '__';
        end

        if ~isempty(value) %Supported value : Char, numeric, Resolution, ROI
            bfValue = ' : ';
            if isnumeric(value)
                if length(value) == 1
                    value = num2str(value);
                else 
                    %Tread in the fprintf
                end
            end
        else 
            bfValue = '';
        end
        
        switch specificFormat
            case 'None'
                fprintf([ind msg bfValue value '\n']);
            case 'Resolution'
                if length(value) == 2
                    fprintf([ind msg bfValue num2str(value(1)) ' x ' num2str(value(2)) ' px' '\n'])
                else
                    warning('Tiff tag Camera resolution (41003) must be a 2-tuple')
                end
            case 'Field of view'
                if length(value) == 4
                    fprintf([ind msg bfValue '[' num2str(value(1)) ', ' num2str(value(2)) ', ' num2str(value(3)) ', ' num2str(value(4)) ']' ' px\n'])
                else
                    warning('Tiff tag Field of view (41004) must be a 4-tuple')
                end
        end
    end
end
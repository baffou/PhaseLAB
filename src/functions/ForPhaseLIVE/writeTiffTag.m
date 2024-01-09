function writeTiffTag(image,savingPath,metadata,value)
% WRITETIFFTAG Write .tiff with private metadata, given in a key/value fashion.
%
% ARGUMENTS
%       image - Absolute path to a tiff file OR a matrice
%       savingPath - Absolute path for the future tiff file
%       metadata - ID of the tag OR Text description (predifined phase tags)
%       value - value of the tag
%
% SAMPLE:
%   writeTiffTag(matrice,saving_path,metadata1,value1,metadata2, value2...); %write a new tiff file containing the image 'matrice' and the metadatas
%                                                                            %at the saving_path
%   writeTiffTag(pathToATiff,metadata1,value1,...); %open a existing tiff file and add metadata to it
%
%
% See also READTIFFTAG, WRITETIFFTAG, GETPHASETAGS.
%
% Baptiste Marthy - 2021
    arguments
        image {verifyTheImage}
        savingPath char = image;
    end

    arguments (Repeating)
        metadata {isAValideMetadata}
        value
    end
    
    import py.PIL.*

    if isa(image,'numeric')
        import py.numpy.array %#ok<SIMPT> 
        myIm = py.PIL.Image.fromarray(py.numpy.array(image));
    else
        myIm = py.PIL.Image.open(image);
        previousTags = readTiffTag(image,"Cell");
        previousMetadata = previousTags(1:2:length(previousTags)-1);
        previousValue = previousTags(2:2:length(previousTags));
        metadata = [previousMetadata metadata];
        value = [previousValue value];
    end

    tagID = getPhaseTags();


    if ~isempty(metadata)
        metadatas_struct = py.PIL.TiffImagePlugin.ImageFileDirectory_v2();
    
        for k=1:length(metadata)
            if isa(metadata{k},'char')
                id = getfield(tagID,metadata{k}); %#ok<GFLD> 
            else
                id = metadata{k};
            end
            
            if verifyMetadataValue(id,value{k})
                metadatas_struct{uint16(id)} = value{k};
            end
        end
    end

    save(myIm,savingPath,pyargs('tiffinfo',metadatas_struct));
end

%-----------VERIFICATION FUNC

function bool = verifyTheImage(im)
    bool = false;
    if isa(im,"numeric") && min(size(im) > [1 1])
        bool = true;
        return
    else
        mustBeFile(im);
    end

end

function bool = isAValideMetadata(metadata)
    if max(strcmp(metadata,fieldnames(getPhaseTags())))
        bool = true;
    elseif max(metadata == cell2mat(struct2cell(getPhaseTags())))
        bool = true;
    else
        if isa(metadata,'numeric')
            metadata = num2str(metadata);
        end
        error([metadata ' is not a valid tag']);
    end
end

function bool = verifyMetadataValue(metadataID, value)
bool = true;
    switch metadataID
        case {36000, 37000, 38000, 39000, 39001} %Setup element name, objective brand
            if ~isa(value,"char")
                bool = false;
                throwFormattedError(metadataID, value, 'char array');
            end
        case {36001,37001} %GrexelSize, DexelSize
            if ~isnumeric(value)
                bool = false;
                throwFormattedError(metadataID, value, 'numerical value');
            end
            if value > 1 || value < 1e-6
                listOfTags = getPhaseTags();
                listOfID = cell2mat(struct2cell(listOfTags));
                listOfMember = fieldnames(listOfTags);
                warning(['The value of tag ID ' num2str(metadataID) ' (' listOfMember{metadataID == listOfID} ') is expected in meter']);
            end
        case {36002} %ExposureTime
            if ~isnumeric(value)
                bool = false;
                throwFormattedError(metadataID, value, 'numerical value');
            end
            if value > 25 || value < 1e-4
                listOfTags = getPhaseTags();
                listOfID = cell2mat(struct2cell(listOfTags));
                listOfMember = fieldnames(listOfTags);
                warning(['The value of tag ID ' num2str(metadataID) ' (' listOfMember{metadataID == listOfID} ') is expected in second']);
            end
        case {37002} %distanceCapteurReseau
            if ~isnumeric(value)
                bool = false;
                throwFormattedError(metadataID, value, 'numerical value');
            end
            if value > 5 || value < 1e-6
                listOfTags = getPhaseTags();
                listOfID = cell2mat(struct2cell(listOfTags));
                listOfMember = fieldnames(listOfTags);
                warning(['The value of tag ID ' num2str(metadataID) ' (' listOfMember{metadataID == listOfID} ') is expected in meter']);
            end
        case 37004 %GratingAngle
            if ~isnumeric(value)
                bool = false;
                throwFormattedError(metadataID, value, 'numerical value');
            end
            if value > 360 || value < 0
                listOfTags = getPhaseTags();
                listOfID = cell2mat(struct2cell(listOfTags));
                listOfMember = fieldnames(listOfTags);
                warning(['The value of tag ID ' num2str(metadataID) ' (' listOfMember{metadataID == listOfID} ') is expected in degrees']);
            end
        case {38001, 41001, 41002, 39002, 39003, 40001} %Zoom, AcqNumber, Timestamps, Magnification, NA, TubeLensFocale
            if ~isnumeric(value)
                bool = false;
                throwFormattedError(metadataID, value, 'numerical value');
            end
            if value < 0
                bool = false;
                throwFormattedError(metadataID, value, 'positive numerical value');
            end
        case {37003,40002} %GratingWellDepth, Wavelength
            if ~isnumeric(value)
                bool = false;
                throwFormattedError(metadataID, value, 'numerical value');
            end
            if value > 1e-5
                listOfTags = getPhaseTags();
                listOfID = cell2mat(struct2cell(listOfTags));
                listOfMember = fieldnames(listOfTags);
                warning(['The value of tag ID ' num2str(metadataID) ' (' listOfMember{metadataID == listOfID} ') is expected in meter']);
            end
    end
end

function throwFormattedError(metadataID, value, expectedClass)
listOfTags = getPhaseTags();
listOfID = cell2mat(struct2cell(listOfTags));
listOfMember = fieldnames(listOfTags);

error(['Tag ID ' num2str(metadataID) ' (' listOfMember{metadataID == listOfID} ') requieres a ' expectedClass ' but a ' class(value) ' has been given'])
end
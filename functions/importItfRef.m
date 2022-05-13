function [INT,REF,IL] = importItfRef(folder,MI,varargin)
remote = 0;
manual = 0;
nickname = [];

IL = []; %If metadatas == false, IL will stay blank !

if isa(MI,'Microscope') %Microscope already built
    acquisitionSoftware = MI.software;
elseif isa(MI,'char')
    if max(strcmpi(MI,{'metadatas','metadata','tags','tag'})) %loading MI from tiff tags
        acquisitionSoftware = 'PhaseLIVE'; %Tags must be written by phaseLIVE
    else
        error('MI must be either a Microscope object or ''metadatas''');
    end
else
    error('MI must be either a Microscope object or ''metadatas''');
end

if ~(strcmp(folder(end),'/') || strcmp(folder(end),'\'))
    folder = [folder '/'];
end

Na = nargin-2;

if Na>0
    if isOdd(Na)
        error('not the proper number of arguments in importItfRef')
    end
    for ii = 1:Na/2
        if strcmp(varargin{2*ii-1},'nickname')
            nickname = varargin{2*ii};
        elseif strcmp(varargin{2*ii-1},'selection')
            if isnumeric(varargin{2*ii})
                selection = varargin{2*ii};
            elseif strcmp(varargin{2*ii},'manual')
                manual = 1;
            else
                error('selection input must be a number or a number, a vector, or ''manual''.')
            end
        elseif strcmp(varargin{2*ii-1},'remote')
            if varargin{2*ii}==1 || strcmp(varargin{2*ii},'yes') || strcmp(varargin{2*ii},'on')
                remote = 1;
            elseif varargin{2*ii}==0 || strcmp(varargin{2*ii},'no') || strcmp(varargin{2*ii},'off')
                remote = 0;
            end
        end
    end
end

% import the interferogram main images (not the refs)
if manual==1
    [ItfFileNames0,folder] = uigetfile({'*.tif';'*.txt';'*.tiff'},'MultiSelect','on','File Selector');
    if folder==0
        error('No file has been selected')
    end
    if ischar(ItfFileNames0) % if only one file has been selected
        ItfFileNames{1} = ItfFileNames0;
    else
        ItfFileNames = ItfFileNames0;
    end
    Nif = numel(ItfFileNames);
    
    if Nif==0
        error(['No file imported from the folder ' folder])
    end
    
else
    if strcmpi(acquisitionSoftware,'phast') || strcmpi(acquisitionSoftware,'Sid4Bio')
        ItfFileList = dir([folder 'SID ' nickname '*.tif']);
        ItfFileNames0 = {ItfFileList.name};
        Nif = numel(ItfFileNames0);
        
        if Nif == 0
            error(['No file imported from the folder ' folder])
        end
        
        if exist('selection','var')
            if isnumeric(selection)
                if selection <1
                    if length(selection)~=1
                        error('when smaller than unity, selection must be a number, not a vector')
                    end
                    selection = 1:round(1/selection):Nif;
                end
                Nif = numel(selection);
                ItfFileNames = cell(Nif,1);
                for ii = 1:Nif
                    ItfFileNames{ii} = ItfFileNames0{selection(ii)};
                end
            end
        else
            ItfFileNames = ItfFileNames0;
        end
    elseif strcmpi(acquisitionSoftware,'phaselive')
        ItfFileList = dir([folder nickname '*.tif']);
        ItfFileNamesTemp = {ItfFileList.name};
        ItfFileNamesTempBool = ~contains(ItfFileNamesTemp,'REF_');
        ItfFileNames0 = ItfFileNamesTemp(ItfFileNamesTempBool);
        Nif = numel(ItfFileNames0);
        
        if Nif == 0
            error(['No file imported from the folder ' folder])
        end
        
        if exist('selection','var')
            if isnumeric(selection)
                if selection <1
                    if length(selection)~=1
                        error('when smaller than unity, selection must be a number, not a vector')
                    end
                    selection = 1:round(1/selection):Nif;
                end
                Nif = numel(selection);
                ItfFileNames = cell(Nif,1);
                for ii = 1:Nif
                    ItfFileNames{ii} = ItfFileNames0{selection(ii)};
                end
            end
        else
            ItfFileNames = ItfFileNames0;
        end
    end
    
end
%% determine all the reference images' names in the folder


RefFileList = dir([folder 'REF_*.tif']);
RefFileNames = {RefFileList.name};

Nrf = numel(RefFileNames);

if Nrf==0
    RefFileList = dir([folder 'Refz*.tif']);
    RefFileNames = {RefFileList.name};
    Nrf = numel(RefFileNames);
end

if Nrf==0
    error('No reference interfero has been found')
end


REF = repmat(Interfero(),Nrf,1);
INT = repmat(Interfero(),Nif,1);

if strcmpi(acquisitionSoftware,'phast') || strcmpi(acquisitionSoftware,'Sid4Bio')
    for rr = 1:Nrf
        REF(rr) = Interfero([folder RefFileNames{rr}],MI,'remote',remote);
    end
    
    
    for ii = 1:Nif
        INT(ii) = Interfero([folder ItfFileNames{ii}],MI,'remote',remote);
        INT(ii).Microscope = MI;
        fid = fopen([folder ItfFileNames{ii}(1:end-4) ' REF.txt'],'r');
        if fid==-1
            error(['wrong filename: ' ItfFileNames{ii}(1:end-4) ' REF.txt'])
        end
        tline = fgetl(fid);
        while ~strcmp(tline(1:3),'REF')
            tline = fgetl(fid);
        end
        quotes = find(tline=='"');
        if length(quotes)~=2
            error('error upon reading the ref text file')
        end
        RefFile = tline(quotes(1)+1:quotes(2)-1);
        
        ok = 0;
        for rr = 1:Nrf
            if strcmp(RefFile,REF(rr).fileName)
                INT(ii).Reference(REF(rr));
                ok = 1;
            end
        end
        if ok==0
            error(['The reference ' RefFile ' file for image ' ItfFileNames{ii} ' was not found'])
        end
        
        
        
    end
    
elseif strcmpi(acquisitionSoftware,'phaselive')
    if isa(MI,'Microscope')
        for rr = 1:Nrf
            REF(rr) = Interfero([folder RefFileNames{rr}],MI,'remote',remote);
        end
        
        for ii = 1:Nif
            TIFF = Tiff([folder ItfFileNames{ii}]);
            currentRefFileName  =  [getTag(TIFF,270)];
            RefIndice  =  strcmp(RefFileNames,currentRefFileName);
            
            INT(ii)  =  Interfero([folder ItfFileNames{ii}],MI,'remote',remote);
            INT(ii).Microscope = MI;
            INT(ii).Reference(REF(RefIndice));
        end
    else
        IL = repmat(Illumination(),Nif,1);
        for rr = 1:Nrf
            S_Ref = readTiffTag([folder RefFileNames{rr}], "PhaseLAB");
            REF(rr) = Interfero([folder RefFileNames{rr}],S_Ref.Microscope,'remote',remote);
        end
        for ii = 1:Nif
            S_Itf = readTiffTag([folder ItfFileNames{ii}], "PhaseLAB");
            INT(ii) = Interfero([folder ItfFileNames{ii}],S_Itf.Microscope,'remote',remote);
            RefIndice = strcmp(RefFileNames,S_Itf.Reference);
            INT(ii).Reference(REF(RefIndice));
            IL(ii) = S_Itf.Illumination;
        end
        
    end
    
end

end

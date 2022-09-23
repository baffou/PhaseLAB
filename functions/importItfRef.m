function [INT,REF,IL] = importItfRef(folder,MI,opt)

arguments
    folder
    MI Microscope
    opt.nickname = []
    opt.selection = []
    opt.remote = 0
end

manual = 0;

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

if strcmpi(opt.selection,'manual')
    manual = 1;
end
if opt.remote==1 || strcmp(opt.remote,'yes') || strcmp(opt.remote,'on')
    opt.remote = 1;
elseif opt.remote==0 || strcmp(opt.remote,'no') || strcmp(opt.remote,'off')
    opt.remote = 0;
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
        ItfFileList = dir([folder 'SID ' opt.nickname '*.tif']);
        ItfFileNames0 = {ItfFileList.name};
        Nif = numel(ItfFileNames0);
        
        if Nif == 0
            error(['No file imported from the folder ' folder])
        end
        
        if ~isempty(opt.selection)
            if isnumeric(opt.selection)
                if opt.selection <1
                    if length(opt.selection)~=1
                        error('when smaller than unity, selection must be a number, not a vector')
                    end
                    opt.selection = 1:round(1/opt.selection):Nif;
                end
                Nif = numel(opt.selection);
                ItfFileNames = cell(Nif,1);
                for ii = 1:Nif
                    ItfFileNames{ii} = ItfFileNames0{opt.selection(ii)};
                end
            end
        else % if not opt.selection
            ItfFileNames = ItfFileNames0;
        end
    elseif strcmpi(acquisitionSoftware,'phaselive')
        ItfFileList = dir([folder opt.nickname '*.tif']);
        ItfFileNamesTemp = {ItfFileList.name};
        ItfFileNamesTempBool = ~contains(ItfFileNamesTemp,'REF_');
        ItfFileNames0 = ItfFileNamesTemp(ItfFileNamesTempBool);
        Nif = numel(ItfFileNames0);
        
        if Nif == 0
            error(['No file imported from the folder ' folder])
        end
        
        if ~isempty(opt.selection)
            if isnumeric(opt.selection)
                if opt.selection <1
                    if length(opt.selection)~=1
                        error('when smaller than unity, selection must be a number, not a vector')
                    end
                    opt.selection = 1:round(1/opt.selection):Nif;
                end
                Nif = numel(opt.selection);
                ItfFileNames = cell(Nif,1);
                for ii = 1:Nif
                    ItfFileNames{ii} = ItfFileNames0{opt.selection(ii)};
                end
            end
        else
            ItfFileNames = ItfFileNames0;
            opt.selection=1:Nif;
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
        REF(rr) = Interfero([folder RefFileNames{rr}],MI,'remote',opt.remote);
    end
    
    
    for ii = 1:Nif
        INT(ii) = Interfero([folder ItfFileNames{ii}],MI,'remote',opt.remote);
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
            REF(rr) = Interfero([folder RefFileNames{rr}],MI,'remote',opt.remote);
        end
        
        for ii = 1:Nif
            TIFF = Tiff([folder ItfFileNames{ii}]);
            fprintf([folder ItfFileNames{ii} '\n'])
            currentRefFileName  =  [getTag(TIFF,270)];
            RefIndice  =  strcmp(RefFileNames,currentRefFileName);
            INT(ii)  =  Interfero([folder ItfFileNames{ii}],MI,'remote',opt.remote,'imageNumber',opt.selection(ii));
            INT(ii).Microscope = MI;
            INT(ii).Reference(REF(RefIndice));
        end
    else
        IL = repmat(Illumination(),Nif,1);
        for rr = 1:Nrf
            S_Ref = readTiffTag([folder RefFileNames{rr}], "PhaseLAB");
            REF(rr) = Interfero([folder RefFileNames{rr}],S_Ref.Microscope,'remote',opt.remote);
        end
        for ii = 1:Nif
            S_Itf = readTiffTag([folder ItfFileNames{ii}], "PhaseLAB");
            INT(ii) = Interfero([folder ItfFileNames{ii}],S_Itf.Microscope,'remote',opt.remote);
            RefIndice = strcmp(RefFileNames,S_Itf.Reference);
            INT(ii).Reference(REF(RefIndice));
            IL(ii) = S_Itf.Illumination;
        end
        
    end
    
end

end

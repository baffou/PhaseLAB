function export(IMlist,varargin)
% export(IMlist, 'folder',path,'OPD','T','format','txt')

saveT = 1;
saveOPD = 1;
skipNext = 0;
for ia = 1:nargin-1
    if skipNext==0
        if strcmp(varargin{ia},'format')
            format = varargin{ia+1};
            skipNext = 1;
        elseif strcmp(varargin{ia},'folder')
            folder = varargin{ia+1};
            skipNext = 1;
            if ~isfolder(folder)
                mkdir(folder)
            end
        elseif strcmp(varargin{ia},'OPD')
            saveT = 0;
        elseif strcmp(varargin{ia},'T')
            saveOPD = 0;
        end
    else
        skipNext = 0;
    end
end


Ni = numel(IMlist);

for ii = 1:Ni
    IM0 = IMlist(ii);
    if saveOPD==1
        fileNameOPD = IM0.OPDfileName;
        pointPos = find(fileNameOPD=='.');
        imwrite(uint16(2^16*(IM0.OPD-min(IM0.OPD(:)))/max(IM0.OPD(:)-min(IM0.OPD(:)))),[folder '/OPD_' fileNameOPD(1:pointPos) format],'BitDepth',16)
    end
    if saveT==1
        fileNameT = IM0.TfileName;
        pointPos = find(fileNameT=='.');
        imwrite(uint16(2^16*IM0.T/max(IM0.T(:))),[folder '/T_' fileNameT(1:pointPos) format],'BitDepth',16)
    end
end



end


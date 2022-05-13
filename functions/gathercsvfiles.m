date = generateDatedFileName();
efactor = 1e-18;        
folder = '210606/';
FileNames = dir([folder 'data_*.csv']);
Nf = numel(FileNames);


Tab0 = table({'#','file name','time','factor','alpha','OV','OV min','OV max','XY'});
writetable(Tab0,[folder 'data_gather.csv'],'WriteVariableNames',0);

fid0 = fopen([folder 'data_gather.csv'],'a');


FirstString = cell(Nf,1);
for ii = 1:Nf
    fid = fopen([folder FileNames(ii).name]);
    AA = fgetl(fid);
    FirstString{ii} = AA(1:find(AA==',',1));
    fclose(fid);
end

[SortedNames,indices] = sort(FirstString); % order alphabetically the files, in case they were not taken the same day.


for ii = indices'
    fid = fopen([folder FileNames(ii).name]);
    AA = fgetl(fid);
    pointPos = find(AA=='.');
    fileNumber = AA(pointPos-5:pointPos-1);
    fprintf(fid0,[fileNumber ',' AA '\n']);
    fclose(fid);
end
fclose(fid0);






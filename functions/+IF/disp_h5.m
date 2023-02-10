function disp_h5(fileh5)

if ~exist(fileh5,'file')
    disp(fileh5)
    error('Data files do not exist!')
end

info=h5info(fileh5);

N=length(info.Groups(1).Datasets);
disp('***** Groups(1).Datasets *****')
for ii=1:N
   disp(info.Groups(1).Datasets(ii).Name)
end

N=length(info.Groups(2).Datasets);
disp('***** Groups(2).Datasets *****')
for ii=1:N
   disp(info.Groups(2).Datasets(ii).Name)
end




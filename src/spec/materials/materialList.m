function val = materialList()
% returns the list of available cameras
NPpath = fileparts(which('materialList.m'));
matList = dir(NPpath);
Nc = numel(matList);
val = repmat(string(),Nc,1);
for ic = 1:Nc
    val(ic) = string(matList(ic).name(2:end-4));
end


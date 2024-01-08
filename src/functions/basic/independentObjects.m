function [objList2, nList] = independentObjects(objList)
% gathering all the different objects from a list [obj1, obj1, obj2, obj3, obj2]
% into [obj1; obj2; obj3]
% and returns also the distribution of the independent interferos : [1 1 2 3 2]

% Note : objList2(nList) corresponds to objList

No = numel(objList);
objList2 = objList(1);

n=1;
nList = zeros(No,1);
for io = 2:No
    if ~any(objList(io) == objList2) % the new Ref is not already in the list
        n = n+1;
        objList2(n) = objList(io);
    end
end

for ii=1:n
    nList(objList2(ii)==objList) = ii;
end

objList2 = objList2(:);




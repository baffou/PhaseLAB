function setp1p2(ha)
disp('ButtonDownFcn on ha1 detected')
hfig = ha.Parent;
pos = get(ha,'CurrentPoint');
if isempty(hfig.UserData.p1)
    disp('pmin selected')
    hfig.UserData.p1 = pos(1);
else
    disp('pmax selected')
    hfig.UserData.p2 = pos(1);
    hfig.UserData.goon = 1;
end













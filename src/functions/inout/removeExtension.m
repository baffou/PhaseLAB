function string=removeExtension(string0)

pos=find(string0=='.');

if isempty(pos)
    string = string0;
else
    string=string0(1:pos(end)-1);
end

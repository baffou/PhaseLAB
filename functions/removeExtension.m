function string=removeExtension(string0)

pos=find(string0=='.');

string=string0(1:pos(end)-1);


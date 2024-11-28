function mat=CGcolorScale
% grating colorscale

N=256;
mat=zeros(N,3);
maxColor=[204,166,131];
for ii=1:128
    mat(ii,1)=255-(ii-1)*2;
    mat(ii,2)=255-(ii-1)*2;
    mat(ii,3)=255-(ii-1)*2;
end
for ii=129:256
    mat(ii,1)=(ii-129)*maxColor(1)/(256-129);
    mat(ii,2)=(ii-129)*maxColor(2)/(256-129);
    mat(ii,3)=(ii-129)*maxColor(3)/(256-129);
end
mat=round(mat)/256;










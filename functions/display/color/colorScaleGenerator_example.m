%       colorList = ["ffffff";"d9d1a7";"b4913e";"805b28";"492d15";"000000"];
colorList = ["100080";"6500dc";"9a00c4";"d21536";"ff8000";"ffe700";"ffffff"];
colorList = ["000000";"560000";"AD3200";"FF8B00";"FFD900";"FFFF5B";"FFFFFF"];
posList = [0, 17, 33, 50, 66, 84, 100];

colMap = colorScaleGenerator(colorList,posList,256);

figure
imagegb(meshgrid(1:1024,1:100))
colormap(colMap)

%writematrix(colMap,

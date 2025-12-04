%       colorList = ["ffffff";"d9d1a7";"b4913e";"805b28";"492d15";"000000"];
colorList = ["100080";"6500dc";"9a00c4";"d21536";"ff8000";"ffe700";"ffffff"];
colorList = ["000000";"560000";"AD3200";"FF8B00";"FFD900";"FFFF5B";"FFFFFF"];
colorList = ["000000"
"3c6b2d"
"ffe700"
"ff8000"
"d21536"
"ffffff"
"3e49d3"
"9a00c4"
"e73a5f"
"b4914e"
"b3b44e"];

posList = 0:10:100;

colMap = colorScaleGenerator(colorList,posList,256);

figure
imagegb(meshgrid(1:1024,1:100))
colormap(colMap)


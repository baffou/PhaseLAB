colorList = ["ffffff";"d9d1a7";"b4913e";"805b28";"492d15";"000000"];
posList = [0, 12, 33, 50, 70, 100];

colMap = colorScaleGenerator(colorList,posList);

figure
subplot(1,2,1)
imagegb(IM0.OPD)
colormap(colMap)
subplot(1,2,2)
imageph(IM0.OPD)



function LiveMaskDisplay(ha1,ha2,maskList,N)
pos=get (ha1, 'CurrentPoint');
if round(pos(1)*N)>=1
    posN=min([round(pos(1)*N) numel(maskList)]);
else
    posN=1;
end
%fprintf('posx=%d\n',posN/N)
ha2.Children.CData(:,:,1)=maskList{posN}~=0;
drawnow


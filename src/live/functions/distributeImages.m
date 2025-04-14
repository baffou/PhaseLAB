function distributeImages(hfigList,Itf,IL,def)
% function that computes and distribute the computed images (T, W, dW, etc)
%  on the differennt open windows.
arguments
    hfigList % struct containing the list of windows handles
    Itf % Interfero
    IL Illumination
    def {mustBeMember(def,{'high','low'})} = 'low' % image definition
end

MI = app.MI;

cellValues = struct2cell(hfigList);
isEmptyLogical = cellfun(@isempty, cellValues);
statusList = ~isEmptyLogical;

isref = ~isEmpty(Itf.Ref.Itf);

if statusList(4) && all(~statusList([2:3, 5:end])) %dW only
    % If only dW need to be displayed (and maybe raw)
    [~,IM.DWx,IM.DWy]  =  QLSIprocess(Itf,IL,'definition',def,'computeT',0,'computeW',0,'noRef',isref);
elseif isempty(hfigList.T) % no T
    [~,IM.DWx,IM.DWy,IM.OPD]  =  QLSIprocess(Itf,IL,'definition',def,'computeT',0,'computeW',1);
elseif statusList(3) && all(~statusList([2, 5:end])) % T and nothing else than raw and dW (ie nothing that requires the computation of W)
    [~,IM.DWx,IM.DWy,IM.T]  =  QLSIprocess(Itf,IL,'definition',def,'computeT',1,'computeW',0);
elseif isempty(hfigList.dW)
    IM = QLSIprocess(Itf,IL,'definition',def,'saveGradients',0);
else
    IM = QLSIprocess(Itf,IL,'definition',def,'saveGradients',1);
end

if ~isempty(hfigList.raw)
    hfigList.raw.CData = Itf.Itf;
end
if ~isempty(hfigList.T)
    hfigList.T.CData = IM.T;
end
if ~isempty(hfigList.OPD)
    hfigList.W.CData = IM.OPD;
end
if ~isempty(hfigList.dW)
    hfigList.dW.CData = IM.DWx.^2 + IM.DWy.^2;
end
if ~isempty(hfigList.mass)
    hfigList.mass.CData = 5.56*1e-3 * IM.OPD*1e9;
end

if ~isempty(hfigList.mass)
    dxDWy  = imgradientxy(IM.DWy);
    [~, dyDWx] = imgradientxy(IM.DWx);
    hfigList.PDCM.CData= imgaussfilt(dxDWy-dyDWx,3);
end





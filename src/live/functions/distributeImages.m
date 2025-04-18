function distributeImages(app)
% function that computes and distribute the computed images (T, W, dW, etc)
% on the differennt open windows.

HR = app.HR_Button.Value;
HRlist = {'low','high'};
cellValues = struct2cell(app.himList);
isEmptyLogical = cellfun(@isempty, cellValues);
statusList = ~isEmptyLogical;
noref = isempty(app.Itf.Ref);

% As a function of if raw, dW, T and OPD are required, compute only what is needed, ie dW, W and or T
% Note: in any case, if raw is not the only parameter on, dW need to be computed

if any(statusList(2:end)) % if any image other than raw need to be computed
    if statusList(4) && all(~statusList([2:3, 5:end])) % If only dW needs to be displayed (and maybe raw)
        % Then no W or T calculation
        computeT = 0;
        computeW = 0;
    elseif isempty(app.himList.T) && isempty(app.himList.Rytov) % If still neither T nor Rytov, but something more (W, PDCM, etc...)
        % then compute W
        computeT = 0;
        computeW = 1;
    elseif statusList(3) && all(~statusList([2, 5:end])) % if T and nothing else than raw and dW (ie nothing that requires the computation of W)
        computeT = 1;
        computeW = 0;
    else
        computeT = 1;
        computeW = 1;
    end

    [~,app.DWx0,app.DWy0,app.W0,app.T0]  = QLSIprocess(app.Itf,app.IL,'definition',HRlist{HR+1},'displayCrop',false,'noRef',noref, ...
                                          'computeT', computeT, ...
                                          'computeW', computeW, ...
                                          'saveGradients',0, ...
                                          'computeIM',0);
end


app.updateImages()


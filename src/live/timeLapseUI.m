function [N, dt, T_hours, T_minutes] = timeLapseUI
N = 0; % default value in case the user closes the window
dt = 0;
% Create figure
fig = uifigure('Position',[500 500 400 280],'Name','Time Lapse Parameters');

% Labels
uilabel(fig,'Text','Durée totale','Position',[20 230 100 22]);
uilabel(fig,'Text','Heures (h)','Position',[130 250 60 22]);
uilabel(fig,'Text','Minutes (min)','Position',[200 250 80 22]);
uilabel(fig,'Text','Intervalle (dt, s)','Position',[20 180 120 22]);
uilabel(fig,'Text','Nombre images (N)','Position',[20 130 120 22]);

% Edit fields
ThEdit = uieditfield(fig,'numeric','Position',[130 230 60 22]);
TminEdit = uieditfield(fig,'numeric','Position',[200 230 60 22]);
dtEdit = uieditfield(fig,'numeric','Position',[150 180 100 22]);
NEdit = uieditfield(fig,'numeric','Position',[150 130 100 22]);

% Button to validate
btn = uibutton(fig,'Text','Valider','Position',[150 50 100 30],'ButtonPushedFcn',@validate);

% Timestamps for edits
lastEdited.T = datetime;
lastEdited.dt = datetime;
lastEdited.N = datetime;

% Flags to avoid recursive callbacks
updating = false;

% Callbacks
ThEdit.ValueChangedFcn = @(src,event) updateTimestampAndCalculate('T');
TminEdit.ValueChangedFcn = @(src,event) updateTimestampAndCalculate('T');
dtEdit.ValueChangedFcn = @(src,event) updateTimestampAndCalculate('dt');
NEdit.ValueChangedFcn = @(src,event) updateTimestampAndCalculate('N');

uiwait(fig);

    function updateTimestampAndCalculate(changedField)
        lastEdited.(changedField) = datetime;
        calculateThird();
    end

    function calculateThird()
        if updating
            return;
        end
        updating = true;
        
        fields = {'T', 'dt', 'N'};
        [~, idx] = min([lastEdited.T, lastEdited.dt, lastEdited.N]);
        fieldToCalculate = fields{idx};
        
        T = ThEdit.Value*3600 + TminEdit.Value*60; % Total duration in seconds
        dt = dtEdit.Value;
        N = NEdit.Value;
        
        switch fieldToCalculate
            case 'T'
                if ~isempty(dt) && ~isempty(N) && N>1
                    totalSec = dt*(N-1);
                    ThEdit.Value = floor(totalSec/3600);
                    TminEdit.Value = mod(totalSec/60,60);
                end
            case 'dt'
                if ~isempty(T) && ~isempty(N) && N>1
                    dtEdit.Value = T/(N-1);
                end
            case 'N'
                if ~isempty(T) && ~isempty(dt) && dt>0
                    NEdit.Value = floor(T/dt) + 1;
                end
        end
        updating = false;
    end

    function validate(~,~)
        T_hours = ThEdit.Value;
        T_minutes = TminEdit.Value;
        dt = dtEdit.Value;
        N = NEdit.Value;
        uiresume(fig);
        close(fig);
    end

end
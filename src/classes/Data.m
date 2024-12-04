classdef Data < handle
    % objects used to save data from this type of function:
    % data = IM.alpha_ImageProfile
    % which can involve 100s of measurements, all lost if the process is
    % interrupted for some reason.
    properties
        data
    end
end
% Connect a DAQ_Piezo  

ZchBool = 1; % Z axis

try
    Piezo = DAQ_Piezo();
    Piezo.setVoltageRange([0 10],[0 10],[0 10]);
catch e 
    disp("No piezo found ...");
    disp(e.message)
end

% unconnect a DAQ_Piezo  
Piezo.delete();

function T = IM_to_T(IML, IMR, selection)
arguments
    IML
    IMR
    selection {mustBeMember(selection,{'13','24','1234'})} = '1234'
end

Nth = size(IML,1);

T.phi = cell(Nth,1);
T.to = cell(Nth,1);
T.te = cell(Nth,1);

j = exp(1i*pi/4);

for ith = 1:Nth
    
    eL1one =       IML(ith,1).E.*exp(1i*IML(ith,1).Ph) * norm(IML(1).Illumination.polar(1));
    eL3one =   1i* IML(ith,3).E.*exp(1i*IML(ith,3).Ph) * norm(IML(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
    
    eL2one =    j* IML(ith,2).E.*exp(1i*IML(ith,2).Ph) * norm(IML(1).Illumination.polar(1));
    eL4one =  j^3* IML(ith,4).E.*exp(1i*IML(ith,4).Ph) * norm(IML(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
    
    eL1bis = (eL2one-eL4one)/sqrt(2);
    eL3bis = (eL2one+eL4one)/sqrt(2);

    eR1one =       IMR(ith,1).E.*exp(1i*IMR(ith,1).Ph) * norm(IMR(1).Illumination.polar(1));
    eR3one =  -1i* IMR(ith,3).E.*exp(1i*IMR(ith,3).Ph) * norm(IMR(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
    
    eR2one =   j'* IMR(ith,2).E.*exp(1i*IMR(ith,2).Ph) * norm(IMR(1).Illumination.polar(1));
    eR4one = j'^3* IMR(ith,4).E.*exp(1i*IMR(ith,4).Ph) * norm(IMR(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
    
    eR1bis = (eR2one-eR4one)/sqrt(2);
    eR3bis = (eR2one+eR4one)/sqrt(2);

    switch selection
        case '1234'
            eL1 = (eL1one+eL1bis)/2;
            eL3 = (eL3one+eL3bis)/2;
            eR1 = (eR1one+eR1bis)/2;
            eR3 = (eR3one+eR3bis)/2;
        case '13'
            eL1 = eL1one;
            eL3 = eL3one;
            eR1 = eR1one;
            eR3 = eR3one;
        case '24'
            eL1 = eL1bis;
            eL3 = eL3bis;
            eR1 = eR1bis;
            eR3 = eR3bis;
    end

    DL = eL1 - 1i*eL3;
    SL = eL1 + 1i*eL3;
    DR = eR1 - 1i*eR3;
    SR = eR1 + 1i*eR3;
        
    T.phi{ith}= 0.5*atan(imag((DR-SL)./(DR+SL)));

    T.to{ith} = (DL+SL.*exp(2*1i*T.phi{ith}))/sqrt(2);
    T.te{ith} = (DL-SL.*exp(2*1i*T.phi{ith}))/sqrt(2);

end

if numel(T.phi{ith}) == 1 % scalar
    T.phi = cell2mat(T.phi{ith});
    T.to = cell2mat(T.to{ith});
    T.te = cell2mat(T.te{ith});
end


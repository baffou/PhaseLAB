function J = IM_to_J(IML,IMR,selection,opt)
% Equation (20) from Julien Flamant
arguments
    IML
    IMR
    selection {mustBeMember(selection,{'13','24','1234'})} = '1234'
    opt.ph = 1 % phase correction, just to test a misdetermination of the grating camera distance
end


IL_L = IML.Illumination;
IL_R = IMR.Illumination;

Nth = size(IML,1);
[Ny, Nx] = size(IML(1).OPD);
J = cell(Nth,1);



switch selection
    case '13'

        E = zeros(2, 2, Ny, Nx);
        E0 = [IL_L.polar(1:2).' IL_R.polar(1:2).'];
        
        IMLem = ImageEM(IML,'ph',opt.ph);
        IMRem = ImageEM(IMR,'ph',opt.ph);
        
        for ith = 1:Nth
            
            E(1,1,:,:) = IMLem(ith).Ex;%eL1;
            E(1,2,:,:) = IMRem(ith).Ex;%eR1;
            E(2,1,:,:) = IMLem(ith).Ey;%eL3;
            E(2,2,:,:) = IMRem(ith).Ey;%eR3;
            
        %    J{ith} = pagemtimes(E,E0');
            J{ith} = pagemtimes(pagemtimes(E,E0'),(E0*E0')^(-1));
        end
            
    case '1234'
        
        if IML(1).Illumination.S3<0  % right
            j = exp(1i*pi/4);
        elseif IML(1).Illumination.S3>0  % left
            j = exp(-1i*pi/4);
        end

        E = zeros(2, 4, Ny, Nx);
        E0 = [IL_L.polar(1:2).' IL_R.polar(1:2).' IL_L.polar(1:2).' IL_R.polar(1:2).'];
        for ith = 1:Nth

            eL1one =       IML(ith,1).E.*exp(1i*IML(ith,1).Ph*opt.ph) * norm(IML(1).Illumination.polar(1));
            eL3one =  j^2* IML(ith,3).E.*exp(1i*IML(ith,3).Ph*opt.ph) * norm(IML(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
            
            eL2one =    j* IML(ith,2).E.*exp(1i*IML(ith,2).Ph*opt.ph) * norm(IML(1).Illumination.polar(1));
            eL4one =  j^3* IML(ith,4).E.*exp(1i*IML(ith,4).Ph*opt.ph) * norm(IML(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
            
            eL1bis = (eL2one-eL4one)/sqrt(2);
            eL3bis = (eL2one+eL4one)/sqrt(2);
        
            eR1one =       IMR(ith,1).E.*exp(1i*IMR(ith,1).Ph*opt.ph) * norm(IMR(1).Illumination.polar(1));
            eR3one = j'^2* IMR(ith,3).E.*exp(1i*IMR(ith,3).Ph*opt.ph) * norm(IMR(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
            
            eR2one =   j'* IMR(ith,2).E.*exp(1i*IMR(ith,2).Ph*opt.ph) * norm(IMR(1).Illumination.polar(1));
            eR4one = j'^3* IMR(ith,4).E.*exp(1i*IMR(ith,4).Ph*opt.ph) * norm(IMR(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
            
            eR1bis = (eR2one-eR4one)/sqrt(2);
            eR3bis = (eR2one+eR4one)/sqrt(2);
        
            
            E(1,1,:,:) = eL1one;%eL1;
            E(1,2,:,:) = eR1one;%eR1;
            E(2,1,:,:) = eL3one;%eL3;
            E(2,2,:,:) = eR3one;%eR3;
            E(1,3,:,:) = eL1bis;%eL1;
            E(1,4,:,:) = eR1bis;%eR1;
            E(2,3,:,:) = eL3bis;%eL3;
            E(2,4,:,:) = eR3bis;%eR3;
            
        %    J{ith} = pagemtimes(E,E0');
            J{ith} = pagemtimes(pagemtimes(E,E0'),(E0*E0')^(-1));
        end

    case '24'
        if IML(1).Illumination.S3<0  % right
            j = exp(1i*pi/4);
        elseif IML(1).Illumination.S3>0  % left
            j = exp(-1i*pi/4);
        end

        E = zeros(2, 2, Ny, Nx);
        E0 = [IL_L.polar(1:2).' IL_R.polar(1:2).'];
        for ith = 1:Nth

            eL2one =    j* IML(ith,2).E.*exp(1i*IML(ith,2).Ph*opt.ph) * norm(IML(1).Illumination.polar(1));
            eL4one =  j^3* IML(ith,4).E.*exp(1i*IML(ith,4).Ph*opt.ph) * norm(IML(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
            
            eL1bis = (eL2one-eL4one)/sqrt(2);
            eL3bis = (eL2one+eL4one)/sqrt(2);
        
            eR2one =   j'* IMR(ith,2).E.*exp(1i*IMR(ith,2).Ph*opt.ph) * norm(IMR(1).Illumination.polar(1));
            eR4one = j'^3* IMR(ith,4).E.*exp(1i*IMR(ith,4).Ph*opt.ph) * norm(IMR(1).Illumination.polar(1)); % Assumes here a given handedness, but could be the opposite
            
            eR1bis = (eR2one-eR4one)/sqrt(2);
            eR3bis = (eR2one+eR4one)/sqrt(2);
        
            
            E(1,1,:,:) = eL1bis;%eL1;
            E(1,2,:,:) = eR1bis;%eR1;
            E(2,1,:,:) = eL3bis;%eL3;
            E(2,2,:,:) = eR3bis;%eR3;
            
            J{ith} = pagemtimes(pagemtimes(E,E0'),(E0*E0')^(-1));
        end


end    
    
    
    
    


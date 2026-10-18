function T = IM_to_T(IML, IMR, opt)
arguments
    IML
    IMR
    opt.selection {mustBeMember(opt.selection,{'13','24','1234'})} = '1234'
    opt.method {mustBeMember(opt.method,{'JF','GB'})} = 'JF'
end


switch opt.method
    case 'GB' % closed-form direct expressions

        Nth = size(IML,1);
        j = exp(1i*pi/4);
        T = ImageTransmittance(Nth);
        
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
        
            switch opt.selection
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
            %SR = eR1 + 1i*eR3;
                
            phi = 0.5*atan(imag((DR-SL)./(DR+SL)));
        
            to  = (DL+SL.*exp(2*1i*phi))/sqrt(2);
            te  = (DL-SL.*exp(2*1i*phi))/sqrt(2);
        
            T(ith) = ImageTransmittance(to, te, phi, IML(ith,1).Illumination);
        
        end

    case 'JF'

        J = IM_to_J(IML,IMR);
        Nim = numel(J);
       
        T = ImageTransmittance(Nim);
        
        % vectorized algorithm of the retrieval of biref and diatt properties, from J
        for ith = 1:Nim
            [bir, diatt] = jones_decomposition_vectorized0(J(ith).mat, 'HU');
            phid = -angle(diatt.pd(:,:,1)+1i*diatt.pd(:,:,2))/2;
            phib = -angle(bir.pb(:,:,1)+1i*bir.pb(:,:,2))/2;
            phi = angle(exp(1i*phib*4)+exp(1i*phid*4))/4;
            to = diatt.h0.*exp(1i*bir.phi0).*(1+diatt.D).*exp(1i*( bir.beta/2));
            te = diatt.h0.*exp(1i*bir.phi0).*(1-diatt.D).*exp(1i*(-bir.beta/2));
            %Dic = diatt.D;
            %Bir = bir.beta;
            T(ith) = ImageTransmittance(to, te, phi, IML(ith).Illumination, "phib",phib,"phid",phid);
        
        end

end
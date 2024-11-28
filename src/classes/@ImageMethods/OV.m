        function DMmean = OV(IM,NNP,nmax0,hfigInit)
            % NNP: number of nanoparticles to be measured in the image
            % size of the cropped area around the NP
            if nargin>=4
                hand = hfigInit.UserData{8};
                UIresult = hand.UIresult;
                if ~strcmp(hfigInit.UserData{2},'px')
                    error('Please select px units to use the alpha function')
                end
            end
            if isa(IM,'ImageEM')
                if norm(IM.EE0)==0
                    warning('As E0 is zero at the image plane, the T map is not normalized and the alpha won''t be absolutely measured.')
                end
            end
            taillePx = IM.pxSize;
            
            %nmax = input('valeur de nmax');
            if nargin==1
                NNP = 1;
                nmax0 = 40;
            elseif nargin==2
                nmax0 = 40;
            end
            
            DMmean = zeros(NNP,1);
            
            imph = IM.OPD;
            imT = IM.T; %./imTref; %intensity normalization
            
            for iNP = 1:NNP
                
                if NNP~=1
                    fprintf(['Nanoparticle #' num2str(iNP) '/' num2str(NNP) '\n'])
                end
                if nargin<4
                    hfigInit = figure;imagesc(imT),colormap(gray),colorbar
                    %% zoom on the particle of interest
                    zoom on
                    waitfor(gcf,'CurrentCharacter',char(13))
                    zoom reset
                end
                
                % press the central pixel of the particle
                
                button = 0;
                while(button~=1) % i.e. as long as it is not a mouse click
                    figure(hfigInit)
                    [x,y] = ginput(1);
                    
                    %% starting pixel for sum
                    %n = input('nothing');
                    
                    nmax = min(round(y)-1, nmax0);
                    nmax = min(round(x)-1, nmax);
                    nmax = min(IM.Ny-round(y)-1,nmax);
                    nmax = min(IM.Nx-round(x)-1,nmax);
                    
                    
                    imPcrop = imph(round(y)-nmax:round(y)+nmax,round(x)-nmax:round(x)+nmax); %crop OPD image
                    
                    % create mask image
                    coo = 0:1:nmax; % integration radius
                    Noo = numel(coo);
                    sizeX = 2*nmax+1;
                    sizeY = 2*nmax+1;
                    [rows,columns] = meshgrid(1:sizeX, 1:sizeY);
                    
                    DM = zeros(Noo);
                    %% computation of alpha in function of the summed pixel number
                    for co = 1:Noo
                        rr = coo(co);
                        array2D = (rows - (nmax+1)).^2 + (columns - (nmax+1)).^2;
                        circle = array2D <= rr.^2; %mask circle for each cooeration
                        ring = array2D >= rr.^2 & array2D <= (rr+1).^2; %mask ring
                        
                        imP = imPcrop.*circle;
                        imP_0 = imPcrop.*ring; %only the borders of background image are different from 0
                        
                        backgroundOPD = sum(imP_0(:))/(sum(ring(:))); %mean backgound
                        OPDnorm = (imP-backgroundOPD);
                        
                        %% experimental dry mass
                        OPDnormask = OPDnorm(circle); %take only values included in the circle
                        DM(co) = sum(OPDnormask(:))*taillePx.*taillePx;
                        
                    end
                    
                    
                    %absalpha = abs(alpha);
                    %save -ascii absalpha absalpha
                    
                    %subplot(3,3,9),plot(coo,angle(alpha))
                    %title('Argalpha(rad)')
                    %angalpha = angle(alpha);
                    %save -ascii angalpha_focus angalpha
                    
                    hfig2 = figure();
                    plot(DM)
                    %save -ascii realpha_p250 realpha
                    
                    %% mean value of alpha and error bares
                    %pxmin = input('valeur de pxmin'); %faire la moyene de alpha entre pxmin et pxmax
                    %pxmax = input('valeur de pxmax');
                    [xp,~,button] = ginput(2);  % click twice on any key to restart the loop. Other, click twice with the mouse to keep on going.
                    close(hfig2)
                end
                
                
                pxmin = round(min(xp));
                pxmax = min(round(max(xp)),Noo); % in case the user clicks too far in x
                if pxmax<pxmin
                    error('The second click must correspond to a higher x value.')
                end
                DMmean(iNP) = mean(DM(pxmin:pxmax));
                %fprintf('Optical volume: %.4g µm^3\n',1e18*DMmean(iNP))
                
                if nargin>=4
                    set(UIresult,'String',sprintf('%.3g',DMmean));
                end
            end
            if nargin>=4
                hfigInit.UserData{10} = DMmean;
            end
            fprintf(num2str(DMmean))
            fprintf('\n')
        end
        

[OPDsimu, Tsimu, IMout] = process_DRIMAPS(IM, shotNoise, freq, thetaGrating);
                    Nx=IMp.Nx;
                    Ny=IMp.Ny;

                    [XX,YY]=meshgrid(1:Nx,1:Ny);

                    EE0=IMp.Einc.EE0;
                    I0=abs(EE0(2))^2;

                    fwc=IMp.Microscope.CGcam.Camera.fullWellCapacity;

                    if shotNoise
                        noiseFunction = @poissrnd;
                    else
                        noiseFunction = @identity;
                    end

                    I = cell(4,1);
                    for ii = 1:4
                        E2 = abs( IMp.Ey + sqrt(I0)*exp(1i*(ii-1)*pi/2) ).^2;
                        I{ii}=noiseFunction(E2*fwc/(4*I0)); % factor of 4 because sum intensities of obj and ref
                    end

                    figure
                    for ii=1:4
                        subplot(2,2,ii)
                        imagegb(I{ii})
                    end

                    Phi = atan2(I{2}-I{4},I{1}-I{3}); % order inversion because the phase is applied on Einc

                    figure
                    subplot(1,2,1)
                    imagegb(Phi*lambda/2/pi)
                    subplot(1,2,2)
                    imagegb(IMp.OPD)

                    figure
                    hold on
                    plot(Phi(end/2,:)*lambda/2/pi)
                    plot(IMp.OPD(end/2,:))
                    drawnow

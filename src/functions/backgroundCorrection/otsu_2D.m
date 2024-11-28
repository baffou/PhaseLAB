% from https://en.wikipedia.org/wiki/Otsu%27s_method
function threshold = otsu_2D(hists, total)
% Otsu method for image segmentation
maximum = 0.0;
threshold = 0;
helperVec = 0:255;
mu_t0 = sum(sum(repmat(helperVec',1,256).*hists));
mu_t1 = sum(sum(repmat(helperVec,256,1).*hists));
p_0 = zeros(256);
mu_i = p_0;
mu_j = p_0;
for ii = 1:256
    for jj = 1:256
        if jj == 1
            if ii == 1
                p_0(1,1) = hists(1,1);
            else
                p_0(ii,1) = p_0(ii-1,1) + hists(ii,1);
                mu_i(ii,1) = mu_i(ii-1,1)+(ii-1)*hists(ii,1);
                mu_j(ii,1) = mu_j(ii-1,1);
            end
        else
            p_0(ii,jj) = p_0(ii,jj-1)+p_0(ii-1,jj)-p_0(ii-1,jj-1)+hists(ii,jj); % THERE IS A BUG HERE. INDICES IN MATLAB MUST BE HIGHER THAN 0. ii-1 is not valid
            mu_i(ii,jj) = mu_i(ii,jj-1)+mu_i(ii-1,jj)-mu_i(ii-1,jj-1)+(ii-1)*hists(ii,jj);
            mu_j(ii,jj) = mu_j(ii,jj-1)+mu_j(ii-1,jj)-mu_j(ii-1,jj-1)+(jj-1)*hists(ii,jj);
        end

        if (p_0(ii,jj) == 0)
            continue;
        end
        if (p_0(ii,jj) == total)
            break;
        end
        tr = ((mu_i(ii,jj)-p_0(ii,jj)*mu_t0)^2 + (mu_j(ii,jj)-p_0(ii,jj)*mu_t1)^2)/(p_0(ii,jj)*(1-p_0(ii,jj)));

        if ( tr >= maximum )
            threshold = ii;
            maximum = tr;
        end
    end
end
end
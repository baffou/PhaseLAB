function Jm = meanJones(J,masks)

Nth = numel(J);
Jm = cell(Nth,1);
for ith = 1:Nth
    Jm{ith} = zeros(2,2);
    Jr = squeeze(J{ith}(1,1,:,:));
    Jm{ith}(1,1) = mean(Jr(masks{ith}));
    Jr = squeeze(J{ith}(1,2,:,:));
    Jm{ith}(1,2) = mean(Jr(masks{ith}));
    Jr = squeeze(J{ith}(2,1,:,:));
    Jm{ith}(2,1) = mean(Jr(masks{ith}));
    Jr = squeeze(J{ith}(2,2,:,:));
    Jm{ith}(2,2) = mean(Jr(masks{ith}));
end
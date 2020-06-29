function [IDX,C,K]=auto_kmeans(X, W)

R = length(X);
SS=zeros(1,R);
min_is = zeros(1,R);
IDXs = {};
Cs = {};

for k=1:1:R
    %run kmeans a few times
    run = 5;
    sumds = zeros(1, run);
    for i=1:1:run
        [IDX,C,sumd]=weighted_kmeans(X,W,k);
        IDXs{k,i} = IDX;
        Cs{k,i} = C;
        sumds(i) = sum(sumd);
    end
    [SS(k), min_is(k)]= min(sumds);
end

D = (SS-SS(1))/(SS(end)-SS(1));
%plot(D,'b*--');
K = find(D>0.96, 1);
IDX = IDXs{K, min_is(K)};
C = Cs{K, min_is(K)};

% %with this K, run a few times and take median centroids
% Cs = {};
% IDXs = {};
% for i=1:1:5
%     [IDX,C] = weighted_kmeans(X,W,K);
%     Cs = {Cs C};
%     IDXs = {IDXs IDX};
% end



function [IDX,C,K]=kmeans_info(X, W)

R = length(X);
info = [];
likelihood = [];
BIC = [];
for k=1:1:10
    [~,~,sumd]=weighted_kmeans(X,W,k);
    sum_squares=sum(sumd);
    for i=1:1:5
        [idx,~,sumd]=weighted_kmeans(X,W,k);
        sum_squares=min(sum_squares,sum(sumd));
    end
    var = sum_squares/(R - k);
    Rn = zeros(1,k);
    for n=1:1:k
        Rn(n) = sum(idx==n);
    end
    L = (-0.5*(R-k)) - R*log(var*sqrt(2*pi)) + sum(Rn.*log(Rn/R));
    p = (k-1) + 2*k + 1;
    I = 0.5*p*log(R);
    
    info = [info p];
    likelihood = [likelihood L];
    BIC = [BIC L-p];
end

hold on
plot(BIC,'b*--');
plot(likelihood, 'g*--')
plot(info, 'r*--')
IDX=[];
C=[];
K=[];
%[IDX,C,K]=kmeans(X,K);
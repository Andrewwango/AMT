function [idx,C,sumd]=weighted_kmeans(X,W,K)

Y=X;
%apply weights
for i=1:1:length(X)
    for j=1:1:round(W(i)/0.1)
        Y = [Y ; X(i, 1) X(i, 2)];
    end
end

%cluster
[idx,C, sumd] = kmeans(Y, K);

%remove weights
idx = idx(1:length(X));

%create sumd
% sumd = zeros(K,1);
% for k=1:1:K   
%     norms = norm(X(idx==k) - C(k,:));
%     sumd(k) = sum(norms);
% end
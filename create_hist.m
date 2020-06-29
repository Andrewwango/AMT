
Ns = [];
nps = [];
rng = -3:0.2:3;

for i=1:1:10
    subplot(10,1,i)
    p = my_partialpattern.patterns(:,i);
    p = p(p~=0);
    np = (p-mean(p))/std(p);
    [N, ~] = histcounts(np, rng);
    bar(rng(1:end-1), N);
    Ns = [Ns; N];
    nps = [nps; np];
    [h,p] = chi2gof(nps);
    p
end

figure(2)
totbars = sum(Ns,1);
bar(rng(1:end-1), totbars);
    
    
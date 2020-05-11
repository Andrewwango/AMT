%compute gaussians
all_means = {};
all_stds = {};
for train_set = all_training_sets
    train_set = train_set{1};
    all_means{length(all_means)+1} = mean(train_set.').';
    all_stds{length(all_stds)+1} = std(train_set.').';
end

%test
confusion = zeros(N);

for j = 1:1:N
    test_set = all_test_sets{j};
    
    for i = 1:1:length(test_set)
        p = [];
        for k = 1:1:N
            %compute sax prob
            prob = normpdf(test_set(:, i), all_means{k}, all_stds{k});
            p = [p prod(prob(2:end))];
        end
        [~, max_k] = max(p);
        confusion(j, max_k) = confusion(j, max_k) + 1;
    end
end

cm = confusionchart(confusion);
cm.RowSummary = 'row-normalized';
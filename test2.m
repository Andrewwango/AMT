function iterator_matrix=test2(n_voices, n_freqs, varargin)
if nargin > 2
    submat = test2(n_voices-nargin+2, n_freqs);
    iterator_matrix = [repmat(sort(varargin{1}), size(submat, 1), 1) submat];
else
    iterator_matrix = zeros(n_freqs^n_voices, n_voices);
    for v_i = 1:1:n_voices
        iterator_matrix(:,v_i) = repmat(repelem(1:1:n_freqs, n_freqs^(n_voices-v_i)), 1, n_freqs^(v_i-1));
    end
    iterator_matrix = unique(sort(iterator_matrix, 2), 'rows');
end
%only get rows containing must_include
%must_include = sort(must_include);
%temp = iterator_matrix(:, 1:length(must_include))
%iterator_matrix(all(temp == must_include,2), :)
end
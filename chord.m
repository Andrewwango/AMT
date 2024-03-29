classdef chord
    properties
        ffreqs
        loudnesses
        instruments
        start_time
        end_time
    end
    methods
        function obj=chord(varargin)
            if nargin > 1
                obj.ffreqs = varargin{1};
                obj.loudnesses = varargin{2};
                obj.instruments = varargin{4};
                obj.start_time = varargin{4};
                obj.end_time = varargin{5};
            else %input harmony
                obj.ffreqs = [];
                obj.loudnesses = [];
                obj.instruments = [];
                obj.start_time = varargin{1}.start_time;
                obj.end_time = varargin{1}.end_time;
            end
        end
        
        function fitted=fit(obj, harmony, varargin)
            fitted = obj;
            freqs = harmony.freqs;
            amps = harmony.avg_amps;           
            
            %iterate through number of voices
            MAX_V = 2;
            best_assignments = cell(1, MAX_V);
            for v=1:MAX_V
                v
                instrument_assignment = create_iterator_matrix(v, length(varargin), true);
                best_assignments{v} = {};
                for i_a=1:1:size(instrument_assignment, 1)
                    w0=repelem(20, v);
                    ppatterns = varargin(instrument_assignment(i_a, :));
                    if v > 1, prev_best = best_assignments{v-1}.freq_ass; else, prev_best = []; end
                    freq_assignment = create_iterator_matrix(v, length(freqs), false, prev_best);
                    likelihoods = zeros(1, size(freq_assignment,1));
                    tic
                    for i_f=1:1:size(freq_assignment, 1)
                        likelihoods(i_f) = calc_likelihood(w0, freqs, amps, freq_assignment(i_f,:), ppatterns);
                    end
                    toc
                    %find f0 assignment with best likelihood (or a few) with w0
                    tic
                    [~, I_F] = max(likelihoods);
                    [w, lmax] = fmincon(@(w)-calc_likelihood(w, freqs, amps, freq_assignment(I_F,:), ppatterns), ...
                        w0,[],[],[],[],repelem(0,v));
                    toc
                    best_assignments{v}{end+1} = struct( ...
                        'instr_ass', instrument_assignment(i_a,:), ...
                        'freq_ass', freq_assignment(I_F,:), ...
                        'lhood', -lmax, ...
                        'vol', w);
                end
                [~,I_A] = max(cellfun(@(x)x.lhood, best_assignments{v}));
                best_assignments{v} = best_assignments{v}{I_A};
            end
            
            celldisp(best_assignments)
            
            AICs = (3*(1:1:MAX_V)) - log(cellfun(@(x)x.lhood, best_assignments))
            [~, best_v] = min(AICs);
            
            %choose the v with lowest AIC
            fitted.ffreqs = freqs(best_assignments{best_v}.freq_ass);
            fitted.loudnesses = best_assignments{best_v}.vol;
            fitted.instruments = best_assignments{best_v}.instr_ass;
            
        end
    end
end

function iterator_matrix=create_iterator_matrix(n_voices, n_freqs, repeats, varargin)
if nargin > 3 && ~isempty(varargin{1})
    submat = create_iterator_matrix(n_voices-length(varargin{1}), n_freqs, repeats);
    iterator_matrix = [repmat(sort(varargin{1}), size(submat, 1), 1) submat];
else
    iterator_matrix = zeros(n_freqs^n_voices, n_voices);
    for v_i = 1:1:n_voices
        iterator_matrix(:,v_i) = repmat(repelem(1:1:n_freqs, n_freqs^(n_voices-v_i)), 1, n_freqs^(v_i-1));
    end
    if ~repeats
        iterator_matrix = unique(sort(iterator_matrix, 2), 'rows');
    end
end
end
    
function prob=calc_likelihood(w, freqs, x, f0_assignment, ppatterns)
prob = 0;
for i=1:1:length(freqs)
    mean_p = 0;
    var_p = 0;
    pro = 0;
    no_pp_available = false;
    for j=1:1:length(w)
        f0 = freqs(f0_assignment(j));
        if ~is_overtone(f0, freqs(i))
            no_pp_available = true;
            continue
        end
        k = round(freqs(i)/f0);
        if k > ppatterns{j}.pattern_len
            pro = NaN;
            continue
        end
        %fprintf("%f %f %f \n", i,j,f0)
        %k
        pp_pat = ppatterns{j}.avg_n();
        pp_std = ppatterns{j}.std_n();
        mean_p = mean_p + pp_pat(k)*w(j);
        var_p = var_p + (pp_std(k)*w(j))^2;
    end
    if isnan(pro)
        continue
    end
    if var_p == 0 && no_pp_available
        mean_p = 0;
        var_p = 1;
    end
    if var_p ~= 0
        %pro = normpdf(x(i), mean_p, sqrt(var_p))/normpdf(mean_p, mean_p, sqrt(var_p));
        pro = ((x(i) - mean_p)/sqrt(var_p))^2;
        %fprintf("x %f mu %f s %f prob %f \n", x(i), mean_p, sqrt(var_p), pro)  
    end
    prob = prob + pro;
end
prob = exp(-0.5 * prob);
end

function r=is_overtone(f0, f)
overtones = equaltemper(f0*(1:1:20));
r = ~isempty(find(overtones == f, 1));
end
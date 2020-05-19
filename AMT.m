fmax = 4410;
fNyq = fmax * 2;
t_d = 1;
t_s = 1/30;
[x,fs] = audioread("C:\Users\mcgivyw\Desktop\AMT\piano-1.wav");
x = x(:,1); %stereo to mono
x_lp = lowpass(x, fmax, fs);
x_ds = downsample(x_lp, fs/fNyq);

c = 4;
chunk = x_ds(t_d*fNyq*(c-1)+1:t_d*fNyq*(c)+2);
wft = abs(WindowFT(chunk, t_s*fNyq, t_s*fNyq, 'Gaussian'));
close
%stft(discretisation, fNyq, 'FFTLength', 8820, 'Window',rectwin(t_s*fNyq),'OverlapLength',0);
wft = wft(1:(t_d*fNyq/2+1),:);
wft = wft(1:min(round(equaltemper(999999999)), end), :);

spect = [];
partials = {};
harmonies = {};
for i = 1:1:size(wft,2)
    y_i = wft(:,i);

    %peak detection
    [~, peak_freqs] = findpeaks(movmean(y_i,30), 'MinPeakProminence', 0.2);
    peak_amps = y_i(peak_freqs);
    note_freqs = equaltemper(peak_freqs);
    
    for j = 1:1:length(peak_freqs)
        spect = [spect ; i note_freqs(j) peak_amps(j)];
        new_p = true;
        for p = 1:1:length(partials)
            if (partials(p).end_time == i-1 | partials(p).end_time == i-2) & abs(partials(p).freq - note_freqs(j)) <= 0.1
                partials(p).end_time = i;
                partials(p).amps = [partials(p).amps peak_amps(j)];
                new_p = false;
                break
            end
        end
        if new_p == true
            partials = [partials partial(i, i, note_freqs(j), [peak_amps(j)])];
        end
    end
end

%filter
partials = partials(([partials.end_time] - [partials.start_time] >= 2) & ([partials.freq] > equaltemper(0)));

%split long partials
hold on
ps = [5 6 11 22 14];
for p=1:1:length(partials)
    %plot(linspace(partials(p).start_time, partials(p).end_time, length(partials(p).amps)), partials(p).amps)
    %plot(partials(p).start_time, partials(p).amps(1), 'ro')    
    
    late_attack = movmean(partials(p).amps, 3);
    v = [diff(late_attack) 0];
    late_attack(v<mean(v)+2*std(v)) = 0; %get rises and falls
    late_attack(1:round(length(late_attack)/3)) = 0; %not in initial attack or decay
    new_ps = find([0 diff(logical(late_attack))==1]) + partials(p).start_time; %detect edges
    
    %plot(linspace(partials(p).start_time, partials(p).end_time, length(partials(p).amps)), [0 diff(logical(late_attack))==1])
    
    if isempty(new_ps)
        continue
    else
        new_ps = new_ps(1);
    end
    
    %modify partials
    partials = [partials partial(new_ps, partials(p).end_time, partials(p).freq, partials(p).amps(new_ps-partials(p).start_time:end))];
    partials(p).end_time = new_ps - 1;
    partials(p).amps = partials(p).amps(1:new_ps-partials(p).start_time-1);
end

% hold on
% scatter(spect(:,1), spect(:,2))%, spect(:,3)) %time, frequency plot
% for p=1:1:length(partials)
%     scatter(linspace(partials(p).start_time, partials(p).end_time, 200), ones(200,1)*partials(p).freq, 5, 'MarkerEdgeColor',[0.5 0 0], 'MarkerFaceColor',[0.5 0 0]);
%     text(partials(p).end_time, partials(p).freq, string(partials(p).freq));
% end
% return
% scatter([partials.start_time], [partials.end_time], cellfun(@mean, {partials.amps})*10);
% return

%cluster
[idx,C,k_clusters] = auto_kmeans([[partials.start_time].' [partials.end_time].'], cellfun(@mean, {partials.amps}).');


%Create harmony objects
for k=1:1:k_clusters
    children = partials((idx==k)&(sum(abs((C(k,:) - [partials.start_time; partials.end_time].')),2)<500));
    scatter([children.start_time], [children.end_time], cellfun(@mean, {children.amps})*20);
    harmonies = [harmonies harmony(C(k,1), C(k,2), [children.freq], cellfun(@mean, {children.amps}))];
    string(min([children.freq])) + " Hz: " + string(C(k,2)-C(k,1))
end
legend(string(1:1:k_clusters))
plot(C(:,1),C(:,2), 'kx', 'MarkerSize',15,'LineWidth',3)

return
%Add to partial pattern
my_partialpattern = partialpattern;
for h=1:1:length(harmonies)
    pattern = zeros(1,10);
    ffreq = min(harmonies(h).freqs);
    for i=1:1:my_partialpattern.pattern_len
        f = find(harmonies(h).freqs==equaltemper(ffreq*i));
        if ~isempty(f)
            pattern(i) = harmonies(h).avg_amps(f(1));
        end
    end
    my_partialpattern = update_pattern(my_partialpattern, pattern);
    a = plot(pattern, 'o-');
    label(a, string(ffreq));
end
plot(my_partialpattern.avg_pattern, '*-')
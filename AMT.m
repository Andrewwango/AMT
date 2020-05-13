middleA = 440;
equaltemper = [];
notes = ["G#2" "A2" "A#2" "B2" "C3" "C#3" "D3" "D#3" "E3" "F3" "F#3" "G3" "G#3" "A3" "A#3" "B3" "C4" "C#4" "D4" "D#4" "E4" "F4" "F#4" "G4" "G#4" "A4" "A#4" "B4" "C5" "C#5" "D5" "D#5" "E5" "F5" "F#5" "G5" "G#5" "A5" "A#5" "B5" "C6" "C#6" "D6" "D#6" "E6" "F6" "F#6" "G6" "G#6" "A6" "A#6" "B6" "C7" "C#7" "D7" "D#7" "E7" "F7" "F#7"];
equaltemper_ranges = [;];
for i = -25:1:33
    equaltemper = [equaltemper middleA*2^(i/12) ];
    equaltemper_ranges = [equaltemper_ranges ; middleA*2^((i*100 - 50)/1200) middleA*2^((i*100 + 50)/1200) ];
end
log_equaltemper = log2(equaltemper);

fmax = 4410;
fNyq = fmax * 2;
t_d = 1;
t_s = 1/30;
[x,fs] = audioread("C:\Users\mcgivyw\Desktop\AMT\piano-1.wav");
x = x(:,1); %stereo to mono
x_lp = lowpass(x, fmax, fs);
x_ds = downsample(x_lp, fs/fNyq);

chunk = x_ds(1:t_d*fNyq);
wft = abs(WindowFT(chunk, t_s*fNyq/2, t_s*fNyq, 'Rectangle'));
close
%stft(discretisation, fNyq, 'FFTLength', 8820, 'Window',rectwin(t_s*fNyq),'OverlapLength',0);
wft = wft(1:(t_d*fNyq/2+1),:);
wft = wft(1:round(max(equaltemper)), :);

spect = [];
partials = {};
%plot(wft(:, 12))
%return
for i = 1:1:size(wft,2)
    y_i = wft(:,i);

    %peak detection
    [~, peak_freqs] = findpeaks(movmean(y_i,30), 'MinPeakProminence', 0.2);
    peak_amps = y_i(peak_freqs);
    note_freqs = 2.^ interp1(log_equaltemper, log_equaltemper, log2(peak_freqs), 'nearest');

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
            newpartial = partial;
            newpartial.start_time = i;
            newpartial.end_time = i;
            newpartial.freq = note_freqs(j);
            newpartial.amps = [peak_amps(j)];
            partials = [partials, newpartial];
        end
    end
end
%filter
P = zeros(size(partials));
for p=1:1:length(partials)
    if partials(p).end_time - partials(p).start_time >= 2
        P(p) = 1;
    end
end
partials = partials(logical(P));


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
    end
    
    %modify partials
    newpartial = partial;
    newpartial.start_time = new_ps;
    newpartial.end_time = partials(p).end_time;
    newpartial.freq = partials(p).freq;
    newpartial.amps = partials(p).amps(new_ps-partials(p).start_time:end);
    partials = [partials newpartial];
    partials(p).end_time = new_ps - 1;
    partials(p).amps = partials(p).amps(1:new_ps-partials(p).start_time-1);
end

hold on
%scatter(spect(:,1), spect(:,2))%, spect(:,3)) %time, frequency plot
for p=1:1:length(partials)
    %scatter(linspace(partials(p).start_time, partials(p).end_time, 200), ones(200,1)*partials(p).freq, 5, 'MarkerEdgeColor',[0.5 0 0], 'MarkerFaceColor',[0.5 0 0]);
    %text(partials(p).end_time, partials(p).freq, string(p));
end

X = zeros(length(partials), 2);
for p=1:1:length(partials)
    X(p,:) = [partials(p).start_time partials(p).end_time];
end
for p=1:1:length(partials)
    for i=1:1:round(mean(partials(p).amps)/0.1)
        X = [X ; partials(p).start_time partials(p).end_time];
    end
end

[idx,C] = kmeans(X,2);
idx = idx(1:length(partials));
plot(C(:,1),C(:,2), 'kx', 'MarkerSize',15,'LineWidth',3)

%Create harmony objects

%Correlate harmony partials with numbers to obtain partial patters

%Create partial patterns

%plot
for p=1:1:length(partials)
    if idx(p) == 1
        scatter(partials(p).start_time, partials(p).end_time, 'r');
    elseif idx(p) == 2
        scatter(partials(p).start_time, partials(p).end_time, 'g');
    end
end
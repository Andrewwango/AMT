fmax = 4410; %max frequency content
fNyq = fmax * 2; %min sampling frequency
t_c = 1;
t_w = 1/15;
[x,fs] = audioread("C:\Users\mcgivyw\Desktop\AMT\pianopiano-1.wav");
x = x(:,1); %stereo to mono
x_lp = lowpass(x, fmax, fs);
x_ds = downsample(x_lp, fs/fNyq);
fs = fNyq;

cs = 1:0.5:floor(length(x_ds)/(t_c*fs));
all_harmonies = cell(1, length(cs));
warning('off','signal:findpeaks:largeMinPeakHeight')

for i = 3%1:1:length(cs)
    c = cs(i);
    % Obtain wft
    chunk_start = (c-1) * t_c / t_w;
    chunk = x_ds(t_c*fs*(c-1)+1:t_c*fs*c+2);
       
    wft = abs(WindowFT(chunk, t_w*fs, t_w*fs, 'Gaussian'));
    wft = wft(1:min(round(equaltemper(999999999)), (t_c*fs/2+1)), :); %truncate to useful frequency content
    
    partials = create_partials(wft);
    if isempty(partials)
        continue
    end
    
    harmonies = create_harmonies(partials, chunk_start, chunk_start+t_c/t_w, mean(abs(fft(chunk))));
    
    if c > 1
        prev_harmonies = all_harmonies{i-1};
        [harmonies, mark_for_deletion_p, mark_for_deletion_c] = harmony.check_similar(prev_harmonies, harmonies);
        all_harmonies{i-1} = prev_harmonies(~mark_for_deletion_p);
        harmonies = harmonies(~mark_for_deletion_c);
    end
    
    all_harmonies{i} = harmonies;
end

for i = 3%1:1:length(cs)
    harmonies = all_harmonies{i};
    for h=1:1:length(harmonies)
        fit_patterns(harmonies(h));
    end
end

return
figure
harmony.plot_all_harmonies(all_harmonies, cs)

return
figure
my_partialpattern = partialpattern.all_harmonies_to_pattern(all_harmonies);
plot(my_partialpattern.avg_pattern(), '*-')

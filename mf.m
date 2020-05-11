if exist("all_training_sets", "var") == 0
    all_training_sets = {};
    all_test_sets = {};
    N = 0;
end

fmax = 4410;
fNyq = fmax * 2;
t_d = 1;
t_s = t_d/30;
[x,fs] = audioread("C:\Users\mcgivyw\Desktop\AMT\pianopiano-2.wav");
x = x(:,1); %stereo to mono
x_lp = lowpass(x, fmax, fs);
x_ds = downsample(x_lp, fs/fNyq);

c = [];

for i = 1:1:floor(length(x)/(t_s*fNyq))-2
    sample = x(round(1+i*t_s*fNyq) : round(1+(i+1)*t_s*fNyq));
    cepFeatures = cepstralFeatureExtractor('SampleRate',fNyq);
    [coeffs,~,~] = cepFeatures(sample);
    c = [c coeffs];
end

rand_ind = randperm(length(c));
train_len = round(length(c) * 0.7);
train_set = c(:, rand_ind(1:train_len));
test_set =  c(:, rand_ind(train_len+1:end));

all_training_sets{length(all_training_sets)+1} = train_set;
all_test_sets{length(all_test_sets)+1} = test_set;
N = N + 1;
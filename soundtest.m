fmax = 4410;
fNyq = fmax * 2;
t_d = 1;
t_s = t_d/30;
[x,fs] = audioread("C:\Users\mcgivyw\Desktop\AMT\bb_piano.wav");
x_lp = lowpass(x, fmax, fs);
x_ds = downsample(x_lp, fs/fNyq);
x_filter = filter([1 -0.95], 1, x_ds);
sound(x_filter, fNyq)
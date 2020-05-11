import numpy, scipy, matplotlib, matlab.engine
import matplotlib.pyplot as plt
from scipy.io import wavfile
eng = matlab.engine.start_matlab()

fs, x = wavfile.read("C:\\Users\\mcgivyw\\Desktop\\AMT\\bb.wav")

fmax = 4410;

print(type(eng.lowpass(matlab.double(x), fmax, fs)))

plt.plot(x)
plt.show()

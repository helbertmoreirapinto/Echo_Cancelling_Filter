% Frame sample
Fs = 44100;
% object
recObj = audiorecorder(Fs);

t = 10; % audio time
disp('Start recording');
recordblocking(recObj, t);
disp('End of recording');

% play audio
play(recObj);

% get audio data
data = getaudiodata(recObj);

% plot data
plot(data);

% write audio
audiowrite("audio_original.wav", data, Fs);

% vector echo
echo_vector = [1                  zeros(1,0.15*Fs)     ... 
               0.1*exp(1i*pi/3.5) zeros(1,0.3*Fs) ... 
               0.5*exp(1i*1.2*pi)                   ];
% input echo
data_echo = real(conv(data,echo_vector));

% write audio with echo
audiowrite("audio_echo.wav", data_echo, Fs);

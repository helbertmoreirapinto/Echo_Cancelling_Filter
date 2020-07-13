%% clear
clc;
clear;


%% Read audio from file
[data, Fs] = audioread("audio.wav");

% play the audio
disp('playing audio');
sound(data,Fs);

%% Create audio recorder
% Frame sample
Fs = 44100;
nBits = 16;
% object
recObj = audiorecorder(Fs, nBits);

%% Record from microphone
t = 10; % audio time
disp('Start recording');
recordblocking(recObj, t);
disp('End of recording');

%% Play audio
play(recObj);

%% get audio data
data = getaudiodata(recObj);

% plot data
plot(data);

%% Write audio
audiowrite("audio_original.wav", data, Fs);

%% Add echo
% add echo with amplitude a=0.4 after 0.2s
a = 0.4;
N = 0.2*Fs;

data_echo(1:length(data)) = data(1:length(data));

for n = N+1:length(data)
    data_echo(n) = data(n) + a*data(n-N);
end

disp('Playing with echo');
sound(data_echo, Fs);

%% Remove echo
% add echo with amplitude a=0.1 after 0.15s
a = 0.3;
N = 0.2*Fs;

data_without_echo(1:length(data)) = data_echo(1:length(data));

for n = N+1:length(data_echo)
    data_without_echo(n) = data_echo(n) - a*data_echo(n-N);
end

disp('Playing without echo');
sound(data_without_echo, Fs);

%% Correlation

r = xcorr(data_without_echo, data);
plot(r);

%% Other way to add echo
% add an echo after 0.15s (with amplitude=0.1, phase=pi/3.5) and echo after 0.3 seconds (with a=0.5 and phase=1.2*pi)
% vector echo
echo_vector = [1                  zeros(1,0.15*Fs)     ... 
               0.1*exp(1i*pi/3.5) zeros(1,0.3*Fs) ... 
               0.5*exp(1i*1.2*pi)                   ];
% input echo
data_echo = real(conv(data,echo_vector));

sound(data_echo, Fs);

%% LMS filter

h = zeros(1, length(data));
step = 0.01;
eps = 0.001;
mu = 1;

not_echo(1:length(data)) = data_echo(1:length(data));

for i=1:length(data)
    e(i) = data(i) - h(i)' * data_echo(i);
    % NLMS
    mu = 1/(data_echo(i)'*data_echo(i) + eps);
    h(i+1) = h(i) + step * mu * e(i) * data_echo(i);
    not_echo(i) = h(i+1)'*data_echo(i);
end

%not_echo = h(length(data))*data_echo;
disp('Playing without echo');
sound(not_echo, Fs);

%% Plot error

plot(sqrt(erro_LMS.*erro_LMS));
title('Mean square error')

hold on;

plot(sqrt(erro_NLMS.*erro_NLMS));

hold off;
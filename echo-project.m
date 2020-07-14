%% clear
clc;
clear;


%% Read audio from file
[data, Fs] = audioread("audio_teste.ogg");

% play the audio
disp('playing audio');
sound(data,Fs);

%% Record audio
% Frame sample
Fs = 44100;
nBits = 16;
% object
recObj = audiorecorder(Fs, nBits, 1);

% Record from microphone
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
audiowrite("audio_original.ogg", data, Fs);

%% Add echo
% add echo with amplitude a=0.4 after 0.2s
a = 0.4;
N = 0.2*Fs;

data_echo = data;

for n = N+1:length(data)
    data_echo(n) = data(n) + a*data(n-N);
end

disp('Playing with echo');
sound(data_echo, Fs);

%% Remove echo
% remove echo with amplitude a=0.4 after 0.2s
a = 0.4;
N = 0.2*Fs;

data_without_echo = data_echo;

for n = N+1:length(data_echo)
    data_without_echo(n) = data_echo(n) - a*data_without_echo(n-N);
end

disp('Playing without echo');
sound(data_without_echo, Fs);

%% Plot data

t = [1:length(data)];

plot(t,data_echo,'r',t,data,'b');
title('Speech signals');
xlabel('Samples');
legend({'Echo','Original'},'Location','southwest')

%% Diff

diff = data_echo-data;
plot(diff);
title('Difference between audio and audio with echo');
xlabel('Samples');

%% Other way to add echo
% add an echo after 0.15s (with amplitude=0.1, phase=pi/3.5) and echo after 0.3 seconds (with a=0.5 and phase=1.2*pi)
% vector echo
echo_vector = [1                  zeros(1,0.15*Fs)     ... 
               0.1*exp(1i*pi/3.5) zeros(1,0.3*Fs) ... 
               0.5*exp(1i*1.2*pi)                   ];
% input echo
data_echo = real(conv(data,echo_vector));

sound(data_echo, Fs);

%% NLMS filter

h = zeros(1, length(data));
step = 0.02;
eps = 0.002;
mu = 1;

data_without_echo = data_echo;

for i=1:length(data)
    e(i) = data(i) - h(i)' * data_echo(i);
    %NLMS
    mu = 1/(data_echo(i)'*data_echo(i) + eps);
    h(i+1) = h(i) + step * mu * e(i) * data_echo(i);
    data_without_echo(i) = h(i+1)'*data_echo(i);
end

disp('Playing without echo');
sound(data_without_echo, Fs);

%% Plot error

t = [1:length(data)];
plot(t, sqrt(erro_LMS.*erro_LMS),t,sqrt(erro_NLMS.*erro_NLMS));
title('Mean square error');
xlabel('Samples');
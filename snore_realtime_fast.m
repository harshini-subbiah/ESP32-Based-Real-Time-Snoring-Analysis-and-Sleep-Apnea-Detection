function snore_realtime_fast(esp32_ip, port, fs, duration_sec)
 esp32_ip     = '192.168.1.14';
    port         = 12345;
    fs           = 16000;
    duration_sec = 30;
clc; close all;
disp('Optimized Option B: Fast Real-Time Streaming');

% Connect TCP
tcpObj = tcpclient(esp32_ip, port);
pause(1);
disp('Connected! Receiving audio...');

nSamples = fs * duration_sec;
samples = zeros(nSamples,1,'int16');
idx = 1;

tic;
while idx <= nSamples
    bytesAvailable = tcpObj.NumBytesAvailable;
    if bytesAvailable > 0
        raw = read(tcpObj, bytesAvailable, 'uint8');
        data = typecast(uint8(raw),'int16');
        data = data(:);
        endIdx = min(idx + length(data)-1, nSamples);
        samples(idx:endIdx) = data(1:(endIdx-idx+1));
        idx = endIdx + 1;
    end
end
elapsedTime = toc;
fprintf('Received %d samples in %.2f sec\n', idx-1, elapsedTime);

% Normalize
audio = double(samples)/double(intmax('int16'));
audio = audio - mean(audio);
audio = audio / max(abs(audio));

% Save WAV
audiowrite('snore_fast.wav', audio, fs);
disp('Saved snore_fast.wav');

% Analyze
snore_analysis(audio, fs);
end
%% ===============================================================
% === Snore Analysis Function (Full Pipeline) ===
% ===============================================================
function snore_analysis(audio, fs)
audio = audio(:);
t = (0:length(audio)-1)/fs;

% --- Bandpass Filter ---
bpFilt = designfilt('bandpassiir','FilterOrder',6, ...
         'HalfPowerFrequency1',80,'HalfPowerFrequency2',1000, ...
         'SampleRate',fs);
filteredAudio = filter(bpFilt, audio);

% --- Frame Analysis ---
frameLength = round(0.05*fs);
overlap = round(0.025*fs);
frameStep = frameLength - overlap;
numFrames = floor((length(filteredAudio)-frameLength)/frameStep);

energy = zeros(1,numFrames);
zcr = zeros(1,numFrames);

for i = 1:numFrames
    idx = (i-1)*frameStep+1 : (i-1)*frameStep+frameLength;
    frame = filteredAudio(idx);
    energy(i) = sum(frame.^2);
    zcr(i) = sum(abs(diff(sign(frame))))/(2*frameLength);
end

% --- Snore Event Detection ---
snoreFlags = energy>0.01 & zcr<0.1;
snoreEvents = bwlabel(snoreFlags);

% --- Spectrogram & Periodogram ---
figure;
subplot(2,1,1); pspectrum(filteredAudio, fs,'spectrogram'); title('Spectrogram');
subplot(2,1,2); periodogram(filteredAudio, [], [], fs,'power'); title('Periodogram');

% --- Detected Snore Visualization ---
figure; plot(t, filteredAudio); hold on;
for i=1:max(snoreEvents)
    frames=find(snoreEvents==i);
    x1=(frames(1)-1)*frameStep/fs;
    x2=(frames(end)-1)*frameStep/fs;
    patch([x1 x2 x2 x1],[-1 -1 1 1],'red','FaceAlpha',0.2,'EdgeColor','none');
end
title('Detected Snore Events'); xlabel('Time (s)'); ylabel('Amplitude');

% --- Feature Extraction ---
duration_in_hours = length(audio)/fs/3600;
numSnoreEvents = max(snoreEvents);
snoreIndex = numSnoreEvents/duration_in_hours;
fprintf('\nSnore Index: %.2f events/hour\n', snoreIndex);

dB_values=[]; durations=[]; peak_freqs=[];
for i=1:numSnoreEvents
    frames=find(snoreEvents==i);
    idx=(frames(1)-1)*frameStep+1 : (frames(end)-1)*frameStep+frameLength;
    seg=filteredAudio(idx);
    rms_val=sqrt(mean(seg.^2));
    dB_values(end+1)=20*log10(rms_val+eps);
    durations(end+1)=(frames(end)-frames(1))*frameStep/fs;
    N=length(seg); Y=abs(fft(seg)); f=(0:N-1)*(fs/N);
    [~,idx_peak]=max(Y(1:floor(N/2))); peak_freqs(end+1)=f(idx_peak);
end

fprintf('Average Intensity: %.2f dB\n', mean(dB_values));
fprintf('Average Duration: %.2f s\n', mean(durations));
fprintf('Average Peak Frequency: %.2f Hz\n', mean(peak_freqs));

% --- Severity Classification ---
avg_dB = mean(dB_values);
if avg_dB<48.6, severity='Normal or Mild';
elseif avg_dB<51.6, severity='Moderate';
else, severity='Severe'; end
fprintf('Severity Classification: %s\n', severity);

% --- Snoring Timeline ---
frameTimes=(0:length(snoreFlags)-1)*frameStep/fs;
figure; stem(frameTimes, snoreFlags,'filled'); ylim([-0.1,1.1]);
yticks([0 1]); yticklabels({'Silent','Snoring'}); xlabel('Time (s)'); ylabel('Detection');
title('Snoring Detection Over Time');

% --- Status Table ---
frameStatusTime=frameTimes(1:5:end)'; frameStatusText=strings(length(frameStatusTime),1);
for i=1:length(frameStatusTime)
    idx=(i-1)*5+1;
    if idx<=length(snoreFlags) && snoreFlags(idx), frameStatusText(i)="Snoring";
    else frameStatusText(i)="Silent"; end
end
StatusTable=table(frameStatusTime,frameStatusText,'VariableNames',{'Time_sec','Status'});
disp(StatusTable); writetable(StatusTable,'SnoreStatusLog.csv');

% --- Sleep Apnea Risk ---
fprintf('Sleep Apnea Risk: ');
if snoreIndex>=30 && avg_dB>=51.6, disp('Severe risk');
elseif snoreIndex>=15 && avg_dB>=48.6, disp('Moderate risk');
elseif snoreIndex>=5, disp('Mild risk'); else, disp('Low or no risk'); end

% --- Bandpass Filter Effect Visualization ---
figure; subplot(2,1,1);
plot(t,audio,'b'); hold on; plot(t,filteredAudio,'r'); grid on;
xlabel('Time (s)'); ylabel('Amplitude'); legend('Original','Filtered'); title('Bandpass Filtering');
nfft=2^nextpow2(length(audio)); f=fs/2*linspace(0,1,nfft/2+1);
A=fft(audio,nfft); F=fft(filteredAudio,nfft);
P1=20*log10(abs(A(1:nfft/2+1))); P2=20*log10(abs(F(1:nfft/2+1)));
subplot(2,1,2); plot(f/1000,P1,'b'); hold on; plot(f/1000,P2,'r');
xlabel('Frequency (kHz)'); ylabel('Power (dB)'); legend('Original','Filtered'); grid on; xlim([0 1]); ylim([-80 80]);

% --- FFT of Audio ---
N=length(audio); nfft=2^nextpow2(N); f=fs*(0:(nfft/2))/nfft;
Y=fft(audio,nfft); Y_mag=abs(Y/N); Y_mag=Y_mag(1:nfft/2+1); Y_dB=20*log10(Y_mag+eps);
figure; subplot(2,1,1); plot(f,Y_mag); grid on; xlabel('Hz'); ylabel('Magnitude'); title('FFT Linear');
subplot(2,1,2); plot(f,Y_dB); grid on; xlabel('Hz'); ylabel('Magnitude dB'); title('FFT Log Scale');

end

#  Real-Time Snoring Analysis and Sleep Apnea Detection using ESP32 and MATLAB

A real-time biomedical signal processing system that captures snoring audio using an ESP32 and an INMP441 MEMS microphone, streams the audio wirelessly to MATLAB over Wi-Fi, and performs Digital Signal Processing (DSP) techniques to detect snoring events and estimate the severity of sleep apnea.

---

## Features

- Real-time wireless audio streaming using ESP32
- TCP/IP communication between ESP32 and MATLAB
- Automatic WAV recording
- Bandpass filtering (80–1000 Hz)
- Short-Time Energy calculation
- Zero Crossing Rate (ZCR)
- FFT Analysis
- Spectrogram generation
- Periodogram generation
- Snore event detection
- Snore Index calculation
- Average intensity estimation
- Peak frequency extraction
- Snore duration calculation
- Sleep apnea severity classification
- Sleep apnea risk estimation
- Automatic CSV logging
- Multiple visualization graphs

---

# System Overview

<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/e41eb518-dd6a-4ae3-9627-9c2396d939d6" />


---

# Hardware

- ESP32 Development Board
- INMP441 MEMS Microphone
- USB Cable
- Wi-Fi Network
- Laptop running MATLAB

---

# Software

- MATLAB R2022a or newer
- Signal Processing Toolbox
- Arduino IDE
- ESP32 Board Package

---

# DSP Pipeline

1. Audio acquisition
2. TCP reception
3. Audio normalization
4. Bandpass filtering
5. Frame segmentation
6. Energy calculation
7. Zero Crossing Rate
8. Snore event detection
9. FFT
10. Spectrogram
11. Periodogram
12. Feature extraction
13. Severity classification
14. Sleep apnea risk estimation
15. CSV generation

---

# Output Parameters

The MATLAB program calculates

- Snore Index (events/hour)
- Average Intensity (dB)
- Average Snore Duration
- Average Peak Frequency
- Sleep Apnea Severity
- Sleep Apnea Risk

---

# Generated Outputs

The program automatically generates

- snore_fast.wav
- SnoreStatusLog.csv

Along with graphical outputs

- Spectrogram
- Periodogram
- FFT (Linear)
- FFT (Log Scale)
- Bandpass Filter Comparison
- Snore Event Detection
- Snoring Timeline
- Original vs Filtered Signal

---

# Sleep Apnea Severity

| Average Intensity | Classification |
|------------------|---------------|
| <48.6 dB | Normal / Mild |
| 48.6–51.6 dB | Moderate |
| >51.6 dB | Severe |

---

# Sleep Apnea Risk

Based on

- Snore Index
- Average Sound Intensity

Risk Levels

- Low
- Mild
- Moderate
- Severe

---

# Running the Project

## Step 1

Program the ESP32 using Arduino IDE.

## Step 2

Connect the ESP32 to the same Wi-Fi network as the PC.

## Step 3

Find the ESP32 IP address from the Serial Monitor.

Example

```
192.168.1.14
```

## Step 4

Open MATLAB.

## Step 5

Update the ESP32 IP inside

```
snore_realtime_fast.m
```

```matlab
esp32_ip='192.168.1.14';
```

## Step 6

Run

```matlab
snore_realtime_fast
```

or

```matlab
snore_realtime_fast('192.168.1.14',12345,16000,30)
```

## Step 7

The program automatically

- receives audio
- saves WAV
- performs DSP
- displays plots
- classifies snoring
- exports CSV

---

# MATLAB Toolboxes Required

- Signal Processing Toolbox
- Image Processing Toolbox (bwlabel)

---

---

# Authors

Harshini S

---
# Contributors

Subiksha

-----
# License

This project is licensed under the MIT License.

# Installation Guide

## 1 Install MATLAB

Install MATLAB with

- Signal Processing Toolbox
- Image Processing Toolbox

---

## 2 Install Arduino IDE

Install Arduino IDE.

---

## 3 Install ESP32 Board Package

Arduino IDE

Preferences

Additional Board URL

https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

Boards Manager

Install

ESP32 by Espressif Systems

---

## 4 Upload ESP32 Code

Open

ESP32_Audio_Streamer.ino

Select

Board

ESP32 Dev Module

Upload.

---

## 5 Connect Wi-Fi

Update

SSID

Password

inside ESP32 code.

---

## 6 Obtain IP Address

Open Serial Monitor.

Copy

```
192.168.x.x
```

---

## 7 Update MATLAB

Inside

snore_realtime_fast.m

Update

```matlab
esp32_ip='YOUR_IP';
```

---

## 8 Run MATLAB

```matlab
snore_realtime_fast
```

---

## Expected Outputs

snore_fast.wav

SnoreStatusLog.csv

Spectrogram

FFT

Bandpass Comparison

Snore Detection

Severity Classification

Sleep Apnea Risk

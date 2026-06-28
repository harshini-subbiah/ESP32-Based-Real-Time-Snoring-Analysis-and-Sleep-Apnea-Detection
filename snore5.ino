#include <WiFi.h>
#include "driver/i2s.h"

// ==== WiFi Settings ====
const char* ssid     = "Subiksha";
const char* password = "Subi1234";
WiFiServer server(12345);
WiFiClient client;

// ==== I2S Settings ====
#define SAMPLE_RATE    16000
#define I2S_WS         25
#define I2S_BCLK       26
#define I2S_DATA_IN    22
#define I2S_PORT       I2S_NUM_0
#define BUFFER_SAMPLES 512   // read 512 samples at a time

void setupI2S() {
  i2s_config_t i2s_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = SAMPLE_RATE,
    .bits_per_sample = I2S_BITS_PER_SAMPLE_32BIT,
    .channel_format = I2S_CHANNEL_FMT_ONLY_RIGHT,
    .communication_format = (i2s_comm_format_t)(I2S_COMM_FORMAT_I2S | I2S_COMM_FORMAT_I2S_MSB),
    .intr_alloc_flags = 0,
    .dma_buf_count = 4,
    .dma_buf_len = 256,
    .use_apll = false
  };
  i2s_pin_config_t pin_config = {
    .bck_io_num = I2S_BCLK,
    .ws_io_num = I2S_WS,
    .data_out_num = -1,
    .data_in_num = I2S_DATA_IN
  };
  i2s_driver_install(I2S_PORT, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_PORT, &pin_config);
  i2s_zero_dma_buffer(I2S_PORT);
}

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\nConnecting to WiFi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi connected!");
  Serial.print("📡 ESP32 IP: "); Serial.println(WiFi.localIP());

  setupI2S();
  server.begin();
  Serial.println("🎙️ I2S Microphone Initialized!");
  Serial.println("Waiting for client...");
}

void loop() {
  if (!client || !client.connected()) {
    client = server.available();
    if (client) {
      Serial.println("✅ Client connected!");
      client.setNoDelay(true);  // disable Nagle
    }
    return;
  }

  int32_t i2sData[BUFFER_SAMPLES];
  size_t bytesRead = 0;

  // Read BUFFER_SAMPLES from I2S
  i2s_read(I2S_PORT, (char*)i2sData, sizeof(i2sData), &bytesRead, portMAX_DELAY);
  int samplesRead = bytesRead / 4;

  // Convert 32-bit -> 16-bit and store in buffer
  int16_t sendBuffer[BUFFER_SAMPLES];
  for (int i = 0; i < samplesRead; i++) {
    sendBuffer[i] = (int16_t)(i2sData[i] >> 16);
  }

  // Send entire buffer at once
  client.write((uint8_t*)sendBuffer, samplesRead * 2);

  // Optional RMS/peak for debug every second
  static unsigned long lastPrint = 0;
  if (millis() - lastPrint > 1000) {
    double sumSq = 0; int16_t peak = 0;
    for (int i = 0; i < samplesRead; i++) {
      sumSq += sendBuffer[i] * sendBuffer[i];
      if (abs(sendBuffer[i]) > peak) peak = abs(sendBuffer[i]);
    }
    double rms = sqrt(sumSq / samplesRead) / 32768.0;
    Serial.printf("🎧 RMS: %.4f | Peak: %d\n", rms, peak);
    lastPrint = millis();
  }

  if (!client.connected()) { client.stop(); Serial.println("❌ Client disconnected!"); }
}

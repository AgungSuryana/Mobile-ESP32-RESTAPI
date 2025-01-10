#include <WiFi.h>
#include <HTTPClient.h>

const char* ssid = "Nama_WiFi"; 
const char* password = "Password_WiFi";

const char* backend_url = "https://restapi-js.vercel.app/api"; //ganti sesuai dengan url backend masing masing

const int gasSensorPin = 34; 

void setup() {
  Serial.begin(115200);
  
  Serial.print("Menghubungkan ke WiFi");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi terhubung!");
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(backend_url);
    http.addHeader("Content-Type", "application/json"); 
    int gasLevel = analogRead(gasSensorPin);
    String timestamp = getTimeStamp();

    String payload = "{\"gasLevel\":" + String(gasLevel) + ",\"timestamp\":\"" + timestamp + "\"}";
    int httpResponseCode = http.POST(payload);
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println("Data berhasil dikirim!");
      Serial.println("Response: " + response);
    } else {
      Serial.print("Error: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("WiFi tidak terhubung!");
  }

  delay(5000);
}

String getTimeStamp() {
  time_t now = time(nullptr);
  struct tm* p_tm = localtime(&now);
  char timestamp[25];
  snprintf(timestamp, sizeof(timestamp), "%04d-%02d-%02dT%02d:%02d:%02d",
           p_tm->tm_year + 1900,
           p_tm->tm_mon + 1,
           p_tm->tm_mday,
           p_tm->tm_hour,
           p_tm->tm_min,
           p_tm->tm_sec);
  return String(timestamp);
}

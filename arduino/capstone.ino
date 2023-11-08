#include <WiFi.h>
// #include <ESP8266WiFi.h>

// Username and password to connect to microcontroller:
const char* ssid = "Samsung Galaxy S10e_7644";
const char* password = "ogjx6739";

// Fixes server parameters:
WiFiServer server(5000); // fixes port of server to 5000
// IPAddress LOCAL_IP(192, 168, 1, 184); // fix server's local IP
// IPAddress GATEWAY(192, 168, 1, 1); // fix server's gateway IP
// IPAddress SUBNET(255, 255, 0, 0);

String header; // stores HTTP request
const int OUTPIN = 22; // digital output pin

// Current time
// unsigned long currentTime = millis();
// Previous time
// unsigned long previousTime = 0; 
// Define timeout time in milliseconds (example: 2000ms = 2s)
// const long timeoutTime = 2000;

void setup() {
  Serial.begin(115200);
  pinMode(OUTPIN, OUTPUT);
  analogWrite(OUTPIN, 0);

  // Connect to Wi-Fi with SSID and password:
  Serial.print("Connecting to ");
  Serial.print(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected.");
  
  // Configures static IP address:
  // if (!WiFi.config(LOCAL_IP, GATEWAY, SUBNET)) {
    // Serial.println("STA Failed to configure");
  // }
  
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  server.begin();
}

void loop() {
  WiFiClient client = server.available();
  if (client) {    
    Serial.println("New client!");
    // if (client.read() == '1') {
      // analogWrite(OUTPIN, 1023);
      // Serial.println("high");
    // } else {
      // analogWrite(OUTPIN, 100);
      // Serial.println("low");
    // }
    Serial.println(client.read());                      
  }
}

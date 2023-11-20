#include <WiFi.h>

// Username and password to connect to microcontroller:
const char* ssid = "Samsung Galaxy S10e_7644";
const char* password = "ogjx6739";

// Fixes server parameters:
WiFiServer server(80); // fixes port of server to 5000
// IPAddress LOCAL_IP(192, 168, 1, 184); // fix server's local IP
// IPAddress GATEWAY(192, 168, 1, 1); // fix server's gateway IP
// IPAddress SUBNET(255, 255, 0, 0);

String header; // stores HTTP request
const int MOTOR_CONTROL_PIN = 14; // analog pin to control the motor
const int MOTOR_POWER_HIGH = 26;
const int MOTOR_POWER_LOW = 27;
const int MAX_CLIENT_COUNT = 4;
WiFiClient clientList[MAX_CLIENT_COUNT]; // list of currently connected clients, 
// up to 4 allowed
int clientCount = 0;
// !!! VTBI, dosage, current channel, and current drug should all be variables stored here:

void setup() {
  Serial.begin(115200);
  pinMode(MOTOR_CONTROL_PIN, OUTPUT);
  analogWrite(MOTOR_CONTROL_PIN, 0);
  pinMode(MOTOR_POWER_HIGH, OUTPUT);
  pinMode(MOTOR_POWER_LOW, OUTPUT);
  digitalWrite(MOTOR_POWER_HIGH, LOW);
  digitalWrite(MOTOR_POWER_LOW, LOW);
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
  WiFiClient client;
  if ((client = server.available()) && (clientCount < MAX_CLIENT_COUNT)) {
//    bool clientAlrConnected = false;
//    int index = 0;
//    while ((!clientAlrConnected) && (index < clientCount)) {
//      clientAlrConnected = client.remoteIP() == clientList[index].remoteIP();
//    }
//    if (!clientAlrConnected) {
      clientList[clientCount] = client;
      clientCount++;
      Serial.print("New client at IP ");
      Serial.println(client.remoteIP());
      Serial.print("Current number of clients: ");
      Serial.println(clientCount);
//    }
  } else {
    for (int index = 0; index < clientCount; index++) {
      client = clientList[index];
      if (client.connected()) {
        String recvBuffer = "";
        while (client.available()) {
          recvBuffer += (char) client.read();
        }
        if (recvBuffer != "") {
          int valueToWrite = recvBuffer.toInt();
          Serial.print(client.remoteIP());
          Serial.print(": ");
          Serial.println(valueToWrite);

          // valueToWrite: value of the analog pin used to control the pump
          // MOTOR CONTROL CODE HERE:
          setMotorAnalogValue(valueToWrite);
          // END CODE
        }
      } else {
        Serial.print("Disconnected client at IP ");
        Serial.println(client.remoteIP());
        clientList[index] = NULL;
        for (int secondIndex = index + 1; secondIndex < clientCount; secondIndex++) {
          clientList[secondIndex - 1] = clientList[secondIndex];
        }
        clientCount--;
      }
    }
  }
  delay(100);
}

void setMotorAnalogValue(int analogPinValue) {
  if (analogPinValue == 0) {
     digitalWrite(MOTOR_POWER_HIGH, LOW);
     digitalWrite(MOTOR_POWER_LOW, LOW);
  } else {
    digitalWrite(MOTOR_POWER_HIGH, HIGH);
    digitalWrite(MOTOR_POWER_LOW, LOW);
    analogWrite(MOTOR_CONTROL_PIN, analogPinValue);
  } 
}

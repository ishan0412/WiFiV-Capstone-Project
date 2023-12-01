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
// char* bufferToSend; // all messages to send are stored here
const int MOTOR_CONTROL_PIN = 14; // analog pin to control the motor
const int MOTOR_POWER_HIGH = 26;
const int MOTOR_POWER_LOW = 27;
const int MAX_CLIENT_COUNT = 4;
WiFiClient clientList[MAX_CLIENT_COUNT]; // list of currently connected clients, 
// up to 4 allowed
int clientCount = 0;
// !!! VTBI, dosage, current channel, and current drug should all be variables stored here:
// int thisPumpId = -1; // lower 8 bits of IP address; if the pump didn't connect to wifi, this'll stay -1

// CHANGE THESE FOR EACH PUMP:
int thisPumpId = 4;  // unique to each pump
String drugName = "VASOPRESSIN";
////////////////////////////

// Pump local variables:
double currentRate = 0;
double currentVtbi = 0;
double systolicPressure = 70;
double diastolicPressure = 40;
double meanArterialPressure = 50;

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

  IPAddress thisPumpIp = WiFi.localIP();
  Serial.print("IP address: ");
  Serial.println(thisPumpIp);
//  thisPumpId = thisPumpIp[3];
//  Serial.print("This pump's ID: ");
  Serial.println(thisPumpId);
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
      sendDataAsJson(client);
      Serial.println("Sent data to new client.");
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
          // int valueToWrite = recvBuffer.toInt();
          char targetSetting = recvBuffer.charAt(recvBuffer.length() - 1);
          double valueToWrite = recvBuffer.substring(0, recvBuffer.length() - 1).toDouble();
          Serial.print(client.remoteIP());
          if (targetSetting == 'r') {
            Serial.print(" RATE: ");
            currentRate = valueToWrite;
            double pressureIncrease = 0.133 * currentRate;
            systolicPressure += pressureIncrease;
            diastolicPressure += pressureIncrease;
            meanArterialPressure += pressureIncrease;
            Serial.print("MAP: ");
            Serial.println(meanArterialPressure);
            // valueToWrite: value of the analog pin used to control the pump
            // MOTOR CONTROL CODE HERE:
            setMotorAnalogValue(valueToWrite);
            // END CODE
          } else {
            Serial.print(" VTBI: ");
            currentVtbi = valueToWrite;
          }
          // TODO: implement handling for rate vs vtbi inputs:
          Serial.println(valueToWrite);
          broadcastDataUpdateBy(client, targetSetting);
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
  // put dosage-to-voltage conversion here:

  // END CODE
  
  if (analogPinValue == 0) {
     digitalWrite(MOTOR_POWER_HIGH, LOW);
     digitalWrite(MOTOR_POWER_LOW, LOW);
  } else {
    digitalWrite(MOTOR_POWER_HIGH, HIGH);
    digitalWrite(MOTOR_POWER_LOW, LOW);
    analogWrite(MOTOR_CONTROL_PIN, analogPinValue);
  } 
}

// TODO: support for updating rate AND vtbi (additional type
// "rate" | "vtbi" parameter in following method)
void broadcastDataUpdateBy(WiFiClient updatingClient, char targetSetting) {
  for (int index = 0; index < clientCount; index++) {
    WiFiClient currClient = clientList[index];
     // if (currClient.remoteIP() != updatingClient.remoteIP()) {
      currClient.write((String(thisPumpId) + " " 
      + String((targetSetting == 'r') ? currentRate : currentVtbi) 
      + " " + String(systolicPressure) + 
      + " " + String(diastolicPressure) +
      + " " + String(meanArterialPressure)
      + " " + targetSetting).c_str());
     // }
    // Serial.println("Broadcasted data update.");
  }
}

void sendDataAsJson(WiFiClient client) {
  String dataToSend = "{\"id\": " + String(thisPumpId) 
  + ", \"ipAddress\": \"" + WiFi.localIP().toString() 
  + "\", \"drugName\": \"" + drugName 
  + "\", \"patientName\": \"" + "" 
  + "\", \"currentRate\": " + String(currentRate) 
  + ", \"currentVtbi\": " + String(currentVtbi) + "}" + "#" + String(systolicPressure) 
      + " " + String(diastolicPressure) 
      + " " + String(meanArterialPressure) + "}";
  client.write(dataToSend.c_str());
}

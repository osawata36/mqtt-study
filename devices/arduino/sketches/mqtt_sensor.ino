#include <WiFi.h>
#include <PubSubClient.h>
#include "config.h"

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  Serial.begin(115200);
  setup_wifi();
  client.setServer(MQTT_SERVER, MQTT_PORT);
}

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(WIFI_SSID);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect(DEVICE_ID)) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // Sensor data publishing example
  float temperature = 25.0; // Replace with actual sensor reading
  String payload = "{\"temperature\":" + String(temperature) + ",\"device_id\":\"" + DEVICE_ID + "\"}";
  
  client.publish(MQTT_TOPIC, payload.c_str());
  delay(30000); // Send every 30 seconds
}
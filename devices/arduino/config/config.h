#ifndef CONFIG_H
#define CONFIG_H

// WiFi Configuration
const char* WIFI_SSID = "your_wifi_ssid";
const char* WIFI_PASSWORD = "your_wifi_password";

// MQTT Configuration
const char* MQTT_SERVER = "your_mqtt_broker.com";
const int MQTT_PORT = 1883;
const char* DEVICE_ID = "arduino_sensor_01";
const char* MQTT_TOPIC = "sensors/temperature";

#endif
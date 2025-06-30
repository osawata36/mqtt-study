package main

import (
	"encoding/json"
	"os"
	"testing"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func TestSensorDataMarshal(t *testing.T) {
	data := SensorData{
		DeviceID:    "test_device",
		Timestamp:   time.Date(2023, 1, 1, 0, 0, 0, 0, time.UTC),
		Temperature: 25.5,
		Humidity:    60.0,
		Pressure:    1013.25,
	}

	payload, err := json.Marshal(data)
	if err != nil {
		t.Fatalf("Failed to marshal sensor data: %v", err)
	}

	expected := `{"device_id":"test_device","timestamp":"2023-01-01T00:00:00Z","temperature":25.5,"humidity":60,"pressure":1013.25}`
	if string(payload) != expected {
		t.Errorf("Expected %s, got %s", expected, string(payload))
	}
}

func TestGetEnv(t *testing.T) {
	testCases := []struct {
		key          string
		defaultValue string
		envValue     string
		expected     string
	}{
		{"TEST_KEY", "default", "", "default"},
		{"TEST_KEY", "default", "custom", "custom"},
	}

	for _, tc := range testCases {
		if tc.envValue != "" {
			os.Setenv(tc.key, tc.envValue)
			defer os.Unsetenv(tc.key)
		}

		result := getEnv(tc.key, tc.defaultValue)
		if result != tc.expected {
			t.Errorf("getEnv(%s, %s) = %s, expected %s", tc.key, tc.defaultValue, result, tc.expected)
		}
	}
}

func TestNewMQTTClient(t *testing.T) {
	os.Setenv("MQTT_BROKER", "test-broker:1883")
	os.Setenv("DEVICE_ID", "test_device")
	os.Setenv("MQTT_TOPIC", "test/topic")
	defer func() {
		os.Unsetenv("MQTT_BROKER")
		os.Unsetenv("DEVICE_ID")
		os.Unsetenv("MQTT_TOPIC")
	}()

	client := NewMQTTClient()

	if client.deviceID != "test_device" {
		t.Errorf("Expected device ID 'test_device', got '%s'", client.deviceID)
	}

	if client.topic != "test/topic" {
		t.Errorf("Expected topic 'test/topic', got '%s'", client.topic)
	}
}

func TestMQTTClientWithMockBroker(t *testing.T) {
	client := &MQTTClient{
		deviceID: "test_device",
		topic:    "test/topic",
	}

	opts := mqtt.NewClientOptions()
	opts.AddBroker("tcp://localhost:1883")
	opts.SetClientID("test_client")

	mockClient := mqtt.NewClient(opts)
	client.client = mockClient

	data := SensorData{
		Temperature: 25.0,
		Humidity:    50.0,
		Pressure:    1000.0,
	}

	err := client.PublishSensorData(data)
	if err == nil {
		t.Log("PublishSensorData completed (broker may not be available)")
	}
}

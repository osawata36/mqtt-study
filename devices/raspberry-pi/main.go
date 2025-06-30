package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type SensorData struct {
	DeviceID    string    `json:"device_id"`
	Timestamp   time.Time `json:"timestamp"`
	Temperature float64   `json:"temperature"`
	Humidity    float64   `json:"humidity"`
	Pressure    float64   `json:"pressure"`
}

type MQTTClient struct {
	client   mqtt.Client
	deviceID string
	topic    string
}

func NewMQTTClient() *MQTTClient {
	broker := getEnv("MQTT_BROKER", "localhost:1883")
	deviceID := getEnv("DEVICE_ID", "raspberry_pi_01")
	topic := getEnv("MQTT_TOPIC", "sensors/data")

	opts := mqtt.NewClientOptions()
	opts.AddBroker(fmt.Sprintf("tcp://%s", broker))
	opts.SetClientID(deviceID)
	opts.SetDefaultPublishHandler(messagePubHandler)
	opts.OnConnect = connectHandler
	opts.OnConnectionLost = connectLostHandler

	client := mqtt.NewClient(opts)

	return &MQTTClient{
		client:   client,
		deviceID: deviceID,
		topic:    topic,
	}
}

func (m *MQTTClient) Connect() error {
	if token := m.client.Connect(); token.Wait() && token.Error() != nil {
		return token.Error()
	}
	return nil
}

func (m *MQTTClient) PublishSensorData(data SensorData) error {
	data.DeviceID = m.deviceID
	data.Timestamp = time.Now()

	payload, err := json.Marshal(data)
	if err != nil {
		return err
	}

	token := m.client.Publish(m.topic, 0, false, payload)
	token.Wait()

	log.Printf("Published: %s", payload)
	return token.Error()
}

func (m *MQTTClient) Disconnect() {
	m.client.Disconnect(250)
}

var messagePubHandler mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
	log.Printf("Received message: %s from topic: %s", msg.Payload(), msg.Topic())
}

var connectHandler mqtt.OnConnectHandler = func(client mqtt.Client) {
	log.Println("Connected to MQTT broker")
}

var connectLostHandler mqtt.ConnectionLostHandler = func(client mqtt.Client, err error) {
	log.Printf("Connection lost: %v", err)
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func main() {
	client := NewMQTTClient()

	if err := client.Connect(); err != nil {
		log.Fatal("Failed to connect to MQTT broker:", err)
	}
	defer client.Disconnect()

	log.Println("MQTT client started")

	for {
		sensorData := SensorData{
			Temperature: 22.5,
			Humidity:    60.0,
			Pressure:    1013.25,
		}

		if err := client.PublishSensorData(sensorData); err != nil {
			log.Printf("Failed to publish data: %v", err)
		}

		time.Sleep(30 * time.Second)
	}
}

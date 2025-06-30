# MQTT IoT System Study

IoTデバイス（Arduino・Raspberry Pi）とAWSを使ったMQTTシステムのサンプル実装

## 構成

```
mqtt-study/
├── devices/                    # IoTデバイス側コード
│   ├── raspberry-pi/          # Raspberry Pi用（Go）
│   ├── arduino/               # Arduino用（C++）
│   └── shared/                # デバイス共通仕様
├── cloud/                     # クラウド側アプリケーション
│   ├── data-processor/        # Lambda関数（データ処理）
│   ├── api/                   # REST API
│   └── dashboard/             # 監視ダッシュボード
├── infrastructure/            # AWS IaC（Terraform）
├── packages/                  # 共通ライブラリ
└── tools/                     # 開発・運用ツール
```

## 技術スタック

- **IoTデバイス**: Go（Raspberry Pi）、C++（Arduino）
- **クラウド**: AWS IoT Core、Lambda、DynamoDB
- **インフラ**: Terraform
- **プロトコル**: MQTT

## 開発環境セットアップ

### Arduino
- Arduino IDE または PlatformIO
- 必要ライブラリ：PubSubClient、WiFi

### Raspberry Pi
```bash
cd devices/raspberry-pi
go mod tidy
go run main.go
```

### 環境変数
```bash
export MQTT_BROKER="your-broker-address"
export DEVICE_ID="your-device-id"
export MQTT_TOPIC="sensors/data"
```
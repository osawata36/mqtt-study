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

### 初回セットアップ
```bash
# 開発環境を自動セットアップ
./scripts/setup-dev.sh
```

### Arduino
- Arduino IDE または PlatformIO
- 必要ライブラリ：PubSubClient、WiFi
- 設定ファイル：`devices/arduino/config/config.h`

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

## 開発ワークフロー

### ローカルでのCI実行
```bash
# プッシュ前にCIと同等のチェックを実行
./scripts/ci-local.sh
```

### 利用可能なスクリプト
```bash
./scripts/test.sh           # テスト実行
./scripts/test-coverage.sh  # カバレッジ付きテスト
./scripts/build.sh          # ビルド
./scripts/ci-local.sh       # 完全なCIチェック
./scripts/pre-commit.sh     # コミット前チェック
./scripts/setup-dev.sh      # 開発環境セットアップ
```

### Pre-commitフック
```bash
# 自動でフォーマット・テストを実行
cp scripts/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### CIチェック項目
- **フォーマット**: `go fmt`
- **静的解析**: `go vet`, `golangci-lint`
- **テスト**: 単体テスト + race detection
- **カバレッジ**: コードカバレッジ計測
- **ビルド**: バイナリ生成確認
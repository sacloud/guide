# プロファイル機能

さくらのクラウドのツール群で利用するプロファイル機能について説明します。プロファイルはusacloud(skr:次世代CLI)/terraform-provider-sakura/SDK等で設定を共有するのに利用されるため、プロファイルを処理する実装が必須でサポートするべき共通部分とツール固有の部分でわけて定義されています。

本ドキュメントではプロファイルv1に関して記述しています。v0に関しては[usacloudのドキュメント](https://docs.usacloud.jp/usacloud/references/profile/)を参照してください。

:warning: 注意点として、現状プロファイルv1をサポートしているツール群は少なく、sacloud-sdk-goへの移行や関連コードの更新等時間を要するので、既存ライブラリや古いバージョンのツールとやりとりする時はv0を利用してください。

## ディレクトリ・パス構造

プロファイルは `$HOME/.sakura/<profila-name>/config.yaml` に配置されます。例えば `skr config create example` で生成した場合は `$HOME/.sakura/example/config.yaml` となります。プロファイルのデフォルト名は `default` です。

### 現在のプロファイルの指定方法

複数プロファイルが存在している場合、 `.sakura/current` ファイルで現在のプロファイル名を指定します。例えば現在指しているプロファイルが `example` の場合には以下のようになります。

```
% cat .sakura/current
example
```

### 保存先ディレクトリ

プロファイルの保存先はデフォルトではホームディレクトリとなりますが、この値は環境変数経由で変更可能です。 優先度としては以下のようになります。

1. `SAKURA_PROFILE_DIR` 環境変数
2. `XDG_CONFIG_HOME` 環境変数
3. ホームディレクトリ

`SAKURA_PROFILE_DIR=/path/to/SAKURA` のような環境変数が設定されていた場合、プロファイルの保存先は `/path/to/SAKURA/.sakura/default/config.yaml` となります。

### 互換性

プロファイルの保存先のパスは `.sakura` となりますが、v0環境で利用している `.usacloud` もサポートします。

## プロファイルの内容

プロファイルv1の中身はYAMLとなっており、各ツール共通となる認証情報・エンドポイント情報やSDK・ツールの設定を行う情報とに分かれています。以下が例となります。

```yaml
version: 1
credentials:
  # アクセスキーベースの認証情報
  access_token: <your-access-token>
  access_token_secret: <your-access-token-secret>
endpoints:
  iam: http://localhost:18087
  # other endpoints
cli:
  argument_match_mode: exact
  # other parameters
go:
  api_root_url: https://secure.sakura.ad.jp/cloud/zone
  # other parameters
```

### 各パラメータの型と説明

`credentials` / `endpoints`セクションはAPIを扱う全てのツールがサポートすべきセクションとなります。

#### credentialsセクション

さくらのクラウドで扱う認証情報を設定する。アクセスキーベースとサービスプリンシパルキーベースの2つをサポートし、どちらも指定されている場合にはサービスプリンシパルキーの方を優先します。

```yaml
credentials:
  # アクセスキーベースの認証情報
  access_token: <your-access-token>
  access_token_secret: <your-access-token-secret>
  # サービスプリンシパルキーベースの認証情報
  service_principal_id: <your-service-principal-id>
  service_principal_key_kid: <your-service-principal-kid>
  private_key: '-----BEGIN RSA PRIVATE KEY-----...'
  private_key_path: /path/to/key
```

| パラメータ名 | 旧パラメータ名 | 型 | 内容 |
| --- | --- | --- | --- |
| access_token | AccessToken | string | アクセスキー方式のアクセストークン |
| access_token_secret | AccessTokenSecret | string | アクセスキー方式のシークレット |
| service_principal_id | ServicePrincipalID | string | サービスプリンシパルID |
| service_principal_key_kid | ServicePrincipalKeyKID | string | サービスプリンシパルキーのKID |
| private_key | PrivateKey | string | サービスプリンシパル秘密鍵(PEM) |
| private_key_path | PrivateKeyPEMPath | string | サービスプリンシパル秘密鍵(PEM)のファイルパス |

`private_key`/`private_key_path`の両方が指定されていた場合には`private_key`が優先されます。

#### endpointsセクション

sakumockやテスト環境など、実環境以外のAPIを利用する時に設定します。

```yaml
endpoints:
  iam: http://localhost:18087
  # other endpoints
```

| パラメータ名 | 型 | 内容 |
| --- | --- | --- |
| addon | string | Addon APIのエンドポイントURL |
| apigw | string | API Gateway APIのエンドポイントURL |
| apprun_shared | string | AppRun Shared APIのエンドポイントURL |
| apprun_dedicated | string | AppRun Dedicated APIのエンドポイントURL |
| cloudhsm | string | CloudHSM APIのエンドポイントURL |
| dedicated_storage | string | Dedicated Storage APIのエンドポイントURL |
| eventbus | string | EventBus APIのエンドポイントURL |
| iam | string | IAM APIのエンドポイントURL |
| kms | string | KMS APIのエンドポイントURL |
| monitoring_suite | string | Monitoring Suite APIのエンドポイントURL |
| nosql | string | NoSQL APIのエンドポイントURL |
| object_storage | string | Object Storage APIのエンドポイントURL |
| secretmanager | string | SecretManager APIのエンドポイントURL |
| security_control | string | Security Control APIのエンドポイントURL |
| simple_notification | string | Simple Notification APIのエンドポイントURL |
| simple_mq_queue | string | Simple MQ Queue APIのエンドポイントURL |
| simple_mq_message | string | Simple MQ Message APIのエンドポイントURL |
| webaccel | string | WebAccel APIのエンドポイントURL |
| workflows | string | Workflows APIのエンドポイントURL |

新規サービスが増えるたびに追加されます。

#### 各ツール向けセクション

- CLI

`skr`/`usacloud`向けパラメータ。

```yaml
cli:
  argument_match_mode: exact
  default_output_type: table
  default_query_driver: jq
  no_color: false
  process_timeout_sec: 7200
```

| パラメータ名 | 旧パラメータ名 | 型 | 内容 |
| --- | --- | --- | --- |
| argument_match_mode | ArgumentMatchMode | string | 操作対象リソースを引数で指定するコマンドでのリソース名と引数の比較方法(partial(部分一致)/exact(完全一致)) |
| default_output_type | DefaultOutputType | string | 既定の出力形式(table/json/yaml) |
| default_query_driver | DefaultQueryDriver | string | 各コマンドの--queryを処理するデフォルトのドライバ(jmespath/jq) |
| no_color | NoColor | bool | ANSIエスケープシーケンスによる色つけを無効化 |
| process_timeout_sec | ProcessTimeoutSec | int | コマンド全体の実行タイムアウトまでの秒数 |

- Go

さくらのツール群はGoで書かれているものが多く、terraform/CLI/SDKは `sacloud-sdk-go/common/saclient` に依存しているため、saclient向けの設定は `go` セクションで設定します。

```yaml
# terraform/CLI/Go SDKで利用する
go:
  api_root_url: https://secure.sakura.ad.jp/cloud/zone
  accept_language: en-US,en;q=0.9
  default_zone: is1a
  fake_mode: false
  fake_store_path: ~/.usacloud/fake_store.json
  http_request_rate_limit: 5
  http_request_timeout: 300
  retry_max: 0
  retry_wait_max: 64
  retry_wait_min: 1
  state_polling_interval: 0
  state_polling_timeout: 0
  trace_mode: HTTP
  zone: is1a
  zones:
    - is1a
    - is1b
    - tk1a
    - tk1b
    - tk1v
```

| パラメータ名 | 旧パラメータ名 | 型 | 内容 |
| --- | --- | --- | --- |
| api_root_url | APIRootURL | string | さくらのクラウドAPIのルートURL |
| accept_language | AcceptLanguage | string | APIリクエスト時のAccept-Language |
| default_zone | DefaultZone | string | グローバルリソースAPIを呼ぶ際に指定するゾーン |
| fake_mode | FakeMode | bool | フェイクモード有効化フラグ |
| fake_store_path | FakeStorePath | string | フェイクストアの保存先パス |
| http_request_rate_limit | HTTPRequestRateLimit | int | APIリクエストのレート上限 |
| http_request_timeout | HTTPRequestTimeout | int | HTTPリクエストのタイムアウト秒 |
| retry_max | RetryMax | int | 423/503を受け取った時のリトライ最大回数 |
| retry_wait_max | RetryWaitMax | int | 423/503を受け取った時のリトライ待機の最大秒数 |
| retry_wait_min | RetryWaitMin | int | 423/503を受け取った時のリトライ待機の最小秒数 |
| state_polling_interval | StatePollingInterval | int | 状態監視ポーリング間隔 |
| state_polling_timeout | StatePollingTimeout | int | 状態監視のタイムアウト |
| trace_mode | TraceMode | string | トレース出力モード |
| zone | Zone | string | 操作対象ゾーン |
| zones | Zones | array of string | 利用可能ゾーン一覧 |

- Java / .NET / etc...

他の言語で実装されているSDK等に対しては、Goと同じくそれぞれの言語のセクションにパラメータを書きます(Javaであれば`java`、.NETであれば`dotnet`等)。これらはその言語以外では無視されます。

```yaml
java:
  # ...
dotnet:
  # ...
```

| パラメータ名 | 型 | 内容 |
| --- | --- | --- |
| foobar | string | (各実装依存) |

### パラメータの省略と優先度

プロファイル内のパラメータは省略可能です。これらの値が省略された場合には、プロファイルを利用するツールのデフォルト値が使用されます。

terraform等のツールではプロファイルより優先度の高い指定方法が存在しており、プロファイルで指定した値が無視されるケースもあります。例えばterraformにおけるパラメータ指定の優先度は以下の通りです。

1. tfファイル
2. 環境変数
3. プロファイル
4. terraformプロバイダのデフォルト

## 設定サンプル

同等の設定をv1/v0で書いたファイルを同梱しているので参考にしてください。

- v1: [v1.yaml](v1.yaml)
- v0: [v0.json](v0.json)

v0フォーマットではjava等の多言語向けのセクションをサポートしていないので、それらはv0.jsonには存在していません。
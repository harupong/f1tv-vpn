## f1tv用のVPNを共有するためのツール
2023年に商用VPNをF1TVがバンした。TailscaleでVPNを作って共有することにしたのでメモ。

## exit nodeの使い分け
1. f1tv-main#-[location]
   - メインのexit node。安定性を重視してAWS Lightsailインスタンスを24/7運用。
2. f1tv-reserve-[purpose]
   - 予備のexit node。RacknerdとEthernet ServersのVPSを24/7運用。

### 2023/09時点での構成
1. f1tv-main0-portland
   - メイン）AWS us-west-2リージョンで稼働中。US西海岸はアジアの次にレイテンシーが低い。アジアリージョンはトラフィック料が高いので避ける。
2. f1tv-reserve-streaming
   - 予備）RacknerdのシアトルDCで稼働中。IPアドレスがdirty IP認定されているため、F1TVへログインできなかったり、NetflixのWebサイトが開かなかったりする。F1TVのストリーミングは問題なく動作する。
3. f1tv-reserve-login
   - 予備）Ethernet ServersのロサンゼルスDCで稼働中。ログインは問題なくできるが、Geolocation判定が安定せず、ストリーミング不可になったりF1TV accessのコンテンツのみ表示されたりする。

## AWS Lightsailの手順
TerraformでLightsailのインスタンス作成と、Tailscaleのインストールを自動化する。

1. `terraform/env/[region]`ディレクトリに移動する
2. `terraform apply`を実行する（インスタンスを削除する場合は`terraform destroy`）

### Lightsailのリージョンを追加する手順
```
cd terraform/env/
mkdir [region-name] && cd [region-name]
cp ../us-west-2/* .
mv terraform.tfvars.example terraform.tfvars
vi backend.tf terraform.tfvars
```

設定ファイルが2つ開くので、リージョンにあわせてパラメーターを編集する。

- backend.tf -> S3のバケット名とリージョン
- terraform.tfvars -> 全項目

また、そのために、以下のような作業が必要になる。

- 対象のリージョンに、S3のバケットを作る 命名規則 terraform-f1tv-vpn-[リージョン名]
- デフォルトのSSHキーをローカルにダウンロードしておく

## Racknerd/Ethernet Serversの手順
AnsibleでTailscaleの導入を自動化する。インスタンス作成は手動でおこなう。

1. 起動したインスタンスのIPアドレスを `hosts` に追記する。
2. `ansible-playbook -i hosts playbook.yml`を実行してtailscaleを導入する。
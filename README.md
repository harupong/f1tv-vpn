# f1tv用のVPNを共有するためのツール

2023年に商用VPNをF1TVがバンした。TailscaleでVPNを作って共有することにしたのでメモ。

## VPNノードのデプロイ方法

1. ノード作成方法はプロバイダーによる。VPS屋さんは個別、AWSなどはTerraformでやる。
2. ノードの初期設定方法はAnsibleで自動実行

### 【共通】ノード作成後の初期設定をAnsibleで自動実行

``` shell
cd ansible
vi inventory.yml # ノードのIPアドレスを追記/編集
ansible-playbook -i inventory.yml playbook/deploy_nodes.yml # ノードを特定するには -l <hostname> 
```

### AWS Lightsail/Oracle Cloud Infrastructureでのノード作成手順

TerraformでLightsailのインスタンス作成を自動化する。

1. `terraform/env/[region]`ディレクトリに移動する
2. `terraform apply`を実行する（インスタンスを削除する場合は`terraform destroy`）

#### AWS Lightsailのリージョンを追加する手順

``` shell
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

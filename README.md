## f1tv用のVPNを共有するためのツール
2023年に商用VPNをF1TVがバンした。TailscaleでVPNを作って共有することにしたのでメモ。

## exit nodeの使い分け
1. f1tv-main-seattle
   - メインのexit node。Racknerdの768MB/1TBインスタンスを年単位で契約。24/7運用。
2. f1tv-race-portland
   - レース週末のみ稼働するexit node。AWS LightsailのNanoインスタンスをレース週末のみ起動する。レース週末以外は削除する。

## AWS Lightsailの手順
TerraformでLightsailのインスタンス作成と、Tailscaleのインストールを自動化する。

## Racknerdの手順
AnsibleでTailscaleの導入を自動化する。インスタンス作成は手動でおこなう。

1. 起動したインスタンスのIPアドレスを `hosts` に追記する。
4. `ansible-playbook -i hosts playbook.yml`を実行してtailscaleを導入する。
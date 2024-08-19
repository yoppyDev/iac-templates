# 実行手順
1. インスタンスを起動する
```
terraform init
terraform apply
```
2. インスタンスにSSH接続する
```
chmod +x util.sh
./util.sh save_private_key
ssh -i ./outline_key.pem ec2-user@$(terraform output -raw static_ip_address)
```
1. online-serverをインストールする
```
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh)"
```

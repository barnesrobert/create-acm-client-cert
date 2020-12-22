# FROM:
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-certs
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual

# TODO Get server keys from S3...

export EASYRSA_BATCH=1


git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full $DOMAIN nopass

./easyrsa build-client-full $USER.$DOMAIN nopass

mkdir ~/$USER/
cp pki/ca.crt ~/$USER/
cp pki/issued/$DOMAIN.crt ~/$USER/
cp pki/private/$DOMAIN.key ~/$USER/
cp pki/issued/$USER.$DOMAIN.crt ~/$USER
cp pki/private/$USER.$DOMAIN.key ~/$USER/
cd ~/$USER/



aws acm import-certificate --certificate fileb://$DOMAIN.crt --private-key fileb://$DOMAIN.key --certificate-chain fileb://ca.crt --tags Key=Name,Value=$DOMAIN
sleep 2
aws acm import-certificate --certificate fileb://$USER.$DOMAIN.crt --private-key fileb://$USER.$DOMAIN.key --certificate-chain fileb://ca.crt --tags Key=Name,Value=$USER

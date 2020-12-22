# FROM:
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-certs
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual

# TODO Get server keys from S3...

export domain=aws.local
export user=TEST-USER
export EASYRSA_BATCH=1


sudo yum install openssl -y
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa build-server-full $domain nopass

./easyrsa build-client-full $user.$domain nopass

mkdir ~/$user/
cp pki/ca.crt ~/$user/
cp pki/issued/$domain.crt ~/$user/
cp pki/private/$domain.key ~/$user/
cp pki/issued/$user.$domain.crt ~/$user
cp pki/private/$user.$domain.key ~/$user/
cd ~/$user/



aws acm import-certificate --certificate fileb://$domain.crt --private-key fileb://$domain.key --certificate-chain fileb://ca.crt --tags Key=Name,Value=$domain
sleep 2
aws acm import-certificate --certificate fileb://$user.$domain.crt --private-key fileb://$user.$domain.key --certificate-chain fileb://ca.crt --tags Key=Name,Value=$user

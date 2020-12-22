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



domain_cert_arn=$(aws acm import-certificate --certificate fileb://$DOMAIN.crt --private-key fileb://$DOMAIN.key --certificate-chain fileb://ca.crt --tags Key=Name,Value=$DOMAIN --query CertificateArn --output text)
sleep 2
user_cert_arn=$(aws acm import-certificate --certificate fileb://$USER.$DOMAIN.crt --private-key fileb://$USER.$DOMAIN.key --certificate-chain fileb://ca.crt --tags Key=Name,Value=$USER --query CertificateArn --output text)


#aws logs create-log-group --log-group-name clientvpn
#aws logs create-log-stream --log-group-name clientvpn --log-stream-name $DOMAIN/$USER

aws ec2 create-client-vpn-endpoint --client-cidr-block 10.5.0.0/22 --server-certificate-arn domain_cert_arn --authentication-options Type=certificate-authentication,MutualAuthentication={ClientRootCertificateChainArn=$user_cert_arn} --connection-log-options Enabled=true,CloudwatchLogGroup=clientvpn,CloudwatchLogStream=$DOMAIN/$USER

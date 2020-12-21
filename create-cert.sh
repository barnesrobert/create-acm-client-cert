# FROM:
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-certs
# https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html#mutual

#./easyrsa build-server-full aws.local nopass

user=USER_NAME_FOR_EACH_CLIENT_CERT

./easyrsa build-client-full $user.domain.tld nopass

mkdir ~/$user/
cp pki/ca.crt ~/$user/
cp pki/issued/aws.local.crt ~/$user/
cp pki/private/aws.local.key ~/$user/
cp pki/issued/$user.aws.local.crt ~/$user
cp pki/private/$user.aws.local.key ~/$user/
cd ~/$user/



aws acm import-certificate --certificate fileb://aws.local.crt --private-key fileb://aws.local.key --certificate-chain fileb://ca.crt
aws acm import-certificate --certificate fileb://$user.aws.local.crt --private-key fileb://$user.aws.local.key --certificate-chain fileb://ca.crt

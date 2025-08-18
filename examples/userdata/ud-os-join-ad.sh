#!/bin/bash -xe
# Send the following variables from terraform:
#${aws_region}
#${is_asg} - True/False - Auto Scaling Group?
#${domain_name} - Domain Name: example.com
#${dom_disname} - dc=local,dc=fastramp,dc=internal
#${ou_env} - OU=Linux,OU=Production,OU=Management,OU=Servers
## ${admins_ad_group} - linuxadmins
#${domain_join_user_name} - svc_dj
#${sm_djuser_path} - /production/mgmt/ad/svc_dj

set -o nounset

admins_ad_group=${admins_ad_group}

# Get IMDSv2 token
TOKEN=$(curl -X PUT 'http://169.254.169.254/latest/api/token' -H 'X-aws-ec2-metadata-token-ttl-seconds: 21600')

# IF ASG is set - tag instanceID to compname and append, then check for 15 char length
instanceID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/1.0/meta-data/instance-id")
hostname="$(aws ec2 describe-tags --region ${aws_region} --filters "Name=resource-id, Values=$instanceID" "Name=key, Values=Name" | jq -r '.Tags[].Value')"

# Truncate hostname to meet AD 15-char. requirement
if ${is_asg} ; then
  instanceIDAppnd=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/1.0/meta-data/instance-id" | cut -c 3-)
  hostname=$(echo "$hostname" | cut -c1-6)
  hostname="$hostname-$instanceIDAppnd"
  hostname=$(echo "$hostname" | cut -c1-15)
else
  hostname=$(echo "$hostname" | cut -c1-15)
fi

# Set hostname via hostnamectl set-hostname
echo "Setting hostname to $hostname.${domain_name}"
hostnamectl set-hostname "$hostname"."${domain_name}" --no-ask-password

# Set the new host name in /etc/hosts or rsyslog doesn't log new hostname.
sed -i "/127.0.0.1/i\127.0.0.1   $hostname $hostname.${domain_name}" /etc/hosts

# Bounce rsyslogd to grab the new hostname.
systemctl restart rsyslog

# Set default realm for Ubuntu
domain_upper=$(echo "${domain_name}" | tr '[:lower:]' '[:upper:]')
if [[ $(uname -a | tr '[:upper:]' '[:lower:]') =~ "ubuntu" ]]; then
  cat > /etc/krb5.conf <<EOF
[libdefaults]
default_realm = $domain_upper
[realms]
[domain_realm]
EOF
  chmod 0644 /etc/krb5.conf
fi

sm_fips_endpoint="https://secretsmanager-fips.${aws_region}.amazonaws.com"

# Use realm to join the AD domain.
for i in {1..10}
do
  echo `aws secretsmanager get-secret-value --secret-id "${sm_djuser_path}" --region ${aws_region} --endpoint-url $sm_fips_endpoint | jq -r '.SecretString'`| realm join --membership-software=adcli --user=${domain_join_user_name} ${domain_name} --computer-ou="${prod_ou_env},${dom_disname}"
  if [[ ! -z "$(realm list)" ]];
  then
    echo "Realm joined successfully!"
    break
  else
    echo "Realm join failed, retrying $i out of 10 times."
    sleep 60s
    cat /etc/resolv.conf
  fi
  if [[ $i == 10 ]];
  then
    if [[ ! -z "$(realm list)" ]];
    then
      echo "Realm join failed after 10 tries, exiting with code 1"
      exit 1
    fi
  fi
done

# Modify sssd.conf to create <username> only directories.
sed -i -e 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
sed -i -e 's+fallback_homedir = /home/%u@%d+fallback_homedir = /home/%u+g' /etc/sssd/sssd.conf

# Loosen up the permissions so sssd functions properly.
chmod 755 /var/lib/sss
chmod 755 /var/lib/sss/mc
chmod 755 /var/lib/sss/pipes/

# Ensure dynamic DNS updates are enabled.
echo "dyndns_update = True" >> /etc/sssd/sssd.conf
echo "dyndns_update_ptr = True" >> /etc/sssd/sssd.conf

# Allow domain users to get/create a home directory upon login
if [[ $(uname -a | tr '[:upper:]' '[:lower:]') =~ "ubuntu" ]]; then
  pam-auth-update --enable mkhomedir --force
fi

# Restart the daemon and SSHD.
systemctl daemon-reload
systemctl restart sssd

# Update sshd_config to allow password authentication from windows domain.
sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Shutoff GSSAPIAuthentication for SSH
sed -i -e 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
sed -i -e 's/#GSSAPIAuthentication no/GSSAPIAuthentication no/g' /etc/ssh/sshd_config

## Allow the windows AD group to log in
realm permit -g ${admins_ad_group}@${domain_name}

# Allow windows group permissions
echo "%$admins_ad_group    ALL=(ALL)       ALL" | tee -a /etc/sudoers > /dev/null

# Reload sshd config.
systemctl reload sshd

#STIG Fix for and AD
#sed -i 's/.*optional/#&/' /etc/pam.d/sudo
#sed -i 's/.*required/#&/' /etc/pam.d/sudo

[[ -z $(grep root /etc/cron.allow) ]] && echo "root" >> /etc/cron.allow
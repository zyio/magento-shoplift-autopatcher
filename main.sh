#!/bin/bash
#magento autopatcher


#Install needed packages

YUM=$(which yum)
APT=$(which apt-get)

if [ -z "$YUM" ]
then
  #no yum so presume apt
  apt-get install patch
elif [ -z "$APT" ]
then
  #no apt so presume yum. Bit crude
  yum -y install patch
fi

#wget the patches from git to /tmp/magepatches
mkdir /tmp/magepatches
wget -O /tmp/magepatches/1.4.0-1.5.0.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.4.0-1.5.0.sh
wget -O /tmp/magepatches/1.5.1.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.5.1.sh
wget -O /tmp/magepatches/1.6.0.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.6.0.sh
wget -O /tmp/magepatches/1.6.1-1.6.2.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.6.1-1.6.2.sh
wget -O /tmp/magepatches/1.7.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.7.sh

#Find all the vulns!
for SITE in $(find / -path '*/app/code/core/Mage/Core/Controller/Request/Http.php' -exec grep -L _internallyForwarded {} \;); do
 
  #Find Mage version of said site
  VERSION=$(php -r ";require '${SITE}/app/Mage.php'; echo Mage::getVersion(); "|tr -d'.')

  #Determine document root with a questionable awk
  DOCROOT=$(awk -F'app/code/core' {'print $1'} $SITE)

  if [${VERSION} -le 1500 ]
  then
    PATCH=/tmp/magepatches/1.4.0-1.5.0.sh
  elif [${VERSION} -ge 1510 -a ${VERSION} -le 1599]
  then
    PATCH=/tmp/magepatches/1.5.1.sh
  elif [${VERSION} -ge 1600 -a ${VERSION} -le 1609]
  then
    PATCH=/tmp/magepatches/1.6.0.sh
  elif [${VERSION} -ge 1610 -a ${VERSION} -le 1629]
  then
    PATCH=/tmp/magepatches/1.6.1-1.6.2.sh
  elif [${VERSION} -ge 1700 -a ${VERSION} -le 1799]
  then
    PATCH=/tmp/magepatches/1.7.sh
  elif [${VERSION} -ge 1800 -a ${VERSION} -le 1999]
  then
    PATCH=/tmp/magepatches/1.8-1.9.sh
  else
  echo -e "Can't determine a correct patch to apply, possibly no patch available for your magento version of ${VERSION}\n"
  fi

  cp ${PATCH} ${DOCROOT}
  
  PATCH=$(awk -F'/magepatches/' {'print $2'} ${PATCH})

  cd ${DOCROOT}
  OWNER=$(stat -c '%U' app/Mage.php)
  sudo -u${OWNER} /bin/bash ${PATCH}

  echo -e "Magento installation in ${DOCROOT} patched\n"

done

rm -rf /tmp/magepatches

echo -e "Now clear your caches out:\n \
      - https://www.byte.nl/wiki/How_to_apply_Magento_patch_SUPEE-5344?_ga=1.122262091.1191872873.1429777915\n \
      - Restart your webserver and/or php-fpm to be sure\n \
      - Consider apc/opcache as well"

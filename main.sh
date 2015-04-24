#!/bin/bash
#######################################################################################################
##############
##title:             Magento autopatcher
##description:       Finds magento sites vulnerable to 'shoplift' and applies magento patch SUPEE-5344
##author:            Sam Norbury - github.com/zyio - zy.io
##date:              24/04/2015
##version:           0.5
##############
#######################################################################################################

#Install needed packages

YUM=$(which yum)
APT=$(which apt-get)

if [ -z "$YUM" ]
then
  #no yum so presume apt
  apt-get -f install patch
elif [ -z "$APT" ]
then
  #no apt so presume yum. Bit crude
  yum -y install patch
fi

#wget the patches from git to /tmp/magepatches
mkdir /tmp/magepatches
wget -qO /tmp/magepatches/1.4.0-1.5.0.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.4.0-1.5.0.sh
wget -qO /tmp/magepatches/1.5.1.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.5.1.sh
wget -qO /tmp/magepatches/1.6.0.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.6.0.sh
wget -qO /tmp/magepatches/1.6.1-1.6.2.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.6.1-1.6.2.sh
wget -qO /tmp/magepatches/1.7.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.7.sh
wget -qO /tmp/magepatches/1.8-1.9.sh  https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/patches/1.8-1.9.sh

#Find all the vulns!
for SITE in $(find / -path '*/app/code/core/Mage/Core/Controller/Request/Http.php' -exec grep -L _internallyForwarded {} \;); do
 
  #Determine document root with a questionable awk
  DOCROOT=$(echo "${SITE}"| awk -F'app/code/core' {'print $1'})
  
  #Find Mage version of said site
  VERSION=$(php -r ";require '${DOCROOT}/app/Mage.php'; echo Mage::getVersion(); "|tr -d ".")

  #Choose correct patch for correct version. Dot stripping tactic lovingly stolen from Mark @webcreation
  if [ ${VERSION} -le 1500 ]
  then
    PATCH=/tmp/magepatches/1.4.0-1.5.0.sh
  elif [ ${VERSION} -ge 1510 -a ${VERSION} -le 1599 ]
  then
    PATCH=/tmp/magepatches/1.5.1.sh
  elif [ ${VERSION} -ge 1600 -a ${VERSION} -le 1609 ]
  then
    PATCH=/tmp/magepatches/1.6.0.sh
  elif [ ${VERSION} -ge 1610 -a ${VERSION} -le 1629 ]
  then
    PATCH=/tmp/magepatches/1.6.1-1.6.2.sh
  elif [ ${VERSION} -ge 1700 -a ${VERSION} -le 1799 ]
  then
    PATCH=/tmp/magepatches/1.7.sh
  elif [ ${VERSION} -ge 1800 -a ${VERSION} -le 1999 ]
  then
    PATCH=/tmp/magepatches/1.8-1.9.sh
  else
  echo -e "Can't determine a correct patch to apply, possibly no patch available for your magento version of ${VERSION}\n"
  fi

  #copy patch into place
  cp ${PATCH} ${DOCROOT}
  
  PATCH=$(echo "${PATCH}" |awk -F'/magepatches/' {'print $2'})

  #cd-ing the directory is a bit rough but not sure how well the mage scripts handle relative paths. Leaving for now
  cd ${DOCROOT}

  #identify owner and run as that user to avoid silly permission issues
  OWNER=$(stat -c '%U' app/Mage.php)
  sudo -u${OWNER} /bin/bash ${PATCH}
 
  #tidy up after ourselves
  rm -f ${PATCH}
  echo -e "Magento installation in ${DOCROOT} patched\n"

done

rm -rf /tmp/magepatches

echo -e "Now clear your caches out:\n \
      - https://www.byte.nl/wiki/How_to_apply_Magento_patch_SUPEE-5344?_ga=1.122262091.1191872873.1429777915\n \
      - Restart your webserver and/or php-fpm to be sure\n \
      - Consider apc/opcache as well"
#Fin

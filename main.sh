#disclaimer
#get patches from github or offer to use local files if they don't trust.
#apt/yum install patch
#find unpatches sites
#apply patch to site from docroot (as root or as site user? test)
#scan once more for unpatches sites
#echo out something about clearing caches - http://www.magentocommerce.com/knowledge-base/entry/cache-storage-management/%09200
#https://shoplift.byte.nl/
#FIN

##############
## SCRATCH
##############

#path location
#patches/$VERSION.sh

#find mage versions
#for i in $(find / -wholename '*/app/Mage.php'); do echo "$i <-> `php -r ";require '$i'; echo Mage::getVersion(); "`"; done

#find unpatched sites
#find / -wholename '*/app/code/core/Mage/Core/Controller/Request/Http.php' -exec grep -L _internallyForwarded {} \;

#apply patch - pseudo

#$UNPATCHEDSITES = awk -F'app/code/core' {'print $1'} $UNPATCHEDSITES

#$VERSION = for i in $UNPATCHEDSITES; do php -r ";require '$i/app/Mage.php'; echo Mage::getVersion(); "; done

#for i in $UNPATCHEDSITES; do cp patches/$VERSION $UNPATCHEDSITES && bash $UNPATCHEDSITES/$VERSION.sh ; done

#1.4.0-1.5.0.sh
#1.5.1.sh
#1.6.0.sh
#1.6.1-1.6.2.sh
#1.7.sh
#1.8-1.9.sh

##############
## END SCRATCH
##############



#wget the patches from git to /tmp/magepatches


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

echo -e "Now clear your caches out:\n \
      - https://www.byte.nl/wiki/How_to_apply_Magento_patch_SUPEE-5344?_ga=1.122262091.1191872873.1429777915\n \
      - Restart your webserver and/or php-fpm to be sure\n \
      - Consider apc/opcache as well"




#determine version of site and patch appropriately
#https://www.byte.nl/wiki/How_to_apply_Magento_patch_SUPEE-5344?_ga=1.122262091.1191872873.1429777915





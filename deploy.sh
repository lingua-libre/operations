#!/bin/bash

read -p "Mediawiki Release [REL1_35]: " RELEASE
RELEASE=${RELEASE:-REL1_35}

read -p "System user [www-data]: " USER
USER=${USER:-www-data}

read -p "Path [dev.lingualibre.org]: " MAINPATH
MAINPATH=${MAINPATH:-dev.lingualibre.org}

if [ $# -eq 0 ]
then
	read -p "database name: " wgDBname
	read -p "database user: " wgDBuser
	read -p "database password: " wgDBpassword
	read -p "wiki secret key: " wgSecretKey
	read -p "OAuth consumer key: " wgOAuthAuthenticationConsumerKey
	read -p "OAuth consumer secret: " wgOAuthAuthenticationConsumerSecret
fi

# Install Mediawiki  and import configuration files
git clone  --recurse-submodules https://gerrit.wikimedia.org/r/mediawiki/core.git --branch ${RELEASE} --depth=1 ${MAINPATH}

# Crete PrivateSettings file
mkdir ${MAINPATH}/private
if [ $# -eq 0 ]
then
    echo "<?php" >> ${MAINPATH}/private/PrivateSettings.php
    echo "\$wgDBname = \"${wgDBname}\";" >> ${MAINPATH}/private/PrivateSettings.php
    echo "\$wgDBuser = \"${wgDBuser}\";" >> ${MAINPATH}/private/PrivateSettings.php
    echo "\$wgDBpassword = \"${wgDBpassword}\";" >> ${MAINPATH}/private/PrivateSettings.php
    echo "\$wgSecretKey = \"${wgSecretKey}\";" >> ${MAINPATH}/private/PrivateSettings.php
    echo "\$wgOAuthAuthenticationConsumerKey = \"${wgOAuthAuthenticationConsumerKey}\";" >> ${MAINPATH}/private/PrivateSettings.php
    echo "\$wgOAuthAuthenticationConsumerSecret = \"${wgOAuthAuthenticationConsumerSecret}\";" >> ${MAINPATH}/private/PrivateSettings.php
else
    cp $1 ${MAINPATH}/private/PrivateSettings.php
fi

# Install Lingua Libre configuration and logos
cd ${MAINPATH}/
mkdir -p resources/assets/logo/
wget https://raw.githubusercontent.com/lingua-libre/operations/master/mediawiki-config/logo/lingualibre-logo-2x.png -P resources/assets/logo/
wget https://raw.githubusercontent.com/lingua-libre/operations/master/mediawiki-config/logo/lingualibre-favicon.ico -P resources/assets/logo/
wget https://raw.githubusercontent.com/lingua-libre/operations/master/mediawiki-config/LocalSettings.php
chown -R ${USER}:${USER} ./
sudo -u ${USER} composer install --no-dev

# Install skins
sudo -u ${USER} git clone --depth 1 https://github.com/lingua-libre/BlueLL.git skins/BlueLL

# Install extensions
cd extensions/
for ext in OAuthAuthentication Wikibase cldr CleanChanges LocalisationUpdate Babel UniversalLanguageSelector Translate MwEmbedSupport TimedMediaHandler CodeEditor Scribunto Echo Thanks
do
	sudo -u ${USER} git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/${ext}.git --branch ${RELEASE} --depth 1
done

# Install Lingua Libre specific extensions
for ext in QueryViz RecordWizard Upload2Commons CustomSubtitle
do
	sudo -u ${USER} git clone https://github.com/lingua-libre/${ext}.git --depth 1
done


# Use patched version of OAuthAuthentication
cd OAuthAuthentication/
sudo -u ${USER} git fetch https://gerrit.wikimedia.org/r/mediawiki/extensions/OAuthAuthentication refs/changes/85/683885/4
sudo -u ${USER} git checkout FETCH_HEAD
cd ../

# Use patched version of Wikibase (detail, no more useful from 1.36)
cd Wikibase/
sudo -u ${USER} git fetch https://gerrit.wikimedia.org/r/mediawiki/extensions/Wikibase refs/changes/28/664228/2
sudo -u ${USER} git checkout FETCH_HEAD
cd ../

# Use patched version of InputBox (detail, no more useful from 1.37)
cd InputBox/
sudo -u ${USER} git fetch https://gerrit.wikimedia.org/r/mediawiki/extensions/InputBox refs/changes/34/683034/2
sudo -u ${USER} git checkout FETCH_HEAD
cd ../

# Use patched version of MultimediaViewer (detail)
cd MultimediaViewer/
sudo -u ${USER} git fetch https://gerrit.wikimedia.org/r/mediawiki/extensions/MultimediaViewer refs/changes/39/683039/3
sudo -u ${USER} git checkout FETCH_HEAD
cd ../

# Import submodules and install dependencies of Wikibase
cd Wikibase
sudo -u ${USER} git submodule update --init --recursive
cd ../

# Allow the execution of the lua binary for Scribunto
chmod a+x Scribunto/includes/engines/LuaStandalone/binaries/lua5_1_5_linux_lua_64/generic

# Composer install
for ext in Wikibase OAuthAuthentication TimedMediaHandler
do
	cd ${ext}/
	sudo -u ${USER} composer install --no-dev
	cd ../
done

# Npm install
for ext in QueryViz RecordWizard
do
	cd ${ext}/
	sudo -u ${USER} npm install --production
	cd ../
done

# Run maintenance scripts
cd ../
php maintenance/update.php
php extensions/Wikibase/lib/maintenance/populateSitesTable.php
php extensions/Wikibase/repo/maintenance/rebuildItemsPerSite.php

# Install backup script
mkdir -p /usr/local/lib/backup /usr/local/lib/systemd/system
wget https://raw.githubusercontent.com/lingua-libre/operations/master/backup/backup-lingualibre -P /usr/local/lib/backup/
wget https://raw.githubusercontent.com/lingua-libre/operations/master/systemd/backup-lingualibre.service -P /usr/local/lib/systemd/system/
wget https://raw.githubusercontent.com/lingua-libre/operations/master/systemd/backup-lingualibre.timer -P /usr/local/lib/systemd/system/
echo '* Please configure the MySQL user used for backups, and declare it in /usr/local/lib/backup/backup-lingualibre'
echo '  (parameters MYSQL_HOST, MYSQL_USER, and MYSQL_PASS).'
echo '* The hour of the daily backup can be configured in /usr/local/lib/systemd/system/backup-lingualibre.timer.'
echo '* Then launch the daily backup with:'
echo '    sudo systemctl start backup-lingualibre.timer'
echo '    sudo systemctl enable backup-lingualibre.timer'

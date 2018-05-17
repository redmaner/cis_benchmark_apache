#!/bin/bash

# Define bash colors for Mac OSX / Linux
case `uname -s` in
    Darwin) 
           txtrst='\033[0m' # Color off
           txtred='\033[0;31m' # Red
           txtgrn='\033[0;32m' # Green
           txtblu='\033[0;34m' # Blue
           ;;
    *)
           txtrst='\e[0m' # Normal
		   txtylw='\e[1;33m' # Yellow bold
           txtred='\e[1;31m' # Red bold
           txtgrn='\e[1;32m' # Green bold
           txtblu='\e[1;36m' # Blue bold
           ;;
esac

up=$PWD
exec 2> /dev/null
clear

# Define messages
status_ok="[${txtgrn}OK${txtrst}]"
status_wrn="[${txtred}WARNING${txtrst}]"

# Apache 
apache_dir=/etc/httpd
apache_conf=$apache_dir/conf/httpd.conf
apache_confs=$(grep -i "Include *.conf" $apache_conf | grep -v '#Include')


source $up/suggestions.sh

# Define suggestions
suggestions="sgs_auth_modules"

echo -e "
  ___   _   ____         ___     _    _____
 / __) (_) (  __)  __   / __)   / \  (_  __)
( (__  | | _\ \   (__) ( (__   / ^ \   | |
 \___) |_|(___)         \___) /_/ \_\  |_|

"
echo -e "BENCHMARK - APACHE VERSION 2.4"

###################################################
# AUDIT CHAPTER 2: MINIMIZE APACHE MODULES
###################################################

echo -e "\n${txtblu}Chapter 2: Minimize Apache modules${txtrst}\n"

# 2.2 Log Config Module
if [ "$(httpd -M | grep log_config)" == "" ]; then
	echo -e " - Log Config Module is enabled              $status_wrn\n"
	suggestions="$suggestions sgs_log_config_module"
else
	echo -e " - Log Config Module is enabled              $status_ok\n"
fi

# 2.3 WebDAV modules are disabled
if [ "$(httpd -M | grep ' dav_[[:print:]]+module')" != "" ]; then
	echo -e " - WebDAV modules are disabled               $status_wrn\n"
	suggestions="$suggestions sgs_webdav_module"
else
	echo -e " - WebDAV modules are disabled               $status_ok\n"
fi

# 2.4 Status Module is disabled
if [ '$(httpd -M | egrep "status_module")' != "" ]; then
	echo -e " - Status module is disabled                 $status_wrn\n"
	suggestions="$suggestions sgs_status_module"
else
	echo -e " - Status module is disabled                 $status_ok\n"
fi

# 2.5 Autoindex Module is disabled
if [ "$(httpd -M | grep autoindex_module)" != "" ]; then
	echo -e " - Autoindex module is disabled              $status_wrn\n"
	suggestions="$suggestions sgs_autoindex_module"
else
	echo -e " - Autoindex module is disabled              $status_ok\n"
fi

# 2.6 Proxy modules are disabled
if [ "$(httpd -M | grep proxy_)" != "" ]; then
	echo -e " - Proxy modules are disabled                $status_wrn\n"
	suggestions="$suggestions sgs_proxy_module"
else
	echo -e " - Proxy modules are disabled                $status_ok\n"
fi

# 2.7 User Directories Modules are disabled
if [ "$(httpd -M | grep userdir_)" != "" ]; then
	echo -e " - User directories modules are disabled     $status_wrn\n"
	suggestions="$suggestions sgs_user_dir_module"
else
	echo -e " - User directories modules are disabled     $status_ok\n"
fi

# 2.8 Info module is disabled
if [ '$(httpd -M | egrep "info_module")' != "" ]; then
	echo -e " - Info module is disabled                   $status_wrn\n"
	suggestions="$suggestions sgs_info_module"
else
	echo -e " - Info module is disabled                   $status_ok\n"
fi

# Show suggestions after audit
echo -e "${txtblu}SUGGESTIONS:${txtrst}"
sed "s/ /\n/g" <<< $suggestions | while read sgs; do
	$sgs
done

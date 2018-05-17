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
 \___) |_|(____)        \___) /_/ \_\  |_|

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

###################################################
# AUDIT CHAPTER 3: PRINCIPLES, PERMISSIONS AND OWNERSHIP
###################################################

echo -e "\n${txtblu}Chapter 3: Principles, permissions and ownership${txtrst}\n"

# 3.1 Apache web server is run by a non-root user
apache_user=$(grep -i '^User' $apache_conf | cut -d" " -f2)
apache_user_uid=$(id $apache_user | cut -d'=' -f2 | cut -d'(' -f1)
user_uid_min=$(grep '^UID_MIN' /etc/login.defs | cut -d" " -f2)

if [ $apache_user == "" ]; then
	echo -e " - User is not commented out in httpd.conf   $status_wrn"
	suggestions="$suggestions sgs_define_user"
else
	echo -e " - User is not commented out in httpd.conf    $status_ok"
fi

if [ '$(grep -i '^Group' '$apache_conf')' == "" ]; then
	echo -e " - Group is not commented out in httpd.conf   $status_wrn"
	suggestions="$suggestions sgs_define_group"
else
	echo -e " - Group is not commented out in httpd.conf   $status_ok"
fi

if [ "$apache_user_uid" -ge "$user_uid_min" ]; then
	echo -e " - User ($apache_user) uid ($apache_user_uid) is less than $user_uid_min     $status_wrn"
	suggestions="$suggestions sgs_uid_less"
else
	echo -e " - User ($apache_user) uid ($apache_user_uid) is less than $user_uid_min     $status_ok"
fi

if [ $(ps axu | grep httpd | grep -v root | cut -d" " -f1 | grep $apache_user) == "" ]; then
	echo -e " - Apache web server is run by non-root user  $status_wrn\n"
	suggestions="$suggestions sgs_non_root"
else
	echo -e " - Apache web server is run by non-root user  $status_ok\n"
fi 

# Show suggestions after audit
echo -e "${txtblu}SUGGESTIONS:${txtrst}"
sed "s/ /\n/g" <<< $suggestions | while read sgs; do
	$sgs
done

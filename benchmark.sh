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
exec 2> $up/error.log
clear

# Languages
source $up/languages/strings_en

# Define messages
status_ok="[${txtgrn}$string_status_ok${txtrst}]"
status_wrn="[${txtred}$string_status_warning${txtrst}]"

# Apache 
apache_bin=apache2ctl
apache_dir=/etc/apache2
apache_conf=$apache_dir/apache2.conf
apache_confs=$(grep -i "Include *.conf" $apache_conf | grep -v '#Include')\

# Tmp
date_tmp=$(date +"%m-%d-%Y-%H-%M-%S")
tmp_dir="$up/.tmp-$date_tmp"
tmp_dir_keep_alive=true
apache_conf_tmp=$tmp_dir/apache.conf
apache_conf_tmp_status=false

source $up/scripts/make_tmp_conf.sh
source $up/scripts/suggestions.sh

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

echo -e "\n${txtblu}$string_c2_title${txtrst}\n"

# 2.2 Log Config Module
if [ "$($apache_bin -M | grep log_config)" == "" ]; then
	echo -e "$string_c2_22    $status_wrn\n"
	suggestions="$suggestions sgs_log_config_module"
else
	echo -e "$string_c2_22    $status_ok\n"
fi

# 2.3 WebDAV modules are disabled
if [ "$($apache_bin -M | grep ' dav_[[:print:]]+module')" != "" ]; then
	echo -e "$string_c2_23    $status_wrn\n"
	suggestions="$suggestions sgs_webdav_module"
else
	echo -e "$string_c2_23    $status_ok\n"
fi

# 2.4 Status Module is disabled
if [ "$($apache_bin -M | grep status_module)" != "" ]; then
	echo -e "$string_c2_24    $status_wrn\n"
	suggestions="$suggestions sgs_status_module"
else
	echo -e "$string_c2_24    $status_ok\n"
fi

# 2.5 Autoindex Module is disabled
if [ "$($apache_bin -M | grep autoindex_module)" != "" ]; then
	echo -e "$string_c2_25    $status_wrn\n"
	suggestions="$suggestions sgs_autoindex_module"
else
	echo -e "$string_c2_25    $status_ok\n"
fi

# 2.6 Proxy modules are disabled
if [ "$($apache_bin -M | grep proxy_)" != "" ]; then
	echo -e "$string_c2_26    $status_wrn\n"
	suggestions="$suggestions sgs_proxy_module"
else
	echo -e "$string_c2_26    $status_ok\n"
fi

# 2.7 User Directories Modules are disabled
if [ "$($apache_bin -M | grep userdir_)" != "" ]; then
	echo -e "$string_c2_27    $status_wrn\n"
	suggestions="$suggestions sgs_user_dir_module"
else
	echo -e "$string_c2_27    $status_ok\n"
fi

# 2.8 Info module is disabled
if [ "$($apache_bin -M | grep info_module)" != "" ]; then
	echo -e "$string_c2_28    $status_wrn\n"
	suggestions="$suggestions sgs_info_module"
else
	echo -e "$string_c2_28    $status_ok\n"
fi

###################################################
# AUDIT CHAPTER 3: PRINCIPLES, PERMISSIONS AND OWNERSHIP
###################################################

echo -e "\n${txtblu}$string_c3_title${txtrst}\n"

# 3.1 Apache web server is run by a non-root user
apache_user=$(grep -i '^User' $apache_conf | cut -d" " -f2)
apache_user_uid=$(id $apache_user | cut -d'=' -f2 | cut -d'(' -f1)
user_uid_min=$(grep '^UID_MIN' /etc/login.defs | cut -d" " -f2)
source $up/languages/strings_en

if [ $apache_user == "" ]; then
	echo -e "$string_c3_31_1    $status_wrn"
	suggestions="$suggestions sgs_define_user"
else
	echo -e "$string_c3_31_1    $status_ok"
fi

if [ '$(grep -i '^Group' '$apache_conf')' == "" ]; then
	echo -e "$string_c3_31_2    $status_wrn"
	suggestions="$suggestions sgs_define_group"
else
	echo -e "$string_c3_31_2    $status_ok"
fi

if [ "$apache_user_uid" -ge "$user_uid_min" ]; then
	echo -e "$string_c3_31_3    $status_wrn"
	suggestions="$suggestions sgs_uid_less"
else
	echo -e "$string_c3_31_3    $status_ok"
fi

if [ $(ps axu | grep $apache_bin | grep -v root | cut -d" " -f1 | grep $apache_user) == "" ]; then
	echo -e "$string_c3_31_4    $status_wrn\n"
	suggestions="$suggestions sgs_non_root"
else
	echo -e "$string_c3_31_4    $status_ok\n"
fi 

# Show suggestions after audit
echo -e "${txtblu}$string_suggestions_title${txtrst}"
sed "s/ /\n/g" <<< $suggestions | while read sgs; do
	$sgs
done

# Remove temporary files
if [ $tmp_dir_keep_alive == false ]; then
	rm -rf $tmp_dir
fi

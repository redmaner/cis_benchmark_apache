#!/bin/bash

###################################################
# SUGGESTIONS CHAPTER 2
###################################################

sgs_auth_modules () {
echo -e "\n${txtylw} * Enable Only Necessary Authentication and Authorization Modules${txtrst}
  >> Reference: "
}

sgs_log_config_module () {
echo -e "\n${txtylw} * Enable the log config module${txtrst}
  >> Reference: "
}

sgs_webdav_module () {
echo -e "\n${txtylw} * Disable WebDAV modules${txtrst}
  >> Reference: "
}

sgs_status_module () {
echo -e "\n${txtylw} * Disable status module${txtrst}
  >> Reference: "
}

sgs_autoindex_module () {
echo -e "\n${txtylw} * Disable autoindex module${txtrst}
  >> Reference: "
}

sgs_proxy_module () {
echo -e "\n${txtylw} * Disable proxy modules${txtrst}
  >> Reference: "
}

sgs_user_dir_module () {
echo -e "\n${txtylw} * Disable user directories modules${txtrst}
  >> Reference: "
}

sgs_info_module () {
echo -e "\n${txtylw} * Disable info module${txtrst}
  >> Reference: "
}

###################################################
# SUGGESTIONS CHAPTER 3
###################################################

sgs_define_user () {
echo -e "\n${txtylw} * Define user in httpd.conf${txtrst}
  >> Reference: "
}

sgs_define_group () {
echo -e "\n${txtylw} * Define group in httpd.conf${txtrst}
  >> Reference: "
}

sgs_less_uid () {
echo -e "\n${txtylw} * Make sure the defined user in httpd.conf has a uid which is less than UID_MIN${txtrst}
  >> Reference: "
}

sgs_non_root () {
echo -e "\n${txtylw} * Make sure the Apache web server is run by a non root user${txtrst}
  >> Reference: "
}


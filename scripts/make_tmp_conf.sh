#!/bin/bash
# Apache has multiple configuration files that determine the entire configuration of the Apache HTTP server
# This script is meant to merge these configurations into a single file for easier checking

# Debian / Ubuntu
if [ -d $apache_dir/conf-enabled ] && [ -d $apache_dir/mods-enabled ] && [ -d $apache_dir/sites-enabled ] && [ -e $apache_dir/ports.conf ]; then
	mkdir -p $tmp_dir
	cat $apache_conf > $apache_conf_tmp
	cat $apache_dir/ports.conf >> $apache_conf_tmp

	# Enabled confs
	find $apache_dir/conf-enabled -iname "*.conf" | sort | while read apache_conf_enabled; do
		cat $apache_conf_enabled >> $apache_conf_tmp
	done

	# Load modules
	find $apache_dir/mods-enabled -iname "*.load" | sort | while read apache_mod_load; do
		cat $apache_mod_load >> $apache_conf_tmp
	done

	# configure modules
	find $apache_dir/mods-enabled -iname "*.conf" | sort | while read apache_mod_conf; do
		cat $apache_mod_conf >> $apache_conf_tmp
	done

	# Enabled sites
	find $apache_dir/sites-enabled -iname "*.conf" | sort | while read apache_sites_enabled; do
		cat $apache_sites_enabled >> $apache_conf_tmp
	done

	apache_conf_tmp_status=true
fi	

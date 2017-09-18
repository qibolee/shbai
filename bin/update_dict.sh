#!/bin/bash
# -*- coding: gbk -*-


################################################
# File Name		: update_dict.sh
# Author		: liqibo(liqibo@baidu.com)
# Create Time	: 2017/08/02
# Brief			: fetch zongkong dict to local, always
################################################


# global config
local_dir="/home/work/shangbai"
data_dir="${local_dir}/online"
tmp_dir="${local_dir}/tmp"
bin_dir="${local_dir}/bin"

# remote data
# white url
url_white_url="ftp://10.46.240.12:/home/work/zongkong/userdata/40/na_badcase_white_dict/na_badcase_white_dict_sys_default_0.txt"
url_white_url_md5="ftp://10.46.240.12:/home/work/zongkong/userdata/40/na_badcase_white_dict/na_badcase_white_dict_sys_default_0.txt.md5"
#url_white_url="ftp://10.46.240.12:/home/work/zongkong/userdata/36/url_white_dict/url_white_dict_url.txt"
#url_white_url_md5="ftp://10.46.240.12:/home/work/zongkong/userdata/36/url_white_dict/url_white_dict_url.txt.md5"
# slp dict
url_slp_dict="ftp://10.46.240.12:/home/work/zongkong/userdata/38/smart_landing_page_user_control_up/smart_landing_page_user_control_up_dict.txt"
url_slp_dict_md5="ftp://10.46.240.12:/home/work/zongkong/userdata/38/smart_landing_page_user_control_up/smart_landing_page_user_control_up_dict.txt.md5"

# local data
# white url
path_white_url="${data_dir}/white_url"
path_white_url_md5="${data_dir}/white_url.md5"
tmp_white_url="${tmp_dir}/tmp_white_url"
tmp_white_url_md5="${tmp_dir}/tmp_white_url.md5"
# slp dict
path_slp_dict="${data_dir}/slp_dict"
path_slp_dict_md5="${data_dir}/slp_dict.md5"
tmp_slp_dict="${tmp_dir}/tmp_slp_dict"
tmp_slp_dict_md5="${tmp_dir}/tmp_slp_dict.md5"
# mixer block '\t': url_sign, 1, 0, 0, 100, 0
path_mixer_block="${data_dir}/mixer_block"
path_mixer_block_md5="${data_dir}/mixer_block.md5"
# mixer全屏蔽词表 '\t': uid, url, url_sign, 1, 0, 0, 100, 0
path_mixer_full="${data_dir}/mixer_full"
path_mixer_full_md5="${data_dir}/mixer_full.md5"


# log info
function log(){
	now_date=`date +"%Y/%m/%d %H:%M:%S"`
	pid=$$
	echo -e "${pid} ${now_date} $1"
}


# init work space
function init_work(){
	log "init work space..."
	log "change directory..."
	cd ${local_dir}
	log "change done"
	log "inti done"
	log "pwd: `pwd`"
}


# fetch white url to local, every 10 minutes
function update_white_url(){
	log "run update white url..."
	
	while [[ true ]]
	do
		do_wget ${url_white_url} ${url_white_url_md5} ${tmp_white_url} ${tmp_white_url_md5}
		old_md5=`cat ${path_white_url_md5} | awk '{print $1}'`
		new_md5=`cat ${tmp_white_url_md5} | awk '{print $1}'`
		if [[ ${old_md5} != ${new_md5} ]]
		then
			log "now, updateing local white url..."
			cat ${tmp_white_url_md5} | awk '{print $1}' >${path_white_url_md5}
			# sleep, avoid conflict
			sleep 1m
			cat ${tmp_white_url} >${path_white_url}
			update_mixer_block_by_url
		fi
		log "sleeping 10 minutes..."
		sleep 10m
	done
	log "white url update done, but must occur error"
}


# fetch slp dict to local, every 10 minutes
function update_slp_dict(){
	log "run update slp dict..."
	
	while [[ true ]]
	do
		do_wget ${url_slp_dict} ${url_slp_dict_md5} ${tmp_slp_dict} ${tmp_slp_dict_md5}
		old_md5=`cat ${path_slp_dict_md5} | awk '{print $1}'`
		new_md5=`cat ${tmp_slp_dict_md5} | awk '{print $1}'`
		if [[ ${old_md5} != ${new_md5} ]]
		then
			log "now, updateing local white url..."
			cat ${tmp_slp_dict_md5} | awk '{print $1}' >${path_slp_dict_md5}
			# sleep, avoid conflict
			sleep 1m
			cat ${tmp_slp_dict} >${path_slp_dict}
		fi
		log "sleeping 10 minutes..."
		sleep 10m
	done
	log "slp dict update done, but must occur error"
}


# update mixer block dict
function update_mixer_block_by_url(){
	log "updating mixer block..."
	tmp_dict="${tmp_dir}/tmp_dict"
	while [[ true ]]
	do
		should_md5=`cat ${path_mixer_full_md5} | awk '{print $1}'`
		real_md5=`md5sum ${path_mixer_full} | awk '{print $1}'`
		if [[ ${should_md5} == ${real_md5} ]]
		then
			break
		fi
		log "mixer_block is buzy, sleeping 1 minute"
		sleep 1m
	done
	echo -n "" >${path_mixer_full_md5}
	# sleep, avoid conflict
	sleep 1m
	# updating, url filter
	awk -F'\t' 'ARGIND==1{mp[$1]=1} ARGIND==2{if(!($2 in mp)){print $0}}' ${path_white_url} ${path_mixer_full} >${tmp_dict}
	cat ${tmp_dict} >${path_mixer_full}
	# online mixer block dict
	#awk -F'\t' '{printf("%s\t%s\t%s\t%s\t%s\n", $3, $4, $5, $6, $7)}' ${path_mixer_full} >${path_mixer_block}
	cd ${data_dir}
	#md5sum ${path_mixer_block} >${path_mixer_block_md5}
	cd -
	# online mixer dict generate done
	md5sum ${path_mixer_full} | awk '{print $1}' >${path_mixer_full_md5}
	rm ${tmp_dict}
	log "update mixer done"
}


# update mixer block dict
function update_mixer_block_by_slp(){
	log "updating mixer block..."
	tmp_dict="${tmp_dir}/tmp_dict"
	while [[ true ]]
	do
		should_md5=`cat ${path_mixer_full_md5} | awk '{print $1}'`
		real_md5=`md5sum ${path_mixer_full} | awk '{print $1}'`
		if [[ ${should_md5} == ${real_md5} ]]
		then
			break
		fi
		log "mixer_block is buzy, sleeping  1minute"
		sleep 1m
	done
	echo -n "" >${path_mixer_full_md5}
	# sleep, avoid conflict
	sleep 1m
	# updating, uid filter
	awk -F'\t' 'ARGIND==1{if($2!=0 && $3>=50 && $3<=100){mp[$1]=1}} ARGIND==2{if(!($2 in mp)){print $0}}' ${path_slp_dict} ${path_mixer_full} >${tmp_dict}
	cat ${tmp_dict} >${path_mixer_full}
	# online mixer block dict
	#awk -F'\t' '{printf("%s\t%s\t%s\t%s\t%s\t%s\n",$3,$4,$5,$6,$7,$8)}' ${path_mixer_full} >${path_mixer_block}
	cd ${data_dir}
	#md5sum ${path_mixer_block} >${path_mixer_block_md5}
	cd -
	# online mixer dict generate done
	md5sum ${path_mixer_full} | awk '{print $1}' >${path_mixer_full_md5}
	rm ${tmp_dict}
	log "update mixer done"
}


# do_wget url_data url_md5 local_data local_md5
function do_wget(){
	if [[ $# != 4 ]]
	then
		log "do_wget error, argc is not 4"
		return 1
	fi
	url_data=$1
   	url_md5=$2
   	local_data=$3
   	local_md5=$4
	while [[ true ]]
	do
		wget ${url_md5} -O ${local_md5}
		should_md5=`cat ${local_md5} | awk '{print $1}'`
		if [[ ${should_md5} == "" ]]
		then
			log "md5 file is null, sleeping 1 minute"
			sleep 1m
			continue
		fi
		wget ${url_data} -O ${local_data}
		real_md5=`md5sum ${local_data} | awk '{print $1}'`
		if [[ ${should_md5} != ${real_md5} ]]
		then
			log "md5 check failed, sleeping 1 minute"
			sleep 1m
			continue
		fi
		break
	done
	return 0
}


# main task
function main_task(){
	log "starting..."
	init_work
	update_white_url &
	#update_slp_dict &
	wait
	log "done, but must occur error"
}


# run
main_task




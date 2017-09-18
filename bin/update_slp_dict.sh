#!/bin/bash
# -*- coding: gbk -*-


################################################
# File Name		: update_slp_dict.sh
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
# slp dict
url_slp_dict="ftp://10.46.240.12:/home/work/zongkong/userdata/38/smart_landing_page_user_control_up/smart_landing_page_user_control_up_dict.txt"
url_slp_dict_md5="ftp://10.46.240.12:/home/work/zongkong/userdata/38/smart_landing_page_user_control_up/smart_landing_page_user_control_up_dict.txt.md5"

# local data
# slp dict
file_slp_uid="slp_uid"
path_slp_uid="${data_dir}/${file_slp_uid}"
path_slp_uid_md5="${data_dir}/${file_slp_uid}.md5"
path_slp_dict="${data_dir}/slp_dict"
path_slp_dict_md5="${data_dir}/slp_dict.md5"
tmp_slp_dict="${tmp_dir}/tmp_slp_dict"
tmp_slp_dict_md5="${tmp_dir}/tmp_slp_dict.md5"
# mixer block '\t': url_sign, 1, 0, 0, 100, 0
file_mixer_block="mixer_block"
path_mixer_block="${data_dir}/${file_mixer_block}"
path_mixer_block_md5="${data_dir}/${file_mixer_block}.md5"
# mixer全屏蔽词表 '\t': uid, url, url_sign, 1, 0, 0, 100, 0
path_mixer_full="${data_dir}/mixer_full"


# log info
function log(){
	now_date=`date +"%Y/%m/%d %H:%M:%S"`
	echo -e "[${now_date}] $1"
}


# init work space
function init_work(){
	log "init work space..."
	log "change directory..."
	cd ${local_dir}
	log "change done"
	log "init done"
	log "pwd: `pwd`"
}


# fetch slp dict to local
function update_slp_dict(){
	log "run update slp dict..."
	
	do_wget ${url_slp_dict} ${url_slp_dict_md5} ${tmp_slp_dict} ${tmp_slp_dict_md5}
	old_md5=`cat ${path_slp_dict_md5} | awk '{print $1}'`
	new_md5=`cat ${tmp_slp_dict_md5} | awk '{print $1}'`
	if [[ ${old_md5} == ${new_md5} ]]
	then
		log "slp dict is updated"
		return 0
	fi
	log "now, updating slp dict to local..."
	cat ${tmp_slp_dict_md5} | awk '{print $1}' >${path_slp_dict_md5}
	cat ${tmp_slp_dict} >${path_slp_dict}
	# slp uid
	awk -F'\t' '{if($2!=0 && $3>=50 && $3<=100){print $1}}' ${path_slp_dict} >${path_slp_uid}
	cd ${data_dir}
	md5sum ${file_slp_uid} >${path_slp_uid_md5}
	cd -
	# update mixer block
	update_mixer_block
	log "slp dict update done, but must occur error"
}


# update mixer block dict
function update_mixer_block(){
	log "updating mixer block..."
	tmp_dict="${tmp_dir}/tmp_dict"
	# tmp mixer full
	awk -F'\t' 'ARGIND==1{mp[$1]=1} ARGIND==2{if(!($1 in mp)){print $0}}' ${path_slp_uid} ${path_mixer_full} >${tmp_dict}
	# 数据量判定
	tmp_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${tmp_dict}`
	old_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_mixer_full}`
	if [[ ${tmp_num} -lt 2 || ${tmp_num} -lt $((old_num / 100)) ]]
	then
		log "failed, mixer block data is too few, don't update"
		log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		rm ${tmp_dict}
		return 1
	fi

	# update mixer full
	cat ${tmp_dict} >${path_mixer_full}
	# update mixer block
	awk -F'\t' '{printf("%s\t%s\t%s\t%s\t%s\t%s\n",$3,$4,$5,$6,$7,$8)}' ${path_mixer_full} >${path_mixer_block}
	cd ${data_dir}
	md5sum ${file_mixer_block} >${path_mixer_block_md5}
	cd -

	rm ${tmp_dict}
	log "update mixer block done"
	log "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
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
	old_md5=`md5sum ${local_data} | awk '{print $1}'`
	while [[ true ]]
	do
		wget ${url_md5} -O ${local_md5}
		should_md5=`cat ${local_md5} | awk '{print $1}'`
		if [[ ${should_md5} == ${old_md5} ]]
		then
			log "dont need to wget"
			break
		fi
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
	log "start updating >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	init_work
	update_slp_dict
	log "done <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
}


# run
main_task




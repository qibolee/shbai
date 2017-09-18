#!/bin/bash
# -*- coding: gbk -*-


################################################
# File Name		: update_white_url.sh
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

# local data
# white url
path_white_url="${data_dir}/white_url"
path_white_url_md5="${data_dir}/white_url.md5"
tmp_white_url="${tmp_dir}/tmp_white_url"
tmp_white_url_md5="${tmp_dir}/tmp_white_url.md5"
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


# fetch white url to local
function update_white_url(){
	log "run update white url..."

	do_wget ${url_white_url} ${url_white_url_md5} ${tmp_white_url} ${tmp_white_url_md5}
	old_md5=`cat ${path_white_url_md5} | awk '{print $1}'`
	new_md5=`cat ${tmp_white_url_md5} | awk '{print $1}'`
	if [[ ${old_md5} == ${new_md5} ]]
	then
		log "white url is updated"
		return 0
	fi
	log "update white url to lcoal..."
	cat ${tmp_white_url} >${path_white_url}
	cat ${tmp_white_url_md5} | awk '{print $1}' >${path_white_url_md5}
	update_mixer_block
	log "white url update done"
}


# update mixer block dict
function update_mixer_block(){
	log "updating mixer block..."
	tmp_dict="${tmp_dir}/tmp_dict"
	# tmp mixer full
	awk -F'\t' 'ARGIND==1{mp[$1]=1} ARGIND==2{if(!($2 in mp)){print $0}}' ${path_white_url} ${path_mixer_full} >${tmp_dict}
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
	update_white_url
	log "done <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
}


# run
main_task




#!/bin/bash
# -*- coding: gbk -*-


################################################
# File Name		: run_update_slp_dict.sh
# Author		: liqibo(liqibo@baidu.com)
# Create Time	: 2017/08/03
# Brief			: run update_slp_dict.sh
################################################


# global config
static_date=`date +"%Y%m%d"`
local_dir="/home/work/shangbai"
log_dir="${local_dir}/log"
bin_dir="${local_dir}/bin"
path_log="${log_dir}/update_slp_dict_${static_date}.log"


# main task
function main_task(){
	[[ ! -f ${path_log} ]] && touch ${path_log}
	cd ${local_dir}
	bash -x ${bin_dir}/update_slp_dict.sh >>${path_log} 2>>${path_log}
}


# run
main_task




#!/bin/bash
# -*- coding: gbk -*-


################################################
# File Name		: hadoop_job.sh
# Author		: liqibo(liqibo@baidu.com)
# Create Time	: 2017/08/01
# Brief			: hadoop job
################################################



# global config
# hadoop prefix
prefix_thang="hdfs://nmg01-taihang-hdfs.dmop.baidu.com:54310"
prefix_khan="hdfs://nmg01-khan-hdfs.dmop.baidu.com:54310"
prefix_mulan="hdfs://nmg01-mulan-hdfs.dmop.baidu.com:54310"
# hadoop bin
#hadoop_thang="/home/liqibo/software/hadoop-client-taihang/hadoop/bin/hadoop"
hadoop_khan="/home/work/shangbai/lib/hadoop-client-nmg/hadoop/bin/hadoop"
#hadoop_mulan="/home/liqibo/software/mulan-hadoop-client/hadoop/bin/hadoop"

local_dir="/home/work/shangbai/bin/hadoop"
hadoop_prefix="${prefix_khan}"
hadoop_bin="${hadoop_khan}"
mapper_bin="${local_dir}/mapper.py"
reducer_bin="${local_dir}/reducer.py"
# static date
if [[ $# == 1 ]]
then
	static_date=$1
else
	static_date=`date -d"1 day ago" +"%Y%m%d"`
fi
# bad_dict, '\t': uid, url, tag
path_bad_dict="/home/work/shangbai/data/${static_date}/bad_dict"
# hadoop output dir
hadoop_output="${prefix_khan}/app/ecom/fcr/liqibo/NA/bad_dict_charge/${static_date}"
# charge list '\t': uid, total, pc, dead, alert, layer, apk
path_local="/home/work/shangbai/data/${static_date}/bad_dict_charge"


# generate input file list from date range
function list_input(){
	# micro shitu
	prefix_input="${prefix_khan}/app/ecom/fcr/NA/daily_shitu"
	postfix_input="*/part-*"
	# full shitu
	#prefix_input="${prefix_khan}/app/dt/udw/release/app/fengchao/shitu/222_223"
	#postfix_input="*/part-*"
	# feed
	# prefix_input="${hadoop_prefix}/app/dt/udw/release/app/fengchao/shitu/400"
	# postfix_input="*/part-*"
	# small shitu
	# prefix_input="${hadoop_prefix}/app/ecom/fcr/dynamic_creative/dp/small_shitu/wise"
	# postfix_input="*/part-*"

	if [[ $# == 1 ]]
	then
		echo "-input ${prefix_input}/$1/${postfix_input}"
	elif [[ $# == 2 ]]
	then
		static_date=$1
		while [[ ${static_date} -le $2 ]]
		do
			echo "-input ${prefix_input}/${static_date}/${postfix_input}"
			static_date=`date -d"${static_date} 1 day" +"%Y%m%d"`
		done
	fi
}

# input file list
hadoop_input=`list_input ${static_date}`

function run_hadoop(){
	# clear output
	${hadoop_bin} fs -rmr ${hadoop_output}
	# hadoop streaming
		#-outputformat "org.apache.hadoop.mapred.lib.SuffixMultipleTextOutputFormat" \
		#-jobconf mapred.job.queue.name=fcr-adu \
	${hadoop_bin} streaming \
		${hadoop_input} \
		-output ${hadoop_output} \
		-mapper "python27/bin/python2.7 mapper.py" \
		-reducer "python27/bin/python2.7 reducer.py bad_dict" \
		-file "${mapper_bin}" \
		-file "${reducer_bin}" \
		-file "${path_bad_dict}" \
		-cacheArchive "/share/python2.7.tar.gz#python27" \
		-jobconf mapred.job.name=liqibo-static \
		-jobconf mapred.job.priority=VERY_HIGH \
		-jobconf mapred.job.queue.name=fcr-adu \
		-jobconf stream.memory.limit=4096 \
		-jobconf mapred.job.map.capacity=3000 \
		-jobconf mapred.map.tasks=2000 \
		-jobconf mapred.job.reduce.capacity=2000 \
		-jobconf mapred.reduce.tasks=1000 \
		-jobconf mapred.job.reduce.memory.mb=5120 \
		-jobconf stream.num.map.output.key.fields=1

}


# main task
function main_task(){
	#echo ${hadoop_input}
	run_hadoop
	[[ -f ${path_local} ]] && mv ${path_local} ${path_local}.bak
	${hadoop_bin} fs -getmerge ${hadoop_output} ${path_local}
}


# run
main_task




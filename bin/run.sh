#!/bin/bash
#coding:gbk


################################################
# File Name     : run.sh
# Author        : liqibo(liqibo@baidu.com)
# Create Time   : 2017/07/15
# Brief         : 商百天级数据的处理
################################################


# 全局配置
set -x
if [[ $#  == 1 ]]
then
	static_date=$1
else
	# 默认是昨天
	static_date=`date -d "1 day ago" +"%Y%m%d"`
fi
local_dir="/home/work/shangbai"
bin_dir="${local_dir}/bin"
data_dir="${local_dir}/data/${static_date}"
global_data_dir="${local_dir}/online"
log_dir="${local_dir}/log"
# 合并历史数据的天数，用于生成全局的pc/dead词表，mixer屏蔽词表，feed屏蔽词表
history_days=2
# log_file="${local_dir}/log/day_${static_date}.log"

# 外围数据
# 商百天级数据, 每天更新, '\t': userid, url
url_shangbai_data="ftp://cp01-rd-crm-cdc-db10.cp01.baidu.com/home/work/mbjhbtask/wisefc/check_wisefc_na_day_${static_date}"
# 商百天级数据md5校验文件
url_shangbai_md5="ftp://cp01-rd-crm-cdc-db10.cp01.baidu.com/home/work/mbjhbtask/wisefc/check_wisefc_na_day_${static_date}.md5"

# 本地数据--在线屏蔽词表数据
# pc/dead词表文件名
file_pc_dead="pc_dead"
# mixer屏蔽词表文件名
file_mixer_block="mixer_block"
# feed屏蔽词表文件名
file_feed_block="feed_block"
# badurl替换词表文件名
file_badcase_replace="badcase_replace"
# 兜底词表，userid级别词表，'\t': userid, url
path_global_replace_dict="${global_data_dir}/replace_dict"
# 域名白名单，针对死链，添加白名单功能，在白名单中的域名不计入死链中
path_global_white_domain="${global_data_dir}/white_domain"
# url白名单词表, '\t': url, uid
path_global_white_url="${global_data_dir}/white_url"
# slp客户词表 '\t': uid
path_global_slp_uid="${global_data_dir}/slp_uid"
# pc/dead词表 '\t': userid, url
path_global_pc_dead="${global_data_dir}/${file_pc_dead}"
# pc/dead词表md5
path_global_pc_dead_md5="${global_data_dir}/${file_pc_dead}.md5"
# mixer全屏蔽词表 '\t': uid, url, url_sign, 1, 0, 0, 100, 0
path_global_mixer_full="${global_data_dir}/mixer_full"
# mixer屏蔽词表 '\t': url_sign, 1, 0, 0, 100, 0
path_global_mixer_block="${global_data_dir}/${file_mixer_block}"
# mixer屏蔽词表md5
path_global_mixer_block_md5="${global_data_dir}/${file_mixer_block}.md5"
# feed屏蔽词表 '\t': 0, url, 1
path_global_feed_block="${global_data_dir}/${file_feed_block}"
# feed屏蔽词表md5
path_global_feed_block_md5="${global_data_dir}/${file_feed_block}.md5"
# badurl替换词表 '\t': bad_url, 0, replace_url
path_global_badcase_replace="${global_data_dir}/${file_badcase_replace}"
# badurl替换词表md5
path_global_badcase_replace_md5="${global_data_dir}/${file_badcase_replace}.md5"

# 本地数据--每天产出的新数据
# 本地商百原始数据, '\t': userid, url
path_shangbai_ori="${data_dir}/shangbai_ori"
# 本地商百原始数据md5文件
path_shangbai_ori_md5="${data_dir}/shangbai_ori.md5"
# 商百数据预处理后的词表数据, 主要是补充id和去重，后续数据处理皆以此数据为基础 '\t': id, userid, url
path_shangbai_data="${data_dir}/shangbai_data"
# 本地商百数据抽取出的NA输入数据, '\t': id, url
path_na_input="${data_dir}/na_input"
# 本地NA检测结果, '\t': id, url, tag_list, detail_info。其中tag_list: '_'分隔
path_na_output="${data_dir}/na_output"
# 最终产出商百数据的文件名
file_result_data="check_wisefc_na_day_${static_date}.res"
# 本地最终产出文件, '\t': userid, url, check_time, check_type, status。其中check_type为{0:未检测, 1:不合格, 2:合格}，若status有多个，则以';'分隔
path_result_data="${data_dir}/${file_result_data}"
# 本地最终产出md5文件
path_result_md5="${data_dir}/${file_result_data}.md5"
# 所有问题url词表，'\t': userid, url, status
path_bad_dict="${data_dir}/bad_dict"
# 所有问题user消费词表，'\t': userid, total_chrg, pc_chrg, dead_chrg, alert_chrg, layer_chrg, apk_chrg
path_bad_dict_charge="${data_dir}/bad_dict_charge"
# pc/死链url, '\t': userid, url, status
path_pc_dead="${data_dir}/${file_pc_dead}"
# 弹窗浮层url, '\t': userid, url, status
path_alert_layer="${data_dir}/alert_layer"
# 统计汇总数据，以备发送邮件
path_mail_data="${data_dir}/mail_data"
# 折线图
path_trend_picture1="${data_dir}/trend1.png"
path_trend_picture2="${data_dir}/trend2.png"
# 折线图base64
path_trend1_base64="${data_dir}/trend1_base64"
path_trend2_base64="${data_dir}/trend2_base64"
# 抽样数据，100条pc url
path_sample_pc100="${data_dir}/sample_pc100"
# 抽样数据，100条死链url
path_sample_dead100="${data_dir}/sample_dead100"

# 本地数据
# 邮件模板
path_mail_template="${bin_dir}/mail_template"

# 打印log
function log(){
	now_date=`date +"%Y/%m/%d %H:%M:%S"`
	echo -e "[${now_date}] $1"
}


# 第0步，初始化工作环境
function init_work(){
	log "init work space..."
	log "change directory to ${local_di}"
	cd ${local_dir}
	log "change directory done"
	if [[ -d ${data_dir} ]]
	then
		#log "mv ${${data_dir}} to ${data_dir}.bak"
		mv ${data_dir} ${data_dir}.bak
	fi
	log "create local data dir..."
	mkdir ${data_dir}
	log "init done"
	log "static_date: ${static_date}"
	log "pwd: `pwd`"
}


# 第1步，获取商百天级数据并预处理
function get_shangbai_data(){
	log "get shangbai data to local..."
	# 获取商百原始数据到本地，若数据没准备好，则循环检测
	while [[ true ]]
	do
		wget ${url_shangbai_md5} -O ${path_shangbai_ori_md5}
		should_md5=`cat ${path_shangbai_ori_md5}`
		if [[ ${should_md5} == "" ]]
		then
			# 商百数据尚未准备好，休眠10分钟
			log "shangbai data is not ready, sleep 10 minutes..."
			sleep 10m
			log "sleep done"
		else
			wget ${url_shangbai_data} -O ${path_shangbai_ori}
			real_md5=`md5sum ${path_shangbai_ori} | awk -F' ' '{print $1}'`
			if [[ ${real_md5} == ${should_md5} ]]
			then
				# 商百数据已准备好
				log "shangbai data is ready!"
				break
			else
				# 商百数据尚未准备好，休眠10分钟
				log "shangbai data is not ready, sleep 10 minutes..."
				sleep 10m
				log "sleep done"
			fi
		fi
	done
	log "get shangbai data done"

	log "preprocess shangbai data..."
	# 预处理，主要是补充id和去重, 产出格式'\t': id, userid, url
	cat ${path_shangbai_ori} | python ${bin_dir}/preprocess_shangbai.py | sort -u >${path_shangbai_data}
	#awk -F'\t' '{if(NF==2 && $1!="" && $2!=""){print $0}}' ${path_shangbai_ori} | sort -u >${path_shangbai_data}
	log "preprocess done"

	log "fetch url from shangbai data for NA detect..."
	# 抽出商百数据中的url, 生成NA检测的输入数据 '\t': id, url
	awk -F'\t' '{printf("%s\t%s\n", $1, $3)}' ${path_shangbai_data} >${path_na_input}
	log "fetch url done"
}


# 第2步，运行NA处理程序
function run_na(){
	log "running NA command..."
	# 启动检测命令
	# cd /home/work/nascale/cli
	#q_na_detect ${path_na_input} >${path_na_output}
	#na_queue_detect ${path_na_input} -u shangbai > ${path_na_output}
	# cd -
	# 检测完成后，清理命令
	# cd /home/work/nascale/shell
	# bash /home/work/nascale/shell/run_async.sh "killall phantomjs"
	# cd -
	
	cd /home/disk2/jobs/server
	sh run_url.sh 100 ${path_na_input} >${path_na_output}
	cd -

	log "run NA done"
}


# hadoop 统计各类url消费信息
function run_hadoop(){
	log "fetch all bad dict..."
	# 用于统计各类问题url的消费数据
	awk -F'\t' 'ARGIND==1{mp[$1]=$2} ARGIND==2&&($1 in mp){if(match($4,"\\[pcurl\\]")||match($4,"\\[deadurl\\]")||match($4,"\\[dead\\]")||match($4,"\\[alert\\]")||match($4,"\\[layer\\]")||match($4,"\\[apk\\]")){printf("%s\t%s\t%s\n",mp[$1],$2,$3)}}' ${path_shangbai_data} ${path_na_output} | python ${bin_dir}/convert.py utf-8 gbk >${path_bad_dict}
	log "fetch all bad dict done"

	log "running hadoop job..."
	# 统计各类url消费信息
	path_hd_job="${bin_dir}/hadoop/hadoop_job.sh"
	path_hd_log="${bin_dir}/hadoop/${static_date}.log"
	bash -x ${path_hd_job} ${static_date} >${path_hd_log} 2>&1
	log "hadoop job done"
}


# 第3步，对NA产出数据进行处理
function process_na_data(){
	log "process NA result data..."
	# 商百数据, NA产出数据, NA产出数据的时间
	check_time=`date +"%Y-%m-%d"`
	# 产出 '\t': userid, url, check_time, check_type, status
	python ${bin_dir}/produce_result.py ${path_shangbai_data} ${path_na_output} ${check_time} >${path_result_data}
	log "process NA done"
}


# 第4步，抽取当天的pc/dead词表和alert/layer词表
function fetch_pc_dead_dict(){
	log "fetch pc/dead dict..."
	# 从最终结果中捞出pc/dead url，'\t': userid, url, status. [pc: 8, dead: 3] 目前dead准确率较低，暂且只抽取pc url
	awk -F'\t' '$4==1{if(match($5,";")){split($5,a,";");for(i in a){if(a[i]==8){printf("%s\t%s\t%s\n",$1,$2,$5);break;}}}else if($5==8){printf("%s\t%s\t%s\n",$1,$2,$5)}}' \
	${path_result_data} | sort -u >${path_pc_dead}
	log "fetch pc/dead done"

	log "fetch alert/layer dict..."
	# 从最终结果中捞出alert/layer url，'\t': userid, url, status. [alert: 10, layer: 11]
	awk -F'\t' '$4==1{if(match($5, ";")){split($5,a,";");for(i in a){if(a[i]==10 || a[i]==11){printf("%s\t%s\t%s\n",$1,$2,$5);break;}}}else if($5==10 || $5==11){printf("%s\t%s\t%s\n",$1,$2,$5)}}' \
	${path_result_data} | sort -u >${path_alert_layer}
	log "fetch alert/layer done"
}


# 第5步，合并历史pc/dead词表
function merge_pc_dead_dict(){
	log "merge pc/dead dict..."
	tmp_pc_dead="${global_data_dir}/tmp_pc_dead"
	tmp_block_dict="${global_data_dir}/tmp_block_dict"
	# 合并历史pc/dead词表
	echo -n "" >${tmp_pc_dead}
	for i in `seq 0 $((history_days - 1))`
	do
		history_date=`date -d "$i day ago ${static_date}" +"%Y%m%d"`
		history_pc_dead="${local_dir}/data/${history_date}/pc_dead"
		[[ -f ${history_pc_dead} ]] && cat ${history_pc_dead} >>${tmp_pc_dead}
	done
	# pc/dead词表去重
	sort -u ${tmp_pc_dead} >${tmp_block_dict}
	# 对pc/dead词表过滤域名白名单，针对死链url进行域名召回, '\t': uid, url
	python ${bin_dir}/produce_pc_dead.py ${tmp_block_dict} ${path_global_white_domain} >${tmp_pc_dead}
	# 数据量判定, 太少则不提换原来的词表
	tmp_pc_dead_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${tmp_pc_dead}`
	old_pc_dead_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_global_pc_dead}`
	if [[ ${tmp_pc_dead_num} -lt 2 || ${tmp_pc_dead_num} -lt $((old_pc_dead_num/100)) ]]
	then
		log "pc_dead dict data is too few, merge dict failed"
		log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		#rm ${tmp_pc_dead} ${tmp_block_dict}
		return 1
	fi
	# 替换在线pc/dead词表
	cat ${tmp_pc_dead} >${path_global_pc_dead}
	# 生成pc/dead词表的md5校验文件，保留文件名
	cd ${global_data_dir}
	md5sum ${file_pc_dead} >${path_global_pc_dead_md5}
	cd -
	#rm ${tmp_pc_dead} ${tmp_block_dict}
	log "merge pc/dead dict done"
	log "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	return 0
}


# 第6步，更新在线mixer屏蔽词表
function update_mixer_block_dict(){
	log "update online mixer block dict..."
	tmp_mixer_full="${global_data_dir}/tmp_mixer_full"
	# 根据pc/dead词表，生成mixer屏蔽词表 '\t': url_sign, 1, 0, 0, 100, 0
	python ${bin_dir}/produce_mixer_block.py ${path_global_pc_dead} ${path_global_replace_dict} ${path_global_slp_uid} ${path_global_white_url} | sort -u >${tmp_mixer_full}
	# 数据量判定, 太少则不提换原来的词表
	tmp_mixer_full_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${tmp_mixer_full}`
	old_mixer_full_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_global_mixer_full}`
	if [[ ${tmp_mixer_full_num} -lt 2 || ${tmp_mixer_full_num} -lt $((old_mixer_full_num / 100)) ]]
	then
		log "new mixer block dict data is too few, update mixer block dict failed"
		log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		rm ${tmp_mixer_full}
		return 1
	fi
	cat ${tmp_mixer_full} >${path_global_mixer_full}
	# online mixer block
	awk -F'\t' '{printf("%s\t%s\t%s\t%s\t%s\t%s\n",$3,$4,$5,$6,$7,$8)}' ${path_global_mixer_full} >${path_global_mixer_block}
	cd ${global_data_dir}
	md5sum ${file_mixer_block} >${path_global_mixer_block_md5}
	cd -

	rm ${tmp_mixer_full}
	log "update online mixer block dict done"
	log "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	return 0
}


# 第7步，更新在线feed词表
function update_feed_block_dict(){
	log "update online feed block dict..."
	tmp_feed_block="${global_data_dir}/tmp_feed_block"
	# 根据pc/dead词表，生成feed屏蔽词表 '\t': 0, url, 1
	awk -F'\t' '{printf("0\t%s\t1\n", $2)}' ${path_global_pc_dead} | sort -u >${tmp_feed_block}
	# 数据量判定, 太少则不提换原来的词表
	tmp_feed_block_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${tmp_feed_block}`
	old_feed_block_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_global_feed_block}`
	if [[ ${tmp_feed_block_num} -lt 2 || ${tmp_feed_block_num} -lt $((old_feed_block_num / 100)) ]]
	then
		log "new feed block dict data is too few, update feed block dict failed"
		log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		rm ${tmp_feed_block}
		return 1
	fi
	# 替换在线feed屏蔽词表
	cat ${tmp_feed_block} >${path_global_feed_block}
	# 生成feed屏蔽词表的md5校验文件，保留文件名
	cd ${global_data_dir}
	md5sum ${file_feed_block} >${path_global_feed_block_md5}
	cd -

	rm ${tmp_feed_block}
	log "update online feed block dict done"
	log "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	return 0
}


# 第8步，更新在线badcase词表
function update_badcase_replace_dict(){
	log "update online badcase replace dict..."
	tmp_badcase_replace="${global_data_dir}/tmp_badcase_replace"
	# 根据pc/dead词表，生成badcase屏蔽词表 '\t': ur_noproto, 0, url_replace.    path_global_badcase_replace_md5
	awk -F'\t' 'ARGIND==1{mp[$1]=$2} ARGIND==2{if($1 in mp){url=$2;if(substr(url,1,7)=="http://"){url=substr(url,8)}else if(substr(url,1,8)=="https://"){url=substr(url,9)} printf("%s\t0\t%s\n",url,mp[$1]);}}' \
	${path_global_replace_dict} ${path_global_pc_dead} >${tmp_badcase_replace}
	# 数据量判定, 太少则不提换原来的词表
	tmp_badcase_replace_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${tmp_badcase_replace}`
	old_badcase_replace_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_global_badcase_replace}`
	if [[ ${tmp_badcase_replace_num} -lt 2 || ${tmp_badcase_replace_num} -lt $((old_badcase_replace_num / 100)) ]]
	then
		log "new badcase replace dict data is too few, update badcase replace dict failed"
		log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		rm ${tmp_badcase_replace}
		return 1
	fi
	# 替换在线badcase替换词表
	cat ${tmp_badcase_replace} >${path_global_badcase_replace}
	# 生成badcase词表的md5校验文件，保留文件名
	cd ${global_data_dir}
	md5sum ${file_badcase_replace} >${path_global_badcase_replace_md5}
	cd -

	rm ${tmp_badcase_replace}
	log "update online badcase replace dict done"
	log "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	return 0
}


# 第9步，生成统计数据
function static_data(){
	log "generate static data..."
	# 本地手写的除法运算程序
	div_bin="${bin_dir}/div"
	# 商百数据 '\t': userid, url
	shangbai_ori_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_shangbai_ori}`
	shangbai_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_shangbai_data}`
	# NA产出数据 '\t': id, url, tag_list, detail_info. 其中tag_list '_': tag, tag, ..
	na_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_na_output}`
	na_valid_num=`awk -F'\t' 'BEGIN{cnt=0} ARGIND==1{mp[$1]=1} ARGIND==2{if($1 in mp){cnt+=1}} END{print cnt}' ${path_na_input} ${path_na_output}`
	na_pcurl_num=`awk -F'\t' 'BEGIN{cnt=0} {if(match($3, "\\\\[pcurl\\\\]")){cnt+=1}} END{print cnt}' ${path_na_output}`
	na_pcurl_ratio=`${div_bin} ${na_pcurl_num} ${na_valid_num} %`
	na_deadurl_num=`awk -F'\t' 'BEGIN{cnt=0} {if(match($3, "\\\\[deadurl\\\\]") || match($3, "\\\\[dead\\\\]")){cnt+=1}} END{print cnt}' ${path_na_output}`
	na_deadurl_ratio=`${div_bin} ${na_deadurl_num} ${na_valid_num} %`
	na_layer_num=`awk -F'\t' 'BEGIN{cnt=0} {if(match($3, "\\\\[layer\\\\]")){cnt+=1}} END{print cnt}' ${path_na_output}`
	na_layer_ratio=`${div_bin} ${na_layer_num} ${na_valid_num} %`
	na_alert_num=`awk -F'\t' 'BEGIN{cnt=0} {if(match($3, "\\\\[alert\\\\]")){cnt+=1}} END{print cnt}' ${path_na_output}`
	na_alert_ratio=`${div_bin} ${na_alert_num} ${na_valid_num} %`
	na_apk_num=`awk -F'\t' 'BEGIN{cnt=0} {if(match($3, "\\\\[apk\\\\]")){cnt+=1}} END{print cnt}' ${path_na_output}`
	na_apk_ratio=`${div_bin} ${na_apk_num} ${na_valid_num} %`
	# NA各类消费数据
	na_total_chrg=`awk -F'\t' 'BEGIN{chg=0} {chg+=$2} END{printf("%ld",chg)}' ${path_bad_dict_charge}`
	na_pc_chrg=`awk -F'\t' 'BEGIN{chg=0} {chg+=$3} END{printf("%ld",chg)}' ${path_bad_dict_charge}`
	na_pc_chg_ratio=`${div_bin} ${na_pc_chrg} ${na_total_chrg} %`
	na_dead_chrg=`awk -F'\t' 'BEGIN{chg=0} {chg+=$4} END{printf("%ld",chg)}' ${path_bad_dict_charge}`
	na_dead_chg_ratio=`${div_bin} ${na_dead_chrg} ${na_total_chrg} %`
	na_alert_chrg=`awk -F'\t' 'BEGIN{chg=0} {chg+=$5} END{printf("%ld",chg)}' ${path_bad_dict_charge}`
	na_alert_chg_ratio=`${div_bin} ${na_alert_chrg} ${na_total_chrg} %`
	na_layer_chrg=`awk -F'\t' 'BEGIN{chg=0} {chg+=$6} END{printf("%ld",chg)}' ${path_bad_dict_charge}`
	na_layer_chg_ratio=`${div_bin} ${na_layer_chrg} ${na_total_chrg} %`
	na_apk_chrg=`awk -F'\t' 'BEGIN{chg=0} {chg+=$7} END{printf("%ld",chg)}' ${path_bad_dict_charge}`
	na_apk_chg_ratio=`${div_bin} ${na_apk_chrg} ${na_total_chrg} %`
	# 最终生成数据 '\t': userid, url, check_time, check_result, status
	result_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_result_data}`
	result_type0_num=`awk -F'\t' 'BEGIN{cnt=0} {if($4 == 0){cnt+=1}} END{print cnt}' ${path_result_data}`
	result_type0_ratio=`${div_bin} ${result_type0_num} ${result_total_num} %`
	result_type1_num=`awk -F'\t' 'BEGIN{cnt=0} {if($4 == 1){cnt+=1}} END{print cnt}' ${path_result_data}`
	result_type2_num=`awk -F'\t' 'BEGIN{cnt=0} {if($4 == 2){cnt+=1}} END{print cnt}' ${path_result_data}`
	result_checked_num=$((result_type1_num + result_type2_num))
	result_checked_ratio=`${div_bin} ${result_checked_num} ${result_total_num} %`
	result_type1_ratio=`${div_bin} ${result_type1_num} ${result_checked_num} %`
	result_type2_ratio=`${div_bin} ${result_type2_num} ${result_checked_num} %`
	result_deadurl_num=`awk -F'\t' 'BEGIN{cnt=0} $4==1{if(match($5, ";")){split($5, a, ";");for(i in a){if(a[i] == 3){cnt+=1;break;}}}else if($5 == 3){cnt+=1}} END{print cnt}' ${path_result_data}`
	result_deadurl_ratio=`${div_bin} ${result_deadurl_num} ${result_checked_num} %`
	result_pcurl_num=`awk -F'\t' 'BEGIN{cnt=0} $4==1{if(match($5, ";")){split($5, a, ";");for(i in a){if(a[i] == 8){cnt+=1;break;}}}else if($5 == 8){cnt+=1}} END{print cnt}' ${path_result_data}`
	result_pcurl_ratio=`${div_bin} ${result_pcurl_num} ${result_checked_num} %`
	result_layer_num=`awk -F'\t' 'BEGIN{cnt=0} $4==1{if(match($5, ";")){split($5, a, ";");for(i in a){if(a[i] == 11){cnt+=1;break;}}}else if($5 == 11){cnt+=1}} END{print cnt}' ${path_result_data}`
	result_layer_ratio=`${div_bin} ${result_layer_num} ${result_checked_num} %`
	result_alert_num=`awk -F'\t' 'BEGIN{cnt=0} $4==1{if(match($5, ";")){split($5, a, ";");for(i in a){if(a[i] == 10){cnt+=1;break;}}}else if($5 == 10){cnt+=1}} END{print cnt}' ${path_result_data}`
	result_alert_ratio=`${div_bin} ${result_alert_num} ${result_checked_num} %`
	result_apk_num=`awk -F'\t' 'BEGIN{cnt=0} $4==1{if(match($5, ";")){split($5, a, ";");for(i in a){if(a[i] == 12){cnt+=1;break;}}}else if($5 == 12){cnt+=1}} END{print cnt}' ${path_result_data}`
	result_apk_ratio=`${div_bin} ${result_apk_num} ${result_checked_num} %`
	# 统计pc_dead, alert_layer增量数据 '\t': userid, url, status
	pc_dead_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_pc_dead}`
	pc_dead_user_num=`awk -F'\t' '{mp[$1]=1} END{cnt=0;for(i in mp){cnt+=1}print cnt}' ${path_pc_dead}`
	alert_layer_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_alert_layer}`
	alert_layer_user_num=`awk -F'\t' '{mp[$1]=1} END{cnt=0;for(i in mp){cnt+=1}print cnt}' ${path_alert_layer}`
	before_static_date=`date -d "1 day ago ${static_date}" +"%Y%m%d"`
	path_pc_dead_yesterday="${local_dir}/data/${before_static_date}/${file_pc_dead}"
	path_alert_layer_yesterday="${local_dir}/data/${before_static_date}/alert_layer"
	path_result_data_yesterday="${local_dir}/data/${before_static_date}/check_wisefc_na_day_${before_static_date}.res"
	if [[ -f ${path_result_data_yesterday} ]]
	then
		# 新增pc_dead, 是指本次检测出pc_dead, (上次没出现)或(上次检测出非pc_dead), url维度
		pc_dead_total_added_num=`awk -F'\t' 'BEGIN{cnt=0} ARGIND==1&&($4==1||$4==2){mp1[$1,$2]=$5} ARGIND==2&&($4==1||$4==2){if(match($5,"8") && (!(($1,$2) in mp1) || !match(mp1[$1,$2],"8"))){cnt+=1}} END{print cnt}' \
		${path_result_data_yesterday} ${path_result_data}`
		# 新增pc_dead user
		pc_dead_user_added_num=`awk -F'\t' 'BEGIN{cnt=0} ARGIND==1&&($4==1||$4==2){mp1[$1,$2]=$5} ARGIND==2&&($4==1||$4==2){if(match($5,"8") && (!(($1,$2) in mp1) || !match(mp1[$1,$2],"8"))){mp[$1]=1}} END{for(i in mp){cnt+=1} print cnt}' ${path_result_data_yesterday} ${path_result_data}`
		# 已整改pc_dead, 是指本次检测出非pc_dead, 上次检测出是pc_dead, url维度
		pc_dead_total_reduced_num=`awk -F'\t' 'BEGIN{cnt=0} ARGIND==1&&($4==1||$4==2){mp1[$1,$2]=$5} ARGIND==2&&($4==1||$4==2){if(($1,$2) in mp1 && match(mp1[$1,$2],"8") && !match($5,"8")){cnt+=1}} END{print cnt}' \
		${path_result_data_yesterday} ${path_result_data}`
		# 已整改pc_dead user
		pc_dead_user_reduced_num=`awk -F'\t' 'BEGIN{cnt=0} ARGIND==1&&($4==1||$4==2){mp1[$1,$2]=$5} ARGIND==2&&($4==1||$4==2){if(($1,$2) in mp1 && match(mp1[$1,$2],"8") && !match($5,"8")){mp[$1]=1}} END{for(i in mp){cnt+=1} print cnt}' ${path_result_data_yesterday} ${path_result_data}`
		# 新增alert_layer, 是指本次检测出alert_layer, (上次没出现)或(上次检测出非alert_layer), url维度
		alert_layer_total_added_num=`awk -F'\t' 'BEGIN{cnt=0} ARGIND==1&&($4==1||$4==2){mp1[$1,$2]=$5} ARGIND==2&&($4==1||$4==2){if((match($5,"10") || match($5,"11")) && (!(($1,$2) in mp1) || (!match(mp1[$1,$2],"10") && !match(mp1[$1,$2],"11")))){cnt+=1}} END{print cnt}' ${path_result_data_yesterday} ${path_result_data}`
		# 新增alert_layer user
		alert_layer_user_added_num=`awk -F'\t' 'BEGIN{cnt=0} ARGIND==1&&($4==1||$4==2){mp1[$1,$2]=$5} ARGIND==2&&($4==1||$4==2){if((match($5,"10") || match($5,"11")) && (!(($1,$2) in mp1) || (!match(mp1[$1,$2],"10") && !match(mp1[$1,$2],"11")))){mp[$1]=1}} END{for(i in mp){cnt+=1} print cnt}' ${path_result_data_yesterday} ${path_result_data}`
		# 已整改alert_layer, 是指本次检测出非alert_layer, 上次检测出是alert_layer, url维度
		alert_layer_total_reduced_num=`awk -F'\t' 'BEGIN{cnt=0} ARGIND==1&&($4==1||$4==2){mp1[$1,$2]=$5} ARGIND==2&&($4==1||$4==2){if(($1,$2) in mp1 && (match(mp1[$1,$2],"10") || match(mp1[$1,$2],"11")) && !match($5,"10") && !match($5,"11")){cnt+=1}} END{print cnt}' ${path_result_data_yesterday} ${path_result_data}`
		# 已整改alert_layer user
		alert_layer_user_reduced_num=`awk -F'\t' 'BEGIN{cnt=0} ARGIND==1&&($4==1||$4==2){mp1[$1,$2]=$5} ARGIND==2&&($4==1||$4==2){if(($1,$2) in mp1 && (match(mp1[$1,$2],"10") || match(mp1[$1,$2],"11")) && !match($5,"10") && !match($5,"11")){mp[$1]=1}} END{for(i in mp){cnt+=1} print cnt}' ${path_result_data_yesterday} ${path_result_data}`
	else
		pc_dead_total_added_num=${pc_dead_total_num}
		pc_dead_total_reduced_num="0"
		pc_dead_user_added_num=${pc_dead_user_num}
		pc_dead_user_reduced_num="0"

		alert_layer_total_added_num=${alert_layer_total_num}
		alert_layer_total_reduced_num="0"
		alert_layer_user_added_num=${alert_layer_user_num}
		alert_layer_user_reduced_num="0"
	fi

	# 在线词表
	global_pc_dead_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_global_pc_dead}`
	global_mixer_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_global_mixer_block}`
	global_feed_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_global_feed_block}`
	global_badcase_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_global_badcase_replace}`
	global_slp_uid_total_num=`awk -F'\t' 'BEGIN{cnt=0} {cnt+=1} END{print cnt}' ${path_global_slp_uid}`	

	# 将统计数据写入文件
	echo "static_date=${static_date}" >${path_mail_data}
	echo "shangbai_ori_total_num=${shangbai_ori_total_num}" >>${path_mail_data}
	echo "shangbai_total_num=${shangbai_total_num}" >>${path_mail_data}

	echo "na_total_num=${na_total_num}" >>${path_mail_data}
	echo "na_valid_num=${na_valid_num}" >>${path_mail_data}
	echo "na_pcurl_num=${na_pcurl_num}" >>${path_mail_data}
	echo "na_pcurl_ratio=${na_pcurl_ratio}" >>${path_mail_data}
	echo "na_deadurl_num=${na_deadurl_num}" >>${path_mail_data}
	echo "na_deadurl_ratio=${na_deadurl_ratio}" >>${path_mail_data}
	echo "na_layer_num=${na_layer_num}" >>${path_mail_data}
	echo "na_layer_ratio=${na_layer_ratio}" >>${path_mail_data}
	echo "na_alert_num=${na_alert_num}" >>${path_mail_data}
	echo "na_alert_ratio=${na_alert_ratio}" >>${path_mail_data}
	echo "na_apk_num=${na_apk_num}" >>${path_mail_data}
	echo "na_apk_ratio=${na_apk_ratio}" >>${path_mail_data}

	echo "na_total_chrg=${na_total_chrg}" >>${path_mail_data}
	echo "na_pc_chrg=${na_pc_chrg}" >>${path_mail_data}
	echo "na_pc_chg_ratio=${na_pc_chg_ratio}" >>${path_mail_data}
	echo "na_dead_chrg=${na_dead_chrg}" >>${path_mail_data}
	echo "na_dead_chg_ratio=${na_dead_chg_ratio}" >>${path_mail_data}
	echo "na_alert_chrg=${na_alert_chrg}" >>${path_mail_data}
	echo "na_alert_chg_ratio=${na_alert_chg_ratio}" >>${path_mail_data}
	echo "na_layer_chrg=${na_layer_chrg}" >>${path_mail_data}
	echo "na_layer_chg_ratio=${na_layer_chg_ratio}" >>${path_mail_data}
	echo "na_apk_chrg=${na_apk_chrg}" >>${path_mail_data}
	echo "na_apk_chg_ratio=${na_apk_chg_ratio}" >>${path_mail_data}

	echo "result_total_num=${result_total_num}" >>${path_mail_data}
	echo "result_type0_num=${result_type0_num}" >>${path_mail_data}
	echo "result_type0_ratio=${result_type0_ratio}" >>${path_mail_data}
	echo "result_checked_num=${result_checked_num}" >>${path_mail_data}
	echo "result_checked_ratio=${result_checked_ratio}" >>${path_mail_data}
	echo "result_type1_num=${result_type1_num}" >>${path_mail_data}
	echo "result_type1_ratio=${result_type1_ratio}" >>${path_mail_data}
	echo "result_type2_num=${result_type2_num}" >>${path_mail_data}
	echo "result_type2_ratio=${result_type2_ratio}" >>${path_mail_data}
	echo "result_pcurl_num=${result_pcurl_num}" >>${path_mail_data}
	echo "result_pcurl_ratio=${result_pcurl_ratio}" >>${path_mail_data}
	echo "result_deadurl_num=${result_deadurl_num}" >>${path_mail_data}
	echo "result_deadurl_ratio=${result_deadurl_ratio}" >>${path_mail_data}
	echo "result_layer_num=${result_layer_num}" >>${path_mail_data}
	echo "result_layer_ratio=${result_layer_ratio}" >>${path_mail_data}
	echo "result_alert_num=${result_alert_num}" >>${path_mail_data}
	echo "result_alert_ratio=${result_alert_ratio}" >>${path_mail_data}
	echo "result_apk_num=${result_apk_num}" >>${path_mail_data}
	echo "result_apk_ratio=${result_apk_ratio}" >>${path_mail_data}

	echo "pc_dead_total_num=${pc_dead_total_num}" >>${path_mail_data}
	echo "pc_dead_total_added_num=${pc_dead_total_added_num}" >>${path_mail_data}
	echo "pc_dead_total_reduced_num=${pc_dead_total_reduced_num}" >>${path_mail_data}
	echo "pc_dead_user_num=${pc_dead_user_num}" >>${path_mail_data}
	echo "pc_dead_user_added_num=${pc_dead_user_added_num}" >>${path_mail_data}
	echo "pc_dead_user_reduced_num=${pc_dead_user_reduced_num}" >>${path_mail_data}
	echo "alert_layer_total_num=${alert_layer_total_num}" >>${path_mail_data}
	echo "alert_layer_total_added_num=${alert_layer_total_added_num}" >>${path_mail_data}
	echo "alert_layer_total_reduced_num=${alert_layer_total_reduced_num}" >>${path_mail_data}
	echo "alert_layer_user_num=${alert_layer_user_num}" >>${path_mail_data}
	echo "alert_layer_user_added_num=${alert_layer_user_added_num}" >>${path_mail_data}
	echo "alert_layer_user_reduced_num=${alert_layer_user_reduced_num}" >>${path_mail_data}

	echo "global_pc_dead_num=${global_pc_dead_num}" >>${path_mail_data}
	echo "global_mixer_total_num=${global_mixer_total_num}" >>${path_mail_data}
	echo "global_feed_total_num=${global_feed_total_num}" >>${path_mail_data}
	echo "global_badcase_total_num=${global_badcase_total_num}" >>${path_mail_data}
	echo "global_slp_uid_total_num=${global_slp_uid_total_num}" >>${path_mail_data}

	# 随机抽取出100条pc url和死链url
	awk -F'\t' '{if($4 == 1){if(match($5, ";")){split($5, a, ";");for(i in a){if(a[i] == 8){print $2;break;}}}else if($5 == 8){print $2}}}' ${path_result_data} | \
	python ${bin_dir}/sample.py 100 | python ${bin_dir}/convert.py utf-8 gbk >${path_sample_pc100}
	awk -F'\t' '{if($4 == 1){if(match($5, ";")){split($5, a, ";");for(i in a){if(a[i] == 3){print $2;break;}}}else if($5 == 3){print $2}}}' ${path_result_data} | \
	python ${bin_dir}/sample.py 100 | python ${bin_dir}/convert.py utf-8 gbk >${path_sample_dead100}

	log "generate done"
}


# 第10步，生成近7天bad url趋势图及base64文件
function produce_trend_picture(){
	log "produce trend picture..."
	# 生成折线图
	python ${bin_dir}/produce_trend.py ${static_date} ${path_trend_picture1} ${path_trend_picture2}
	# 生成base64文件
	base64 ${path_trend_picture1} >${path_trend1_base64}
	base64 ${path_trend_picture2} >${path_trend2_base64}
	log "produce done"
}


# 第11步，发送邮件
function send_email(){
	log "send email..."
	# 发送邮件
	python ${bin_dir}/produce_mail.py ${path_mail_template} ${path_mail_data} ${path_sample_pc100} ${path_sample_dead100} ${path_trend1_base64} ${path_trend2_base64} | /usr/sbin/sendmail -t
	# 发送邮件
	#echo -e ${email_content} | mail -s ${email_subject} ${receivers} -- -f ${sender}
	log "send email done"
}


# 第12步，休眠一定时间后，生成md5检验文件
function produce_md5(){
	log "sleep 2 hours..."
	# 之所以休眠，是为了留足时间来人工check，没异议后则生成md5文件
	sleep 2h
	log "sleep done"

	log "generate md5 file..."
	# 生成最终商百数据的md5校验文件，保留文件名
	cd ${data_dir}
	md5sum ${file_result_data} >${path_result_md5}
	cd -
	# 生成屏蔽词表的md5校验文件，保留文件名
	cd ${global_data_dir}
	md5sum ${file_pc_dead} >${path_global_pc_dead_md5}
	md5sum ${file_mixer_block} >${path_global_mixer_block_md5}
	md5sum ${file_feed_block} >${path_global_feed_block_md5}
	md5sum ${file_badcase_replace} >${path_global_badcase_replace_md5}
	cd -
	log "generate md5 file done"
}


# 主任务函数
function main_task(){
	init_work
	get_shangbai_data
	run_na
	run_hadoop
	process_na_data
	fetch_pc_dead_dict
	#merge_pc_dead_dict
	#update_mixer_block_dict
	#update_feed_block_dict
	#update_badcase_replace_dict
	#static_data
	#produce_trend_picture
	#send_email
	#produce_md5
}


# 执行主函数命令
main_task






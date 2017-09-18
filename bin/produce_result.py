#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : produce_result.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/16
# Brief         : process NA output data, produce result data
###########################################


__revision__ = '0.1'
import sys
import urllib



# {id: set([status, status, ...])}
dict_url = {}
# "[dead]": "3", "[deadurl]": "3", "[pcurl]": "8", "[alert]": "10", "[layer]": "11", "[apk]": "12"
dict_url_tag = {"[pcurl]": "8", "[alert]": "10", "[layer]": "11", "[apk]": "12"}
# NA检测结果
result_not_check = "0"
result_not_ok = "1"
result_ok = "2"


def run(path_shangbai_data, path_na_output, check_time):
    '''
    input:
        path_shangbai_data, '\t': id, userid, url
        path_na_output, '\t': id, url, tag_list, detail_info
            其中tag_list: '_'分隔, 一个或多个tag
    output:
        '\t': userid, url, check_time, check_type, status
            其中，check_type: 0未检测，1不合格，2合格
            status若有多个，则以';'分隔
    '''
    with open(path_na_output) as file:
        # '\t': id, url, tag_list, detail_info
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))

            if len(ll) < 4:
                continue
            id = ll[0]
            url = ll[1]
            str_tags = ll[2]
            
            if id not in dict_url:
                dict_url[id] = set()

            list_tag = map(lambda x: x.strip(), str_tags.split("_"))

            for tag in list_tag:
                # "E_*"为异常错误，视为未检测
                if tag.startswith("E"):
                    dict_url[id].add("E")
                    break
                elif tag in dict_url_tag:
                    status = dict_url_tag[tag]
                    # ("3", "8", "10", "11", "12")
                    dict_url[id].add(status)

    with open(path_shangbai_data) as file:
        # '\t': id, userid, url
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))

            if len(ll) != 3:
                continue

            id = ll[0]
            uid = ll[1]
            url = ll[2]

            if id in dict_url:
                check_type, status = get_status(dict_url[id])
            else:
                check_type = result_not_check
                status = "0"

            print "%s\t%s\t%s\t%s\t%s" % (uid, url, check_time, check_type, status)

    return 0


def get_status(set_status):
    '''
    set_status in ("3", "8", "10", "11", "12")
    return check_type, url_status
    url_status多条状态时，';'分隔
    '''
    if not set_status:
        # default OK
        return result_ok, "0"

    check_type = result_ok
    url_status = ""
    for status in set_status:
        url_status += "%s;" % status
        check_type = result_not_ok
        # "E"为异常错误，视为未检测
        if status == "E":
            return result_not_check, "0"
    if url_status:
        url_status = url_status[:-1]
    else:
        url_status = "0"

    return check_type, url_status


def main(path_shangbai_data, path_na_output, check_time):
    """
    statement
    """
    exit(run(path_shangbai_data, path_na_output, check_time))


if __name__ == "__main__":
    if len(sys.argv) != 4:
        # 商百数据, NA产出数据, NA产出数据的时间
        print >> sys.stderr, "%s shangbai_data na_output check_time" % sys.argv[0]
    else:
        main(sys.argv[1], sys.argv[2], sys.argv[3])





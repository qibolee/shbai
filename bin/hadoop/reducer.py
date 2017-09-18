#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : reducer.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/10
# Brief         : reducer
###########################################


__revision__ = '0.1'
import sys
import urllib




def main(path_bad_dict):
    '''
    statement
    '''
    dict_uid_url = {}
    with open(path_bad_dict) as file:
        # '\t': uid, url, tags
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))
            if len(ll) < 3:
                continue
            uid = ll[0]
            url = ll[1]
            tags = ll[2]

            if uid not in dict_uid_url:
                dict_uid_url[uid] = {}
            if url not in dict_uid_url[uid]:
                dict_uid_url[uid][url] = tags

    last_key = ""
    # total_chrg, pc_chrg, dead_chrg, alert_chrg, layer_chrg, apk_chrg
    list_chrg = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    for line in sys.stdin:
        # '\t': uid, url, charge
        line = line.strip()
        ll = map(lambda x:x.strip(), line.split("\t"))
        if len(ll) != 3:
            continue
        uid = ll[0]
        url = urllib.unquote(ll[1])
        chrg = int(ll[2])
        chrg /= 100.0

        if not last_key:
            last_key = uid
        if last_key != uid:
            print "\t".join([last_key] + map(lambda x:str(x), list_chrg))
            last_key = uid
            list_chrg = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

        list_chrg[0] += chrg
        if uid not in dict_uid_url or url not in dict_uid_url[uid]:
            continue
        if "[pcurl]" in dict_uid_url[uid][url]:
            list_chrg[1] += chrg
        if "[deadurl]" in dict_uid_url[uid][url] or "[dead]" in dict_uid_url[uid][url]:
            list_chrg[2] += chrg
        if "[alert]" in dict_uid_url[uid][url]:
            list_chrg[3] += chrg
        if "[layer]" in dict_uid_url[uid][url]:
            list_chrg[4] += chrg
        if "[apk]" in dict_uid_url[uid][url]:
            list_chrg[5] += chrg

    # last record
    if last_key:
        print "\t".join([last_key] + map(lambda x:str(x), list_chrg))

    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print >> sys.stderr, "argv error, python %s path_bad_dict" % sys.argv[0]
        exit(1)
    main(sys.argv[1])





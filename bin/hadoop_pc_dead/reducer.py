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




def main(path_mixer_full):
    '''
    statement
    '''
    dict_uid_url = {}
    with open(path_mixer_full) as file:
        # '\t': uid, url, url_sign, 0. 100, ...
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))
            if len(ll) < 2:
                continue
            uid = ll[0]
            url = ll[1]

            if uid not in dict_uid_url:
                dict_uid_url[uid] = set()
            if url not in dict_uid_url[uid]:
                dict_uid_url[uid].add(url)

    last_key = ""
    # total_chrg, bad_chrg
    list_chrg = [0.0, 0.0]
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
            list_chrg = [0.0, 0.0]

        list_chrg[0] += chrg
        if uid in dict_uid_url and url in dict_uid_url[uid]:
            list_chrg[1] += chrg

    # last record
    if last_key:
        print "\t".join([last_key] + map(lambda x:str(x), list_chrg))

    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print >> sys.stderr, "argv error, python %s path_mixer_full" % sys.argv[0]
        exit(1)
    main(sys.argv[1])





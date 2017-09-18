#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : check_alert_layer.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/8/04
# Brief         : static
###########################################


__revision__ = '0.1'
import sys





def run(path_alert_layer1, path_alert_layer2):
    
    dict_uid_url1 = {}
    dict_uid_url2 = {}
    total_uid1 = 0
    total_uid2 = 0
    total_url1 = 0
    total_url2 = 0
    join_uid = 0
    join_url = 0

    with open(path_alert_layer1) as file:
        # '\t': uid, url
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))
            if len(ll) < 2:
                continue
            uid = ll[0]
            url = ll[1]
            if uid not in dict_uid_url1:
                dict_uid_url1[uid] = set()
                total_uid1 += 1
            if url not in dict_uid_url1[uid]:
                dict_uid_url1[uid].add(url)
                total_url1 += 1

    with open(path_alert_layer2) as file:
        # '\t': uid, url
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))
            if len(ll) < 2:
                continue
            uid = ll[0]
            url = ll[1]
            if uid not in dict_uid_url2:
                dict_uid_url2[uid] = set()
                total_uid2 += 1
                # static join data
                if uid in dict_uid_url1:
                    join_uid += 1
            if url not in dict_uid_url2[uid]:
                dict_uid_url2[uid].add(url)
                total_url2 += 1
                # static join data
                if uid in dict_uid_url1 and url in dict_uid_url1[uid]:
                    join_url += 1

    print "total_uid1=%d" % total_uid1
    print "total_uid2=%d" % total_uid2
    print "total_url1=%d" % total_url1
    print "total_url2=%d" % total_url2
    print "join_uid=%d" % join_uid
    print "join_url=%d" % join_url

    return 0


def main(path_alert_layer1, path_alert_layer2):
    """
    statement
    """
    exit(run(path_alert_layer1, path_alert_layer2))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print >> sys.stderr, "error argv: python %s path_alert_layer1 path_alert_layer2" % sys.argv[0]
        exit(1)
    main(sys.argv[1], sys.argv[2])





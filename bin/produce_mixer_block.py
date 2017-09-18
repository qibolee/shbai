#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : produce_mixer_block.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/17
# Brief         : produce mixer block
###########################################


__revision__ = '0.1'
import sys
import sign


# userid
set_uid = set()
set_url = set()

def run(path_pc_dead, path_replace, path_slp_uid, path_white_url):
    '''
    输入:
        pc_dead dict, url维度 '\t': userid, url
        replace dict, userid维度 '\t': userid, url
        slp dict, '\t': uid
        white url, '\t': url, uid
    输出:
        '\t', uid, url, url_sign, 1, 0, 0, 100, 0
    '''
    with open(path_replace) as file:
        # '\t': userid, url
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))

            if len(ll) != 2:
                continue

            uid = ll[0]
            if uid:
                set_uid.add(uid)

    with open(path_slp_uid) as file:
        # '\t': userid
        for line in file:
            uid = line.strip()
            if uid:
                set_uid.add(uid)

    with open(path_white_url) as file:
        # '\t': url, uid, ...
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))
            if len(ll) != 2:
                continue
            url = ll[0]
            uid = ll[1]

            if url:
                set_url.add(url)

    with open(path_pc_dead) as file:
        # '\t': userid, url
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))

            if len(ll) != 2:
                continue

            uid = ll[0]
            url = ll[1]
            if uid in set_uid or url in set_url:
                # 有兜底页的user不纳入黑名单
                continue
            url_sign = get_url_sign(url)
            output_line = '\t'.join([uid, url, url_sign, "1", "0", "0", "100", "0"])
            print output_line

    return 0


def get_url_sign(url):
    '''
    去除协议头，计算url_sign
    '''
    url_process = url
    if url.startswith("http://"):
        url_process = url[7:]
    elif url.startswith("https://"):
        url_process = url[8:]
    url_sign = sign.creat_sign_fs64(url_process)
    return str(url_sign)


def main(path_pc_dead, path_replace, path_slp_uid, path_white_url):
    """
    statement
    """
    exit(run(path_pc_dead, path_replace, path_slp_uid, path_white_url))


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print >> sys.stderr, "python %s path_pc_dead, path_replace, path_slp_uid, path_white_url" % sys.argv[0]
        exit(1)
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])





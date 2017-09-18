#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : produce_pc_dead.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/19
# Brief         : generate online pc/dead block dict
###########################################


__revision__ = '0.1'
import sys
import mutil


# 白名单域名
set_white_domain = set()

# url检测结果不合格的类型，在此只关注pc/dead
status_dead = "3"
status_pc = "8"

def main(path_pc_dead, path_white_domain):
    '''
    input:
        path_pc_dead: '\t': userid, url, status
            status若有多个，以';'分割，这里肯定包含pc或dead
        path_white_domain: domain
    output: 
        '\t': userid, url
    '''
    with open(path_white_domain) as file:
        # 白名单域名，针对死链检测，若某一域名存在于白名单中，且被检测为死链，则不纳入最终的pc/死链屏蔽词表
        for line in file:
            domain = line.strip()
            set_white_domain.add(domain)

    with open(path_pc_dead) as file:
        # '\t': userid, url, status
        for line in file:
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("\t"))

            if len(ll) != 3:
                continue

            uid = ll[0]
            url = ll[1]
            status = ll[2]

            # 对不合格的user处理
            list_status = map(lambda x:x.strip(), status.split(";"))
            for st in list_status:
                if is_badurl(url, st):
                    print "%s\t%s" % (uid, url)
                    break

    return 0


def is_badurl(url, st):
    if st == status_pc:
        return True
    if st == status_dead and not is_white(url):
        return True
    return False


def is_white(url):
    '''
    该url是否在白名单中
    '''
    host = mutil.get_host(url)
    if host in set_white_domain:
        return True
    return False


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print >> sys.stderr, "python %s path_pc_dead path_white_domain" % sys.argv[0]
        exit(1)
    exit(main(sys.argv[1], sys.argv[2]))






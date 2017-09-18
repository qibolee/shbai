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


# ����������
set_white_domain = set()

# url��������ϸ�����ͣ��ڴ�ֻ��עpc/dead
status_dead = "3"
status_pc = "8"

def main(path_pc_dead, path_white_domain):
    '''
    input:
        path_pc_dead: '\t': userid, url, status
            status���ж������';'�ָ����϶�����pc��dead
        path_white_domain: domain
    output: 
        '\t': userid, url
    '''
    with open(path_white_domain) as file:
        # ���������������������⣬��ĳһ���������ڰ������У��ұ����Ϊ���������������յ�pc/�������δʱ�
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

            # �Բ��ϸ��user����
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
    ��url�Ƿ��ڰ�������
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






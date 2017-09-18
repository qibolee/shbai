#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : preprocess_shangbai.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/21
# Brief         : preprocess shangbai data
###########################################


__revision__ = '0.1'
import sys
import sign



def run():
    '''
    input: '\t': userid, url
    output: '\t': id, userid, url
    '''

    for line in sys.stdin:
        line = line.strip()
        ll = map(lambda x: x.strip(), line.split("\t"))

        if len(ll) != 2:
            continue
        uid = ll[0]
        url = ll[1]
        url_sign = get_url_sign(url)
        print "%s\t%s\t%s" % (url_sign, uid, url)
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


def main():
    '''
    statement
    '''
    exit(run())


if __name__ == "__main__":
    main()






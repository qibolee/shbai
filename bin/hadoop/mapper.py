#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : mapper.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/10
# Brief         : mapper
###########################################


__revision__ = '0.1'
import sys


def main():
    '''
    statement
    '''
    for line in sys.stdin:
        # '\t': 
        line = line.strip()
        ll = map(lambda x:x.strip(), line.split("\t"))
        if len(ll) < 18:
            continue
        uid = ll[10]
        url = ll[17]
        charge = ll[2]

        if int(charge) > 0:
            print "\t".join([uid, url, charge])

    return 0


if __name__ == "__main__":
    main()





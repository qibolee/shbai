#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : file.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/10
# Brief         : static
###########################################


__revision__ = '0.1'
import sys
import random


def run(num):
    input = sys.stdin.readlines()
    if num <= 0:
        return 0
    if num > len(input):
        num = len(input)
    result = random.sample(input, num)
    print "".join(result),

    return 0


def main(num):
    """
    statement
    """
    exit(run(num))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print >> sys.stderr, "%s num" % sys.argv[0]
        exit(1)
    main(int(sys.argv[1]))





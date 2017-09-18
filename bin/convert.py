#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : cobert.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/10
# Brief         : convert encode to another
###########################################


__revision__ = '0.1'
import sys


def run(from_encode, to_encode):

    for line in sys.stdin:
        # convert encode
        line = line.strip()
        line = line.decode(from_encode, "ignore")
        line = line.encode(to_encode, "ignore")
        print line

    return 0


def main(from_encode, to_encode):
    """
    statement
    """
    exit(run(from_encode, to_encode))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print >> sys.stderr, "error argv: python %s from_encode to_encode" % sys.argv[0]
        exit(1)
    main(sys.argv[1], sys.argv[2])








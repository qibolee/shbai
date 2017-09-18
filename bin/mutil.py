#!/usr/bin/env python
# -*- coding: gbk -*-
# Last modified: 

"""docstring
"""

__revision__ = '0.1'
import sys
import base64
import urllib
import re


set_http_protocol = set(["http:", "https:"])
pattern_host_port = re.compile(r"[0-9a-z-]+(\.[0-9a-z-]+)+(:[\d]+)?")


def decode_base64(data):
    """Decode base64, padding being optional.

    :param data: Base64 data as an ASCII byte string
    :returns: The decoded byte string.

    """
    missing_padding = 4 - len(data) % 4
    if missing_padding:
        data += b'='* missing_padding
    try:
        out = base64.decodestring(data)
        return out
    except:
        print >> sys.stderr, "base64 err!!!!"
        return None


def get_host(url):
    host, port = get_host_port(url)
    return host


def get_host_port(url):
    list_part = get_url_part(url)
    if len(list_part) < 3:
        return "-", "-"
    return list_part[1], list_part[2]
    """
    try:
        proto, rest = urllib.splittype(url)
        host_port, rest = urllib.splithost(rest)
        host, port = urllib.splitport(host_port)
    except TypeError:
        print >> sys.stderr, url
        host = None
    return host
    """


def get_url_part(url):
    '''
    input: url
    output: proto, host, port, part1, part2, ...

    '''
    url = url.strip()
    url = url.lower()
    list_part = map(lambda x:x.strip(), re.split("/+", url))
    stack_part = []
    proto = "http"
    for part in list_part:
        if not part or part == ".":
            continue
        elif part in set_http_protocol:
            proto = part[:-1]
        elif part == "..":
            if len(stack_part) > 1:
                del stack_part[-1]
        else:
            stack_part.append(part)
    if not stack_part:
        return []
    match = pattern_host_port.match(stack_part[0])
    if not match:
        return []
    host_port = match.group()
    ll = map(lambda x:x.strip(), host_port.split(":"))
    host = ll[0]
    port = ll[1] if len(ll) > 1 else "80"
    list_part = [proto, host, port]
    for part in stack_part[1:]:
        list_part.append(part)
    return list_part


def run():
    for line in sys.stdin:
        url = line.strip()
        parts = get_url_part(url)
        if not parts:
            print "-"
        else:
            print "\t".join(parts)


def main():
    exit(run())


if __name__ == "__main__":
    main()




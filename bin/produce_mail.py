#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################  
# File Name     : produce_mail.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/24
# Brief         : produce mail content
###########################################


__revision__ = '0.1'
import sys


key_pc_sample = "pc_sample"
key_dead_sample = "dead_sample"
key_trend1_base64 = "base64_trend_picture1"
key_trend2_base64 = "base64_trend_picture2"

def run(path_mail_template, path_mail_data, path_sample_pc, path_sample_dead, path_trend1_base64, path_trend2_base64):
    '''
    input:
        path_template: template file
        stdin: key=value
    output:
        template join k=v
    '''
    mail_content = ""
    with open(path_mail_template) as file:
        mail_content = file.readlines()
    if not mail_content:
        return 0
    mail_content = "".join(mail_content)

    sample_pc = []
    with open(path_sample_pc) as file:
        for line in file:
            url = line.strip()
            # <tr class='_3'><td>url</td></tr>
            sample_pc.append("<tr class='_3'><td style=\"width:500px;\">%s</td></tr>" % url)
    sample_pc = "\n".join(sample_pc)

    sample_dead = []
    with open(path_sample_dead) as file:
        for line in file:
            url = line.strip()
            # <tr class='_3'><td>url</td></tr>
            sample_dead.append("<tr class='_3'><td  style=\"width:500px;\">%s</td></tr>" % url)
    sample_dead = "\n".join(sample_dead)

    content_trend1_base64 = ""
    with open(path_trend1_base64) as file:
        content_trend1_base64 = file.readlines()
    content_trend1_base64 = "".join(content_trend1_base64)

    content_trend2_base64 = ""
    with open(path_trend2_base64) as file:
        content_trend2_base64 = file.readlines()
    content_trend2_base64 = "".join(content_trend2_base64)


    with open(path_mail_data) as file:
        for line in file:
            '''
            key=value
            '''
            line = line.strip()
            ll = map(lambda x:x.strip(), line.split("="))
            if len(ll) != 2:
                continue
            key = ll[0]
            value = ll[1]
            if key in mail_content:
                mail_content = mail_content.replace(key, value)
    
    mail_content = mail_content.replace(key_pc_sample, sample_pc)
    mail_content = mail_content.replace(key_dead_sample, sample_dead)
    mail_content = mail_content.replace(key_trend1_base64, content_trend1_base64)
    mail_content = mail_content.replace(key_trend2_base64, content_trend2_base64)

    print mail_content
    return 0


def main(path_mail_template, path_mail_data, path_sample_pc, path_sample_dead, path_trend1_base64, path_trend2_base64):
    '''
    statement
    '''
    exit(run(path_mail_template, path_mail_data, path_sample_pc, path_sample_dead, path_trend1_base64, path_trend2_base64))


if __name__ == "__main__":
    if len(sys.argv) != 7:
        # ${path_global_mail_template} ${path_mail_data} ${path_sample_dead100} ${path_sample_pc100} ${path_trend1_base64} ${path_trend2_base64}
        print >> sys.stderr, "argv error: python %s path_mail_template path_mail_data path_sample_pc path_sample_dead path_trend1_base64 path_trend2_base64" % sys.argv[0]
        exit(1)
    main(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6])





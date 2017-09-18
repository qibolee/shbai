#!/usr/bin/env python
# -*- coding: gbk -*-


###########################################
# File Name     : produce_trend.py
# Author        : liqibo(liqibo@baidu.com)
# Created Time  : 2017/7/25
# Brief         : produce a trend picture
###########################################



import numpy as np
import matplotlib.pyplot as plt
import sys
import os
import datetime


def pain(list_keys, list_keys2, list_values, list_labels, path_output):
    if not list_keys or not list_keys2 or not list_values or not list_labels:
        return 0
    plt.cla()
    for i in range(0, len(list_values)):
        key = list_keys
        value = list_values[i]
        label = list_labels[i]
        plt.plot(key, value, label=label, linewidth=2, marker='o', markersize=5)
    ymin, ymax = plt.ylim()
    plt.ylim(ymin * 0.9, ymax * 1.2)
    plt.xticks(list_keys, list_keys2)
    plt.xlabel("date")
    plt.ylabel("ratio (%)")
    plt.title("trend--last week")
    plt.legend(loc='upper left')
    plt.grid()
    plt.savefig(path_output, dpi=200)


def run(list_date, list_pc, list_dead, list_layer, list_alert, list_apk, path_output1, path_output2):
    list_range = range(0, len(list_date))
    list_values1 = [list_layer, list_alert]
    list_values2 = [list_pc, list_dead, list_apk]
    list_labels1 = ["layer", "alert"]
    list_labels2 = ["pc", "dead", "apk"]
    pain(list_range, list_date, list_values1, list_labels1, path_output1)
    pain(list_range, list_date, list_values2, list_labels2, path_output2)
    return 0


def main(static_date, path_output_file1, path_output_file2):
    list_path_file = []
    list_date = []
    now = datetime.datetime.strptime(static_date, '%Y%m%d')
    # 近7天趋势图
    for i in range(0, 7):
        delta=datetime.timedelta(days=i)
        static_date = (now - delta).strftime("%Y%m%d")
        path_file = "/home/work/shangbai/data/%s/mail_data" % static_date
        if os.path.isfile(path_file):
            list_path_file.append(path_file)
            static_date_month = static_date[-4:-2]
            static_date_day = static_date[-2:]
            list_date.append(static_date_month + "/" + static_date_day)
        else:
            print >> sys.stderr, "file missing, %s" % static_date
            break
    # 低于5天数据则不绘制趋势图
    if len(list_path_file) < 5:
        print >> sys.stderr, "data file to few: %d, generate trend failed" % len(list_path_file)
        return

    list_path_file.reverse()
    list_date.reverse()

    list_pc = []
    list_dead = []
    list_layer = []
    list_alert = []
    list_apk = []

    for path_file in list_path_file:
        with open(path_file) as file:
            for line in file:
                line = line.strip()
                ll = map(lambda x: x.strip(), line.split("="))
                if len(ll) != 2:
                    continue
                key = ll[0]
                value = ll[1]
                if key == "na_pcurl_ratio":
                    list_pc.append(value[:-1])
                elif key == "na_deadurl_ratio":
                    list_dead.append(value[:-1])
                elif key == "na_layer_ratio":
                    list_layer.append(value[:-1])
                elif key == "na_alert_ratio":
                    list_alert.append(value[:-1])
                elif key == "na_apk_ratio":
                    list_apk.append(value[:-1])

    print "pc:", list_pc
    print "dead:", list_dead
    print "layer:", list_layer
    print "alert", list_alert
    print "apk", list_apk

    exit(run(list_date, list_pc, list_dead, list_layer, list_alert, list_apk, path_output_file1, path_output_file2))


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print >> sys.stderr, "argv error: python %s static_date path_output_file1 path_output2" % sys.argv[0]
        exit(1)
    main(sys.argv[1], sys.argv[2], sys.argv[3])






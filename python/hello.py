#!/usr/bin/env python
# -*- coding: utf-8 -*-

def main():
    print "hello world"

    arr = ["a", "b", "c"]

    print arr[0]
    print arr[1]
    print arr[2]

    print "len = ", len(arr)

    print arr

    arr.insert(0, "0")
    arr.append("d")

    print arr

    arr.pop()
    print arr

    arr.pop(0)
    print arr

    for i in range(len(arr)):
        v = arr[i]
        print i, v

    d = {}
    d["a"] = "aa"
    d["b"] = "bb"
    d["c"] = "cc"

    print d.get("a") == None
    print d.get("d") == None

    print "for1"
    for k, v in d.items():
        print k, v

    items = d.items()
    print items

    sayHello()

    print "dist:", getDistance2(20, 20, 40, 40)
    getAddress("ChengDu")
    getAddress("BeiJing", "ZhangSan")
    getAddress("ShangHai", phone = "13880647739")

    fact(0)

def sayHello():
    print "hello world"

def getDistance2(x1, y1, x2, y2):
    return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)

def getAddress(city, name = "default", phone = "default"):
    print "address: city: %s, name: %s, phone: %s" % (city, name, phone)

def fact(n):
    if n >= 5:
        print "finish", n
        return n

    print "call n+1", n
    return fact(n + 1)

main()
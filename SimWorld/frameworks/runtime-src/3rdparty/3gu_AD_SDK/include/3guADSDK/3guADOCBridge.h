//
//  guADOCBridge.h
//  crazyBoom
//
//  Created by lovejia on 15/6/11.
//
//

#ifndef __crazyBoom__guADOCBridge__
#define __crazyBoom__guADOCBridge__

class SelectorObj {
public:
    virtual void callSelector(bool flag) = 0;
};

class _guADOCBridge {
public:
    static void popADByTollgate(int tid);
    static void popAD();
    static void popMoreAD();
};

void popADWithSelector(SelectorObj *obj, void (SelectorObj::*callSelector)(bool));
void popMoreADWithSelector(SelectorObj *obj, void (SelectorObj::*callSelector)(bool));

#endif /* defined(__crazyBoom__guADOCBridge__) */

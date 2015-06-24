
#ifndef __CC_EXTENSION_CCCRYPTO_H_
#define __CC_EXTENSION_CCCRYPTO_H_

#include "extra/cocos2dx_extra.h"

#include "CCLuaEngine.h"

NS_CC_EXTRA_BEGIN

class Crypto
{
public:
    static const int MD5_BUFFER_LENGTH = 16;

    /** @brief Calculate MD5, get MD5 code (not string) */
    static void MD5(void* input, int inputLength,
                    unsigned char* output);
    
    static void MD5File(const char* path, unsigned char* output);
    
    

    static const std::string MD5String(void* input, int inputLength);

    /** @brief Calculate MD5, return MD5 string */
    static LUA_STRING MD5Lua(const char* input, bool isRawOutput);

    static LUA_STRING MD5FileLua(const char* path);

private:
    Crypto(void) {}

    static char* bin2hex(unsigned char* bin, int binLength);
    
};

NS_CC_EXTRA_END

#endif // __CC_EXTENSION_CCCRYPTO_H_

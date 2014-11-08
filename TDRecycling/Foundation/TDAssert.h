//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#define TDAssert(condition) \
    _TDAssert((condition), #condition, __PRETTY_FUNCTION__, __FILE__, __LINE__);

#define TDAssertNeverExecuted() \
    _TDAssertionFailed("TDAssertNeverExecuted was executed", __PRETTY_FUNCTION__, __FILE__, __LINE__); \

int _TDAssert(int condition,
              const char* conditionStr,
              const char* function,
              const char* file,
              int line);

void _TDAssertionFailed(const char* conditionStr,
                        const char* function,
                        const char* file,
                        int line);

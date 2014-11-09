//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#ifdef TD_ASSERT_DEBUG
#   define TD_ASSERT_CURRENT_FILE __FILE__
#   define TD_ASSERT_CURRENT_FUNC __PRETTY_FUNCTION__
#else
#   define TD_ASSERT_CURRENT_FILE "hidden"
#   define TD_ASSERT_CURRENT_FUNC "hidden"
#endif

#define TDAssert(condition) \
    _TDAssert(!!(condition), #condition, TD_ASSERT_CURRENT_FUNC, TD_ASSERT_CURRENT_FILE, __LINE__)

#define TDAssertNeverExecuted() \
    _TDAssertionFailed("TDAssertNeverExecuted was executed", TD_ASSERT_CURRENT_FUNC, TD_ASSERT_CURRENT_FILE, __LINE__)

int _TDAssert(int condition,
              const char* conditionStr,
              const char* function,
              const char* file,
              int line);

void _TDAssertionFailed(const char* conditionStr,
                        const char* function,
                        const char* file,
                        int line);

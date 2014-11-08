//
// Licensed under the terms in LICENSE.txt
//
// Copyright 2014 Tom Dalling. All rights reserved.
//

#import "TDAssert.h"
@import Foundation;

int _TDAssert(int condition,
              const char* conditionStr,
              const char* function,
              const char* file,
              int line)
{
    if(!condition){
        _TDAssertionFailed(conditionStr, function, file, line);
    }

    return condition;
}

const char* TDLastPathComponent(const char* path) {
    size_t len = strlen(path);
    for(const char* c = path + len - 1; c >= path; --c){
        if(*c == '/'){
            return c + 1;
        }
    }
    return path;
}

void _TDAssertionFailed(const char* conditionStr,
                        const char* function,
                        const char* file,
                        int line)
{
    NSString* msg = [NSString stringWithFormat:
                     @"\n\n"
                     "==== Assertion Failed =========================\n"
                     "Condition: %s\n"
                     " Function: %s\n"
                     "     File: %s:%i\n\n",
                     conditionStr, function, TDLastPathComponent(file), line];
    NSLog(@"%@", msg);

    [[NSException exceptionWithName:@"TDAssertionFailedException"
                            reason:msg
                           userInfo:nil] raise];
}


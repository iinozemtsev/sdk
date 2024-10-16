/*
 * Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 */

#ifndef RUNTIME_PLATFORM_APPLE_FRAMEWORK_HEADER_DART_VM_H_
#define RUNTIME_PLATFORM_APPLE_FRAMEWORK_HEADER_DART_VM_H_

#import <Foundation/Foundation.h>

#define DART_DARWIN_EXPORT __attribute__((visibility("default")))

DART_DARWIN_EXPORT
@interface GeneratedForSendString : NSObject
{
  @public
  void* handle;
}

- (NSString*)GimmeString;

- (NSString*)Greet:(NSString*)name;

@end

DART_DARWIN_EXPORT
@interface DartVM : NSObject

- (bool)start;

- (GeneratedForSendString*)LoadGeneratedForSendString;

@end


#endif  // RUNTIME_PLATFORM_APPLE_FRAMEWORK_HEADER_DART_VM_H_

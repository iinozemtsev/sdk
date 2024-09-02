#import "runtime/platform/apple/framework/Headers/DartVM.h"

#include "runtime/bin/simple_embedder.h"
// #include "runtime/include/dart_embedder_api.h"

NSString* const kDefaultSnapshotPath =
    @"Frameworks/Dart.framework/assets/app.dill";

static NSString* GetKernelPath(NSBundle* bundle, NSString* snapshotPath) {
  return [bundle pathForResource:(snapshotPath ?: kDefaultSnapshotPath)
                          ofType:nil];
}

@implementation DartVM

- (bool)start {
  NSLog(@"Starting Dart VM");

  NSString* kernelPath = GetKernelPath([NSBundle mainBundle], nil);
  NSData* kernelData = [NSData dataWithContentsOfFile:kernelPath];
  NSLog(@"kernel path is %@", kernelPath);
  NSLog(@"kernel size is %lu",
        static_cast<unsigned long>([kernelData length]));

  char* error;
  if (!dart::embedder::simple::Run(static_cast<const char*>([kernelData bytes]), [kernelData length],
                                   &error)) {
    NSLog(@"Dart Error: %s", error);
    return false;
  }

  return true;
}

@end

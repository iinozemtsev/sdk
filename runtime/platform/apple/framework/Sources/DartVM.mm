#import "runtime/platform/apple/framework/Headers/DartVM.h"

#include "samples/embedder/generated_for_timer.h"
#include "runtime/easy_embedder/include/dart_easy_embedder_api.h"
// #include "runtime/include/dart_embedder_api.h"

NSString* const kDefaultSnapshotPath =
    @"Frameworks/Dart.framework/assets/app.dill";

static NSString* GetKernelPath(NSBundle* bundle, NSString* snapshotPath) {
  return [bundle pathForResource:(snapshotPath ?: kDefaultSnapshotPath)
                          ofType:nil];
}

@implementation GeneratedForEmbeddee

- (NSString*)GimmeString {
  char* retval = Dart_Timer_Greet((Dart_Timer)handle, "Ivan");
  NSString* result = [NSString stringWithUTF8String:retval];
  free(retval);
  return result;
}

- (NSString*)Greet:(NSString*)name {
  return @"Unimplemented";
}


@end

@implementation DartVM 

- (bool)start {
  return true;
}

- (GeneratedForEmbeddee*)LoadGeneratedForEmbeddee {
  NSString* kernelPath = GetKernelPath([NSBundle mainBundle], nil);
  NSData* kernelData = [NSData dataWithContentsOfFile:kernelPath];

  Dart_SnapshotData snapshot_data;

  snapshot_data.uri = strdup("file:///timer_kernel.dart.snapshot");
  snapshot_data.buffer = const_cast<uint8_t*>(static_cast<const uint8_t*>([kernelData bytes]));
  snapshot_data.buffer_size = [kernelData length];
  snapshot_data.kind = Dart_EE_SnapshotKind_Kernel;
  char* error = nullptr;
  Dart_Timer timer = Dart_Timer_Create(snapshot_data, &error);

  if (timer == nullptr) {
    NSLog(@"Dart Error: %s", error);
  }

  GeneratedForEmbeddee* result = [GeneratedForEmbeddee alloc];
  result->handle = timer;
  return result;
}

@end

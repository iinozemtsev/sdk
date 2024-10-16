#import "runtime/platform/apple/framework/Headers/DartVM.h"

#include "runtime/bin/simple_embedder.h"
// #include "runtime/include/dart_embedder_api.h"

NSString* const kDefaultSnapshotPath =
    @"Frameworks/Dart.framework/assets/app.dill";

static NSString* GetKernelPath(NSBundle* bundle, NSString* snapshotPath) {
  return [bundle pathForResource:(snapshotPath ?: kDefaultSnapshotPath)
                          ofType:nil];
}

@implementation GeneratedForSendString 

- (NSString*)GimmeString {
  dart::embedder::simple::DartResult<std::string> result = ((dart::embedder::simple::GeneratedForSendString*)handle)->gimmeString();
  if (result.is_error) {
    NSLog(@"Dart Error: %s", result.error.c_str());
    return nil;
  }
  return [NSString stringWithUTF8String:result.value.c_str()];
}

- (NSString*)Greet:(NSString*)name {
  return @"Unimplemented";
}


@end

@implementation DartVM {
  dart::embedder::simple::DartEmbedder* embedder;
}

- (bool)start {
  NSLog(@"Starting Dart VM");
  embedder = new dart::embedder::simple::DartEmbedder();
  char* error;
  if (!embedder->Init(&error)) {
    NSLog(@"Dart Error: %s", error);
    return false;
  }

  return true;
}

- (GeneratedForSendString*)LoadGeneratedForSendString {
  NSString* kernelPath = GetKernelPath([NSBundle mainBundle], nil);
  NSData* kernelData = [NSData dataWithContentsOfFile:kernelPath];

  dart::embedder::simple::SnapshotData* snapshot_data = new dart::embedder::simple::SnapshotData();
  snapshot_data->name = "sendString";
  snapshot_data->bytes = static_cast<const char*>([kernelData bytes]);
  snapshot_data->size = [kernelData length];
  char* error;
  dart::embedder::simple::IsolateHandle* isolate = embedder->IsolateGroupFromKernel(*snapshot_data, &error);

  if (isolate == nullptr) {
    NSLog(@"Dart Error: %s", error);
  }
  
  GeneratedForSendString* result = [GeneratedForSendString alloc];
  result->handle = new dart::embedder::simple::GeneratedForSendString(isolate);
  return result;
}

@end

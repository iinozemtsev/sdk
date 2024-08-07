// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "platform/globals.h"
#if (defined(DART_HOST_OS_LINUX) || defined(DART_HOST_OS_ANDROID)) &&          \
    !defined(DART_USE_ABSL)

#include "bin/thread.h"

#include <errno.h>         // NOLINT
#include <sys/resource.h>  // NOLINT
#include <sys/time.h>      // NOLINT

#include "platform/assert.h"
#include "platform/utils.h"

namespace dart {
namespace bin {

class ThreadStartData {
 public:
  ThreadStartData(const char* name,
                  Thread::ThreadStartFunction function,
                  uword parameter)
      : name_(name), function_(function), parameter_(parameter) {}

  const char* name() const { return name_; }
  Thread::ThreadStartFunction function() const { return function_; }
  uword parameter() const { return parameter_; }

 private:
  const char* name_;
  Thread::ThreadStartFunction function_;
  uword parameter_;

  DISALLOW_COPY_AND_ASSIGN(ThreadStartData);
};

// Dispatch to the thread start function provided by the caller. This trampoline
// is used to ensure that the thread is properly destroyed if the thread just
// exits.
static void* ThreadStart(void* data_ptr) {
  ThreadStartData* data = reinterpret_cast<ThreadStartData*>(data_ptr);

  const char* name = data->name();
  Thread::ThreadStartFunction function = data->function();
  uword parameter = data->parameter();
  delete data;

  // Set the thread name. There is 16 bytes limit on the name (including \0).
  // pthread_setname_np ignores names that are too long rather than truncating.
  char truncated_name[16];
  snprintf(truncated_name, sizeof(truncated_name), "%s", name);
  pthread_setname_np(pthread_self(), truncated_name);

  // Call the supplied thread start function handing it its parameters.
  function(parameter);

  return nullptr;
}

int Thread::Start(const char* name,
                  ThreadStartFunction function,
                  uword parameter) {
  pthread_attr_t attr;
  int result = pthread_attr_init(&attr);
  RETURN_ON_PTHREAD_FAILURE(result);

  result = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
  RETURN_ON_PTHREAD_FAILURE(result);

  result = pthread_attr_setstacksize(&attr, Thread::GetMaxStackSize());
  RETURN_ON_PTHREAD_FAILURE(result);

  ThreadStartData* data = new ThreadStartData(name, function, parameter);

  pthread_t tid;
  result = pthread_create(&tid, &attr, ThreadStart, data);
  RETURN_ON_PTHREAD_FAILURE(result);

  result = pthread_attr_destroy(&attr);
  RETURN_ON_PTHREAD_FAILURE(result);

  return 0;
}

intptr_t Thread::GetMaxStackSize() {
  const int kStackSize = (128 * kWordSize * KB);
  return kStackSize;
}

}  // namespace bin
}  // namespace dart

#endif  // (defined(DART_HOST_OS_LINUX) || defined(DART_HOST_OS_ANDROID)) &&   \
        // !defined(DART_USE_ABSL)

#include "include/dart_api.h"
#include "include/dart_engine.h"

// TODO: do we need it at all, maybe just store an isolate in a global
// variable? This would make an API simpler, but we won't be able to
// launch multiple copies of a snapshot.
typedef struct _Dart_Timer {
} _Dart_Timer;

typedef struct _Dart_Timer* Dart_Timer;

DART_EXPORT Dart_Timer Dart_Timer_Create(DartEngine_SnapshotData snapshot,
                                         char** error);
DART_EXPORT Dart_Timer Dart_Timer_CreateForPath(const char* snapshot_path,
                                                char** error);

DART_EXPORT void Dart_Timer_StartTimer(Dart_Timer timer, uint32_t millis);
DART_EXPORT void Dart_Timer_StopTimer(Dart_Timer timer);
DART_EXPORT int64_t Dart_Timer_GetTicks(Dart_Timer timer);

// Caller is responsible for freeing a string.
DART_EXPORT char* Dart_Timer_Greet(Dart_Timer timer, const char* person);

#include <_types/_uint64_t.h>
#include "bin/simple_embedder.h"
#include "include/dart_api.h"

namespace dart::send_string {

class GeneratedForSendString {
 public:
  GeneratedForSendString(const GeneratedForSendString&) = default;
  GeneratedForSendString(GeneratedForSendString&&) = default;
  GeneratedForSendString& operator=(const GeneratedForSendString&) = default;
  GeneratedForSendString& operator=(GeneratedForSendString&&) = default;
  GeneratedForSendString(embedder::simple::IsolateHandle* isolate)
      : isolate_(isolate){};

  dart::embedder::simple::IsolateHandle* isolate_;

  embedder::simple::DartResult<std::string> gimmeString() {
    std::string error;
    Dart_EnterIsolate(isolate_->isolate_);
    Dart_EnterScope();
    Dart_Handle invoke_result =
        Dart_Invoke(isolate_->library_,
                    Dart_NewStringFromCString("gimmeString"), 0, nullptr);
    if (Dart_IsError(invoke_result)) {
      error = Utils::StrDup(Dart_GetError(invoke_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::DartResult<std::string>::Error(error);
    }

    if (!Dart_IsString(invoke_result)) {
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::DartResult<std::string>::Error(
          "Return type is not string ");
    }

    const char* return_value;
    Dart_Handle to_string_result =
        Dart_StringToCString(invoke_result, &return_value);
    if (Dart_IsError(to_string_result)) {
      error = Utils::StrDup(Dart_GetError(to_string_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::DartResult<std::string>::Error(error);
    }
    auto result = embedder::simple::DartResult<std::string>::Success(
        std::string(return_value));
    Dart_ExitScope();
    Dart_ExitIsolate();
    return result;
  }

  embedder::simple::DartResult<std::string> greet(std::string_view person) {
    std::string error;
    Dart_EnterIsolate(isolate_->isolate_);
    Dart_EnterScope();
    std::initializer_list<Dart_Handle> args{
        Dart_NewStringFromCString(std::string(person).c_str())};
    Dart_Handle invoke_result =
        Dart_Invoke(isolate_->library_, Dart_NewStringFromCString("greet"),
                    args.size(), const_cast<Dart_Handle*>(args.begin()));
    if (Dart_IsError(invoke_result)) {
      error = Utils::StrDup(Dart_GetError(invoke_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::DartResult<std::string>::Error(error);
    }

    if (!Dart_IsString(invoke_result)) {
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::DartResult<std::string>::Error(
          "Return type is not string ");
    }

    const char* return_value;
    Dart_Handle dart_result =
        Dart_StringToCString(invoke_result, &return_value);
    if (Dart_IsError(dart_result)) {
      error = Utils::StrDup(Dart_GetError(dart_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::DartResult<std::string>::Error(error);
    }
    auto result = embedder::simple::DartResult<std::string>::Success(
        std::string(return_value));
    Dart_ExitScope();
    Dart_ExitIsolate();
    return result;
  }

  embedder::simple::DartResult<uint64_t> GetTicks() {
    std::string error;
    Dart_EnterIsolate(isolate_->isolate_);
    Dart_EnterScope();
    Dart_Handle invoke_result = Dart_Invoke(
        isolate_->library_, Dart_NewStringFromCString("getTicks"), 0, nullptr);
    if (Dart_IsError(invoke_result)) {
      error = Utils::StrDup(Dart_GetError(invoke_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::DartResult<uint64_t>::Error(error);
    }

    if (!Dart_IsInteger(invoke_result)) {
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::DartResult<uint64_t>::Error(
          "Return type is not int");
    }

    uint64_t return_value;
    Dart_Handle to_int_result =
        Dart_IntegerToUint64(invoke_result, &return_value);
    if (Dart_IsError(to_int_result)) {
      error = Utils::StrDup(Dart_GetError(to_int_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::DartResult<uint64_t>::Error(error);
    }
    auto result = embedder::simple::DartResult<uint64_t>::Success(return_value);
    Dart_ExitScope();
    Dart_ExitIsolate();
    return result;
  }

  embedder::simple::VoidDartResult StartTimer() {
    std::string error;
    Dart_EnterIsolate(isolate_->isolate_);
    Dart_EnterScope();
    Dart_Handle invoke_result =
        Dart_Invoke(isolate_->library_,
                    Dart_NewStringFromCString("startTicker"), 0, nullptr);
    if (Dart_IsError(invoke_result)) {
      error = Utils::StrDup(Dart_GetError(invoke_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::VoidDartResult::Error(error);
    }

    if (!Dart_IsNull(invoke_result)) {
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::VoidDartResult::Error("Return type is not int");
    }

    auto result = embedder::simple::VoidDartResult::Success();
    Dart_ExitScope();
    Dart_ExitIsolate();
    return result;
  }

  embedder::simple::VoidDartResult StopTimer() {
    std::string error;
    Dart_EnterIsolate(isolate_->isolate_);
    Dart_EnterScope();
    Dart_Handle invoke_result =
        Dart_Invoke(isolate_->library_,
                    Dart_NewStringFromCString("stopTicker"), 0, nullptr);
    if (Dart_IsError(invoke_result)) {
      error = Utils::StrDup(Dart_GetError(invoke_result));
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::VoidDartResult::Error(error);
    }

    if (!Dart_IsNull(invoke_result)) {
      Dart_ExitScope();
      Dart_ExitIsolate();
      return embedder::simple::VoidDartResult::Error("Return type is not int");
    }

    auto result = embedder::simple::VoidDartResult::Success();
    Dart_ExitScope();
    Dart_ExitIsolate();
    return result;
  }
};
}  // namespace dart::send_string

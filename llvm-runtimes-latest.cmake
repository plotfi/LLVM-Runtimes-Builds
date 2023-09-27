set(cmake_toolchains "${CMAKE_CURRENT_LIST_DIR}/../toolchains")

set(LLVM_BUILTIN_TARGETS
      aarch64-none-linux-android21
      armv7-none-linux-androideabi16
      i686-none-linux-android16
      x86_64-unknown-linux-gnu
      x86_64-none-linux-android21
      x86_64-unknown-windows-msvc
      x86_64-apple-darwin
    CACHE STRING "")

set(LLVM_RUNTIME_TARGETS
      aarch64-none-linux-android21
      armv7-none-linux-androideabi16
      i686-none-linux-android16
      x86_64-unknown-linux-gnu
      x86_64-none-linux-android21
      x86_64-unknown-windows-msvc
      x86_64-apple-darwin
    CACHE STRING "")


set(target x86_64-apple-darwin)
set(RUNTIMES_BUILD_ALLOW_DARWIN ON CACHE STRING "")
set(BUILTINS_${target}_CMAKE_SYSTEM_NAME Darwin CACHE STRING "") # LLVMExternalProjectUtils checks this
set(BUILTINS_${target}_CMAKE_TOOLCHAIN_FILE "${cmake_toolchains}/Toolchain-Darwin-universal.cmake" CACHE STRING "")
set(BUILTINS_${target}_XCODE_VERSION ${XCODE_VERSION} CACHE STRING "")
include(DarwinSDK)
set(BUILTINS_${target}_DARWIN_macosx_CACHED_SYSROOT "${macosx_sdk_path}" CACHE STRING "")
set(BUILTINS_${target}_DARWIN_iphoneos_CACHED_SYSROOT "${iphoneos_sdk_path}" CACHE STRING "")
set(BUILTINS_${target}_DARWIN_iphonesimulator_CACHED_SYSROOT "${iphonesimulator_sdk_path}" CACHE STRING "")
set(BUILTINS_${target}_DARWIN_watchos_CACHED_SYSROOT "${watchos_sdk_path}" CACHE STRING "")
set(BUILTINS_${target}_DARWIN_watchsimulator_CACHED_SYSROOT "${watchsimulator_sdk_path}" CACHE STRING "")
set(BUILTINS_${target}_DARWIN_osx_BUILTIN_ARCHS x86_64 arm64 CACHE STRING "")
# Rely on autodetection for now. If Apple upstreams arm64e then we can readd this.
# set(BUILTINS_${target}_DARWIN_ios_BUILTIN_ARCHS arm64 arm64e CACHE STRING "")
set(BUILTINS_${target}_DARWIN_iossim_BUILTIN_ARCHS x86_64 arm64 CACHE STRING "")
set(BUILTINS_${target}_COMPILER_RT_ENABLE_WATCHOS YES CACHE BOOL "")
# Hard-code these to the Xcode 12.5 versions for now, until https://reviews.llvm.org/D124557
# lands, to work around cross-compilation failures from failing to determine SDK versions.
set(BUILTINS_${target}_DARWIN_iphonesimulator_OVERRIDE_SDK_VERSION "14.5" CACHE STRING "")
set(BUILTINS_${target}_DARWIN_watchsimulator_OVERRIDE_SDK_VERSION "7.4" CACHE STRING "")
# The builtins configure checks for this being 10.7 or above in order to enable
# some security warnings. We can use 10.14 to match the runtimes configure below.
set(BUILTINS_${target}_DARWIN_macosx_OVERRIDE_SDK_VERSION "10.14" CACHE STRING "")
set(BUILTINS_${target}_COMPILER_RT_ENABLE_MACCATALYST ON CACHE BOOL "")

set(RUNTIMES_${target}_CMAKE_SYSTEM_NAME Darwin CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_TOOLCHAIN_FILE "${cmake_toolchains}/Toolchain-Darwin-universal.cmake" CACHE STRING "")
set(RUNTIMES_${target}_XCODE_VERSION ${XCODE_VERSION} CACHE STRING "")
set(RUNTIMES_${target}_DARWIN_macosx_CACHED_SYSROOT "${macosx_sdk_path}" CACHE STRING "")
set(RUNTIMES_${target}_DARWIN_iphoneos_CACHED_SYSROOT "${iphoneos_sdk_path}" CACHE STRING "")
set(RUNTIMES_${target}_DARWIN_iphonesimulator_CACHED_SYSROOT "${iphonesimulator_sdk_path}" CACHE STRING "")
set(RUNTIMES_${target}_DARWIN_watchos_CACHED_SYSROOT "${watchos_sdk_path}" CACHE STRING "")
set(RUNTIMES_${target}_DARWIN_watchsimulator_CACHED_SYSROOT "${watchsimulator_sdk_path}" CACHE STRING "")
set(RUNTIMES_${target}_COMPILER_RT_SANITIZERS_TO_BUILD asan cfi tsan ubsan_minimal CACHE STRING "")
set(RUNTIMES_${target}_DARWIN_osx_ARCHS x86_64 arm64 CACHE STRING "")
set(RUNTIMES_${target}_DARWIN_ios_ARCHS arm64 arm64e CACHE STRING "")
set(RUNTIMES_${target}_DARWIN_iossim_ARCHS x86_64 arm64 CACHE STRING "")
set(RUNTIMES_${target}_COMPILER_RT_BUILD_LIBFUZZER OFF CACHE BOOL "")
set(RUNTIMES_${target}_COMPILER_RT_ENABLE_MACCATALYST ON CACHE BOOL "")
if(ENABLE_LD64_LINKER)
  set(RUNTIMES_${target}_LLVM_USE_LINKER ld64 CACHE STRING "")
  # HACK: workaround LLVM trying to use ld64 without a Darwin target and
  # failing to find ld.ld64 (instead of ld64.ld64)
  set(RUNTIMES_${target}_CXX_SUPPORTS_CUSTOM_LINKER YES CACHE BOOL "")
endif()
# This needs to be at least 10.12 to build TSan. It's also used to disable
# building the i386 slice for macOS on 10.15 and above, but we don't build that
# slice anyway, so that's irrelevant for us.
set(RUNTIMES_${target}_DARWIN_macosx_OVERRIDE_SDK_VERSION "10.14" CACHE STRING "")
# TODO(t48839194) - isystem for xray needs to be added to not break Fuchsia
set(RUNTIMES_${target}_COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")


function(android_runtime target toolchain_file)
  set(BUILTINS_${target}_CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
  set(BUILTINS_${target}_CMAKE_TOOLCHAIN_FILE "${toolchain_file}" CACHE FILEPATH "")
  # Include the atomics in compiler-rt to match the NDK
  # https://android.googlesource.com/toolchain/llvm_android/+/99ac9d34479063805c5278877c2b263513aa59e4/builders.py#338
  set(BUILTINS_${target}_COMPILER_RT_EXCLUDE_ATOMIC_BUILTIN OFF CACHE BOOL "")
  set(BUILTINS_${target}_LLVM_ENABLE_PER_TARGET_RUNTIME_DIR OFF CACHE BOOL "")

  set(RUNTIMES_${target}_CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
  set(RUNTIMES_${target}_CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE BOOL "")
  set(RUNTIMES_${target}_CMAKE_TOOLCHAIN_FILE "${toolchain_file}" CACHE FILEPATH "")
  set(RUNTIMES_${target}_SANITIZER_CXX_ABI "libc++" CACHE STRING "")
  set(RUNTIMES_${target}_SANITIZER_CXX_ABI_INTREE ON CACHE BOOL "")
  set(RUNTIMES_${target}_COMPILER_RT_SANITIZERS_TO_BUILD asan cfi hwasan ubsan_minimal CACHE STRING "")
  set(RUNTIMES_${target}_COMPILER_RT_BUILD_XRAY ON CACHE BOOL "")
  set(RUNTIMES_${target}_COMPILER_RT_USE_BUILTINS_LIBRARY ON CACHE BOOL "")
  set(RUNTIMES_${target}_LIBUNWIND_ENABLE_SHARED YES CACHE BOOL "")
  set(RUNTIMES_${target}_LIBCXXABI_ENABLE_SHARED NO CACHE BOOL "")
  set(RUNTIMES_${target}_LIBCXX_ENABLE_ABI_LINKER_SCRIPT NO CACHE BOOL "")
  set(RUNTIMES_${target}_LIBCXX_ENABLE_STATIC_ABI_LIBRARY YES CACHE BOOL "")
  set(RUNTIMES_${target}_LIBCXX_ENABLE_STATIC NO CACHE BOOL "")
  set(RUNTIMES_${target}_LIBCXX_STATICALLY_LINK_ABI_IN_SHARED_LIBRARY YES CACHE BOOL "")
  set(RUNTIMES_${target}_LLVM_ENABLE_PER_TARGET_RUNTIME_DIR OFF CACHE BOOL "")
endfunction()

android_runtime(aarch64-none-linux-android21 "${cmake_toolchains}/Toolchain-android-aarch64.cmake")
set(BUILTINS_aarch64-none-linux-android21_COMPILER_RT_DISABLE_AARCH64_FMV ON CACHE BOOL "")

# Enable 128-bit compiler-rt functions for 32-bit targets because Rust relies on them (T120868527)
android_runtime(armv7-none-linux-androideabi16 "${cmake_toolchains}/Toolchain-android-armv7.cmake")
set(BUILTINS_armv7-none-linux-androideabi16_COMPILER_RT_ENABLE_SOFTWARE_INT128 ON CACHE BOOL "")

android_runtime(i686-none-linux-android16 "${cmake_toolchains}/Toolchain-android-x86.cmake")
set(BUILTINS_i686-none-linux-android16_COMPILER_RT_ENABLE_SOFTWARE_INT128 ON CACHE BOOL "")

android_runtime(x86_64-none-linux-android21 "${cmake_toolchains}/Toolchain-android-x86_64.cmake")


set(target x86_64-unknown-linux-gnu)
set(BUILTINS_${target}_CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
# We intentionally don't set CMAKE_SYSTEM_NAME to avoid CMake thinking we're cross-compiling.
# CMAKE_TOOLCHAIN_FILE should be set, but it causes issues running LLDB tests which need to be resolved first.
# https://fb.workplace.com/groups/toolchain.fndn/permalink/8723369431036847/
#set(BUILTINS_${target}_CMAKE_TOOLCHAIN_FILE "${cmake_toolchains}/Toolchain-${FBCODE_PLATFORM}.cmake" CACHE FILEPATH "")
set(BUILTINS_${target}_LLVM_ENABLE_PER_TARGET_RUNTIME_DIR NO CACHE BOOL "")

set(RUNTIMES_${target}_CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
# See above.
#set(RUNTIMES_${target}_CMAKE_TOOLCHAIN_FILE "${cmake_toolchains}/Toolchain-${FBCODE_PLATFORM}.cmake" CACHE FILEPATH "")
# The following two lines should be removed once we're setting CMAKE_TOOLCHAIN_FILE again.
find_program(FBPYTHON fbpython REQUIRED)
set(RUNTIMES_${target}_Python3_EXECUTABLE "${FBPYTHON}" CACHE FILEPATH "")
set(RUNTIMES_${target}_LLVM_ENABLE_ASSERTIONS ON CACHE BOOL "")
set(RUNTIMES_${target}_SANITIZER_CXX_ABI "libc++" CACHE STRING "")
set(RUNTIMES_${target}_SANITIZER_CXX_ABI_INTREE ON CACHE BOOL "")
# TODO(T164389888) - Remove `hwasan` from the following list after there is a solution to the problem mentioned in
# https://github.com/llvm/llvm-project/pull/66259?fbclid=IwAR1m2UwRnzsXb450ZCnD3eiR74U81P-Z3YkC_5jiFzAL0AD05I0HkqC_FBk#issuecomment-1726623392
set(RUNTIMES_${target}_COMPILER_RT_SANITIZERS_TO_BUILD "asan;cfi;hwasan;tsan;ubsan_minimal" CACHE STRING "")
# TODO(t48839194) - isystem for xray needs to be added to not break Fuchsia
set(RUNTIMES_${target}_COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
set(RUNTIMES_${target}_LIBCXX_ENABLE_TIME_ZONE_DATABASE OFF CACHE BOOL "")
set(RUNTIMES_${target}_CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE STRING "")


set(target x86_64-unknown-windows-msvc)
set(BUILTINS_${target}_CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
set(BUILTINS_${target}_CMAKE_SYSTEM_NAME Windows CACHE STRING "")
set(BUILTINS_${target}_CMAKE_TOOLCHAIN_FILE "${cmake_toolchains}/Toolchain-Windows-x86_64.cmake" CACHE FILEPATH "")
set(BUILTINS_${target}_LLVM_ENABLE_PER_TARGET_RUNTIME_DIR NO CACHE BOOL "")
if(VCToolsVersion)
  set(BUILTINS_${target}_VCToolsVersion ${VCToolsVersion} CACHE STRING "The MSVC version to use for builds")
endif()

set(RUNTIMES_${target}_CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_SYSTEM_NAME Windows CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_SYSROOT "" CACHE STRING "")
set(RUNTIMES_${target}_SANITIZER_CXX_ABI "libc++" CACHE STRING "")
set(RUNTIMES_${target}_LLVM_ENABLE_ASSERTIONS ON CACHE BOOL "")
set(RUNTIMES_${target}_SANITIZER_CXX_ABI_INTREE ON CACHE BOOL "")
# Disable this flag while the upstream change is still pending
# set(RUNTIMES_${target}_CMAKE_C_FLAGS "-Xclang -fno-split-cold-code" CACHE STRING "")
# set(RUNTIMES_${target}_CMAKE_CXX_FLAGS "-Xclang -fno-split-cold-code" CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_C_FLAGS "" CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_CXX_FLAGS "" CACHE STRING "")
set(RUNTIMES_${target}_COMPILER_RT_SANITIZERS_TO_BUILD "asan;cfi;tsan;ubsan_minimal" CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/../toolchains/Toolchain-Windows-x86_64.cmake" CACHE FILEPATH "")
# TODO(t48839194) - isystem for xray needs to be added to not break Fuchsia
set(RUNTIMES_${target}_COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
set(RUNTIMES_${target}_LLVM_ENABLE_RUNTIMES "libcxx;compiler-rt" CACHE STRING "")
set(RUNTIMES_${target}_CMAKE_BUILD_WITH_INSTALL_RPATH ON CACHE STRING "")
if(VCToolsVersion)
  set(RUNTIMES_${target}_VCToolsVersion ${VCToolsVersion} CACHE STRING "The MSVC version to use for builds")
endif()


# ensure that all required variables are set
foreach(target ${LLVM_BUILTIN_TARGETS})
  if(target STREQUAL x86_64-unknown-linux-gnu)
    # HACK: this intentionally doesn't set a toolchain for now to avoid LLDB
    # test issues (see above comments).
    continue()
  endif()

  if(BUILTINS_${target}_CMAKE_TOOLCHAIN_FILE)
    # The toolchain file will define all aspects of the target's build.
    continue()
  endif()

  foreach(variable CMAKE_SYSTEM_NAME CMAKE_SYSTEM_PROCESSOR CMAKE_SYSROOT CMAKE_C_FLAGS)
    if(NOT DEFINED BUILTINS_${target}_${variable})
      message(SEND_ERROR "${target} BUILTINS variable ${variable} is not set")
    endif()
  endforeach()
endforeach()

foreach(target ${LLVM_RUNTIME_TARGETS})
  if(target STREQUAL x86_64-unknown-linux-gnu)
    # HACK: see above.
    continue()
  endif()

  if(RUNTIMES_${target}_CMAKE_TOOLCHAIN_FILE)
    # The toolchain file will define all aspects of the target's build.
    continue()
  endif()

  foreach(variable CMAKE_SYSTEM_NAME CMAKE_SYSTEM_PROCESSOR CMAKE_SYSROOT CMAKE_C_FLAGS)
    if(NOT DEFINED RUNTIMES_${target}_${variable})
      message(SEND_ERROR "${target} RUNTIMES variable ${variable} is not set")
    endif()
  endforeach()
endforeach()

# Set the FACEBOOK CMake variable and pass any flags set by toolchain.mk. Note
# that cache files are only called during the initial configure, so this will
# only pick up on flags passed by toolchain.mk and any cache files included
# before it (which should only be the common toolchain cache file).
foreach(target ${LLVM_BUILTIN_TARGETS})
  set(BUILTINS_${target}_FACEBOOK YES CACHE BOOL "")
  set(BUILTINS_${target}_CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${BUILTINS_${target}_CMAKE_C_FLAGS}" CACHE BOOL "" FORCE)
  set(BUILTINS_${target}_CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${BUILTINS_${target}_CMAKE_CXX_FLAGS}" CACHE BOOL "" FORCE)
  set(BUILTINS_${target}_CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${BUILTINS_${target}_CMAKE_ASM_FLAGS}" CACHE BOOL "" FORCE)
  set(BUILTINS_${target}_USE_BUILT_BOOTSTRAP_TOOLCHAIN ${USE_BUILT_BOOTSTRAP_TOOLCHAIN} CACHE BOOL "" FORCE)
  set(BUILTINS_${target}_FBCODE_PLATFORM ${FBCODE_PLATFORM} CACHE STRING "" FORCE)
endforeach()
foreach(target ${LLVM_RUNTIME_TARGETS})
  set(RUNTIMES_${target}_FACEBOOK YES CACHE BOOL "")
  set(RUNTIMES_${target}_CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${RUNTIMES_${target}_CMAKE_C_FLAGS}" CACHE BOOL "" FORCE)
  set(RUNTIMES_${target}_CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${RUNTIMES_${target}_CMAKE_CXX_FLAGS}" CACHE BOOL "" FORCE)
  set(RUNTIMES_${target}_CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${RUNTIMES_${target}_CMAKE_ASM_FLAGS}" CACHE BOOL "" FORCE)
  set(RUNTIMES_${target}_USE_BUILT_BOOTSTRAP_TOOLCHAIN ${USE_BUILT_BOOTSTRAP_TOOLCHAIN} CACHE BOOL "" FORCE)
  set(RUNTIMES_${target}_FBCODE_PLATFORM ${FBCODE_PLATFORM} CACHE STRING "" FORCE)
  set(RUNTIMES_${target}_ENABLE_LD64_LINKER ${ENABLE_LD64_LINKER} CACHE STRING "" FORCE)
endforeach()

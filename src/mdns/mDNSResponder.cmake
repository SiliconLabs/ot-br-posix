#
#  Copyright (c) 2023, The OpenThread Authors.
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the copyright holder nor the
#     names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#
cmake_minimum_required(VERSION 3.11.4)

set(MDNS_RESPONDER_SOURCE_NAME mDNSResponder-1310.80.1)
include(FetchContent)

function(check_gnu_sed is_gnu_sed candidate_executable)

    # Check if the candidate can return a version string that contains "GNU"
    execute_process(
        COMMAND ${candidate_executable} --version | grep GNU
        RESULT_VARIABLE result
        OUTPUT_VARIABLE FOO)
    if(NOT result EQUAL 0)
        # Candidate is not GNU sed
        set(${is_gnu_sed} FALSE PARENT_SCOPE)
        message("${candidate_executable} is NOT GNU sed ")
    else()
        set(${is_gnu_sed} TRUE PARENT_SCOPE)
    endif()
endfunction()

message(STATUS "Detecting GNU sed")
find_program(GNU_SED_EXE
    NAMES gsed sed
    VALIDATOR check_gnu_sed
    REQUIRED TRUE
)
message(STATUS "Detecting GNU sed - done")
message(STATUS "Using GNU sed: ${GNU_SED_EXE}")

FetchContent_Declare(mDNSResponder
    DOWNLOAD_DIR        ${PROJECT_BINARY_DIR}/mDNSResponder
    TLS_VERIFY          OFF
    URL                 https://github.com/apple-oss-distributions/mDNSResponder/archive/refs/tags/${MDNS_RESPONDER_SOURCE_NAME}.tar.gz
    PATCH_COMMAND       cd Clients
    COMMAND             ${GNU_SED_EXE} -i "/#include <ctype.h>/a #include <stdarg.h>" dns-sd.c
    COMMAND             ${GNU_SED_EXE} -i "/#include <ctype.h>/a #include <sys/param.h>" dns-sd.c
    LOG_DOWNLOAD 1
    LOG_UPDATE 1
    LOG_CONFIGURE 1
    LOG_BUILD 1
    LOG_TEST 1
    LOG_INSTALL 1
)

FetchContent_MakeAvailable(mDNSResponder)
FetchContent_GetProperties(mDNSResponder SOURCE_DIR MDNS_RESPONDER_SOURCE_DIR)

add_library(mdnssd SHARED
    ${MDNS_RESPONDER_SOURCE_DIR}/mDNSShared/dnssd_clientlib.c
    ${MDNS_RESPONDER_SOURCE_DIR}/mDNSShared/dnssd_clientstub.c
    ${MDNS_RESPONDER_SOURCE_DIR}/mDNSShared/dnssd_ipc.c
)

target_include_directories(mdnssd
    PUBLIC
        ${MDNS_RESPONDER_SOURCE_DIR}/mDNSShared
)

target_compile_options(mdnssd PRIVATE
    -O2
    -g
    -W
    -Wall
    -fno-strict-aliasing
)

target_compile_definitions(mdnssd PRIVATE
    -D_GNU_SOURCE
    -DHAVE_IPV6
    -DNOT_HAVE_SA_LEN
    -DUSES_NETLINK
    -DTARGET_OS_LINUX
    -DHAVE_LINUX
    -DMDNS_DEBUGMSGS=0
)

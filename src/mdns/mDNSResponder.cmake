set(MDNS_RESPONDER_SOURCE_NAME mDNSResponder-1310.80.1)
include(FetchContent)

# set(my_LIBRARY ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}my${CMAKE_STATIC_LIBRARY_SUFFIX})

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
    PATCH_COMMAND       cd Clients && ${GNU_SED_EXE} -i "/#include <ctype.h>/a #include <stdarg.h>" dns-sd.c && ${GNU_SED_EXE} -i "/#include <ctype.h>/a #include <sys/param.h>" dns-sd.c
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

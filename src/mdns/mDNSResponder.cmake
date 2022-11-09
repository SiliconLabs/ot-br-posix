set(MDNS_RESPONDER_SOURCE_NAME mDNSResponder-1310.80.1)
include(FetchContent)

# set(my_LIBRARY ${CMAKE_INSTALL_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}my${CMAKE_STATIC_LIBRARY_SUFFIX})
find_program(SED NAMES gsed sed)
execute_process(
    COMMAND ${SED} --version
    RESULT_VARIABLE ret
    OUTPUT_VARIABLE out
)

if (NOT (ret EQUAL "0" AND out MATCHES ".*(GNU sed).*"))
    message(FATAL_ERROR
        "GNU sed is required\n"
        "Try installing using `brew`:\n"
        "    brew install gnu-sed\n\n")
endif()

FetchContent_Declare(mDNSResponder
    DOWNLOAD_DIR        ${PROJECT_BINARY_DIR}/mDNSResponder
    TLS_VERIFY          OFF
    URL                 https://github.com/apple-oss-distributions/mDNSResponder/archive/refs/tags/${MDNS_RESPONDER_SOURCE_NAME}.tar.gz
    PATCH_COMMAND       cd Clients
    COMMAND             ${SED} -i "/#include <ctype.h>/a #include <stdarg.h>" dns-sd.c
    COMMAND             ${SED} -i "/#include <ctype.h>/a #include <sys/param.h>" dns-sd.c
    COMMAND             mkdir -p ${CMAKE_SYSROOT}/lib ${CMAKE_SYSROOT}/include
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

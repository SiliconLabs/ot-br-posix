#
#  Copyright (c) 2020, The OpenThread Authors.
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

add_executable(otbr-test-unit
    $<$<BOOL:${OTBR_DBUS}>:test_dbus_message.cpp>
    $<$<STREQUAL:${OTBR_MDNS},"mDNSResponder">:test_mdns_mdnssd.cpp>
    main.cpp
    test_common_types.cpp
    test_dns_utils.cpp
    test_logging.cpp
    test_once_callback.cpp
    test_pskc.cpp
    test_task_runner.cpp
)
target_include_directories(otbr-test-unit PRIVATE
    ${CPPUTEST_INCLUDE_DIRS}
)
target_link_libraries(otbr-test-unit
    $<$<BOOL:${OTBR_DBUS}>:otbr-dbus-common>
    $<$<STREQUAL:${OTBR_MDNS},"mDNSResponder">:otbr-mdns>
    $<$<BOOL:${CPPUTEST_LIBRARY_DIRS}>:-L$<JOIN:${CPPUTEST_LIBRARY_DIRS}," -L">>
    ${CPPUTEST_LIBRARIES}
    mbedtls
    otbr-common
    otbr-utils
    pthread
)
add_test(
    NAME unit
    COMMAND otbr-test-unit
)

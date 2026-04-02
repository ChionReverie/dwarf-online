set(DFHACK_PLUGIN_DESTINATION plugins)

# dfhack_plugin(dwarf_online 
#     src/plugin.cpp
#     src/RequestQueue.cpp
#     LINK_LIBRARIES cpr::cpr -static
# )

find_package(OpenSSL REQUIRED)
# find_package(CURL)

# get_target_property(MY_CPR_SRC cpr::cpr PROJECT_SOURCE_DIR)
# get_target_property(MY_CPR_SOURCES cpr::cpr SOURCES)

# list(TRANSFORM MY_CPR_SOURCES PREPEND "${MY_CPR_SRC}/")
set(MY_CPR_SOURCES 
    accept_encoding.cpp
    async.cpp
    auth.cpp
    callback.cpp
    cert_info.cpp
    connection_pool.cpp
    cookies.cpp
    cprtypes.cpp
    curl_container.cpp
    curlholder.cpp
    error.cpp
    file.cpp
    multipart.cpp
    parameters.cpp
    payload.cpp
    proxies.cpp
    proxyauth.cpp
    session.cpp
    threadpool.cpp
    timeout.cpp
    unix_socket.cpp
    util.cpp
    response.cpp
    redirect.cpp
    interceptor.cpp
    ssl_ctx.cpp
    curlmultiholder.cpp
    multiperform.cpp)
list(TRANSFORM MY_CPR_SOURCES PREPEND "${cpr_SOURCE_DIR}/cpr/")

set(MY_CPR_HEADERS
    cpr/accept_encoding.h
    cpr/api.h
    cpr/async.h
    cpr/async_wrapper.h
    cpr/auth.h
    cpr/bearer.h
    cpr/body.h
    cpr/body_view.h
    cpr/buffer.h
    cpr/cert_info.h
    cpr/cookies.h
    cpr/cpr.h
    cpr/cprtypes.h
    cpr/curlholder.h
    cpr/curlholder.h
    cpr/error.h
    cpr/file.h
    cpr/limit_rate.h
    cpr/local_port.h
    cpr/local_port_range.h
    cpr/multipart.h
    cpr/parameters.h
    cpr/payload.h
    cpr/proxies.h
    cpr/proxyauth.h
    cpr/response.h
    cpr/secure_string.h
    cpr/session.h
    cpr/singleton.h
    cpr/ssl_ctx.h
    cpr/ssl_options.h
    cpr/threadpool.h
    cpr/timeout.h
    cpr/unix_socket.h
    cpr/util.h
    cpr/verbose.h
    cpr/interface.h
    cpr/redirect.h
    cpr/http_version.h
    cpr/interceptor.h
    cpr/filesystem.h
    cpr/curlmultiholder.h
    cpr/multiperform.h
    cpr/resolve.h
)
list(TRANSFORM MY_CPR_HEADERS PREPEND "${cpr_SOURCE_DIR}/include")

add_library(cpr_static
    STATIC
        ${MY_CPR_SOURCES}
        ${MY_CPR_INCLUDES}
        ${cpr_BINARY_DIR}/cpr_generated_includes/cpr/cprver.h

)
target_include_directories(cpr_static 
    PUBLIC
        "${cpr_SOURCE_DIR}/include"
        ${cpr_BINARY_DIR}/cpr_generated_includes
)

target_link_libraries(cpr_static
    INTERFACE $<INSTALL_INTERFACE:cpr>
    PRIVATE CURL::libcurl -static
)
set_target_properties(cpr_static PROPERTIES POSITION_INDEPENDENT_CODE TRUE)

add_library(dwarf_online
    src/plugin.cpp
    src/RequestQueue.cpp
)
target_link_libraries(dwarf_online 
    PRIVATE dfhack dfhack-version cpr_static
)
set_target_properties(dwarf_online
    PROPERTIES SUFFIX .plug.so PREFIX ""
)

# add_compile_options(dwarf_online 
#     PRIVATE 
#         -Wall -Wextra
# )


add_executable(dwarf_online_hello 
    src/hello.cpp
)
target_link_libraries(dwarf_online_hello cpr::cpr
)
# add_compile_options(hello 
#     PRIVATE 
#         -Wall -Wextra
# )


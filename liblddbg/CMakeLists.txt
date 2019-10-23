# create msg.c/msg.h

add_custom_command (
  OUTPUT msg.c msg.h
  COMMAND ${CMAKE_CURRENT_BINARY_DIR}/../sgsmsg/sgsmsg 
       -h ${CMAKE_CURRENT_BINARY_DIR}/msg.h
       -d ${CMAKE_CURRENT_BINARY_DIR}/msg.c
       -n liblddbg_msg
       -i ${CMAKE_CURRENT_SOURCE_DIR}/../sgsmsg/messages/sgs.ident
       ${CMAKE_CURRENT_SOURCE_DIR}/common/liblddbg.msg
    DEPENDS common/liblddbg.msg
)

set (COMSRC
   common/args.c
   common/audit.c
   common/basic.c
   common/debug.c
   common/syminfo.c
   common/tls.c
)

set (T3264
   bindings
   cap
   dlfcns
   dynamic
   elf
   entry
   files
   got
   libs
   map
   move
   phdr
   statistics
   support
   syms
   unused
   util
   version
)

set (COM32SRC ${T3264})
set (COM64SRC ${T3264})
set (BLTSRC msg.c)
set (SGSSRC sgscommon/alist.c)

list (TRANSFORM COM32SRC PREPEND common/)
list (TRANSFORM COM32SRC APPEND .c)
list (TRANSFORM COM64SRC APPEND 64.c)

foreach (x ${T3264})
  add_custom_command (
    OUTPUT ${x}64.c
    COMMAND cp
      ${CMAKE_CURRENT_SOURCE_DIR}/common/${x}.c
      ${CMAKE_CURRENT_BINARY_DIR}/${x}64.c
    DEPENDS common/${x}.c
  )
endforeach()

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/common)

set_source_files_properties (${COM64SRC} PROPERTIES COMPILE_FLAGS "-D_ELF64")

add_library(objlddbg OBJECT
  ${COMSRC}
  ${COM32SRC}
  ${COM64SRC}
  ${BLTSRC}
  ${SGSSRC}
)

add_library (lddbg STATIC $<TARGET_OBJECTS:objlddbg>)
target_link_libraries (lddbg libconv.a)

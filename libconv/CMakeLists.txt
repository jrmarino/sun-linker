set (COMSRC
  common/arch.c
  common/audit.c
  common/c_literal.c
  common/cap.c
  common/config.c
  common/corenote.c
  common/data.c
  common/deftag.c
  common/demangle.c
  common/dl.c
  common/dwarf.c
  common/dwarf_ehe.c
  common/dynamic.c
  common/elf.c
  common/entry.c
  common/globals.c
  common/group.c
  common/lddstub.c
  common/map.c
  common/phdr.c
  common/relocate.c
  common/relocate_amd64.c
  common/relocate_i386.c
  common/relocate_sparc.c
  common/sections.c
  common/segments.c
  common/strproc.c
  common/symbols.c
  common/syminfo.c
  common/time.c
  common/tokens.c
  common/version.c
)

set (COM32SRC
  common/cap_machelf32.c
  common/dynamic_machelf32.c
  common/globals_machelf32.c
  common/sections_machelf32.c
  common/symbols_machelf32.c
  common/symbols_sparc_machelf32.c
)

set (COM64SRC
  common/cap_machelf64.c
  common/dynamic_machelf64.c
  common/globals_machelf64.c
  common/sections_machelf64.c
  common/symbols_machelf64.c
  common/symbols_sparc_machelf64.c
)

set (MSGX
  arch audit c_literal cap config corenote data deftag
  demangle dl dwarf dwarf_ehe dynamic elf entry globals
  group map lddstub phdr relocate_amd64 relocate_i386
  relocate_sparc sections segments symbols symbols_sparc
  syminfo time version
)
set (BLTSRC ${MSGX})

list(TRANSFORM BLTSRC APPEND _msg.c)
list(TRANSFORM BLTSRC PREPEND ${CMAKE_CURRENT_BINARY_DIR}/)

set (ELFCAPSRC elfcap/elfcap.c)
set (ASMSRC vernote/vernote.s)

foreach (x ${MSGX})
  add_custom_command (
    OUTPUT ${x}_msg.c ${x}_msg.h
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/../sgsmsg/sgsmsg 
       -h ${CMAKE_CURRENT_BINARY_DIR}/${x}_msg.h 
       -d ${CMAKE_CURRENT_BINARY_DIR}/${x}_msg.c 
       -n sgs_msg_libconv_${x}
       ${CMAKE_CURRENT_SOURCE_DIR}/common/${x}.msg
    DEPENDS common/${x}.msg
  )
endforeach()

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/common)

set_source_files_properties (${COM64SRC} PROPERTIES COMPILE_FLAGS "-D_ELF64")

add_library(objconv OBJECT 
  ${COMSRC}
  ${COM32SRC}
  ${COM64SRC}
  ${BLTSRC}
  ${ELFCAPSRC}
  ${ASMSRC}
)

add_library (conv STATIC $<TARGET_OBJECTS:objconv>)

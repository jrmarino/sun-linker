cmake_minimum_required(VERSION 3.14)

project (sun_linker)

include_directories (include)

# build the libraries
add_subdirectory (sgsmsg)
add_subdirectory (libconv)
# add_subdirectory (libelf)
# add_subdirectory (libld)
# add_subdirectory (liblddbg)

# build the executable
# add_subdirectory (ld)

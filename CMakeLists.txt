cmake_minimum_required(VERSION 3.24)
project(Optimization CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_COLOR_DIAGNOSTICS ON)

### LTO ###

option(ENABLE_LTO "Enable Link-Time Optimization" OFF)
if(ENABLE_LTO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT result)
    if(result)
        message(STATUS "LTO/IPO is supported. Enabling it.")
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
        add_compile_options(-flto=auto)
        add_link_options(-flto=auto)
    else()
        message(WARNING "LTO/IPO is not supported by the compiler.")
    endif()
endif()

### PGO ###

set(PROFILE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/profiles)
set(PROFILE_FILE ${PROFILE_OUTPUT_DIR}/merged.profdata)

option(ENABLE_PGO_INSTRUMENTATION "Enable PGO instrumentation" OFF)
if(ENABLE_PGO_INSTRUMENTATION)
    add_compile_options(-fprofile-instr-generate)
    add_link_options(-fprofile-instr-generate)

    add_custom_target(run-pgo-instrumented
        COMMAND LLVM_PROFILE_FILE=${PROFILE_OUTPUT_DIR}/pgo-%p.profraw $<TARGET_FILE:app>
        COMMENT "Run the instrumented binary to generate profile data"
    )

    find_program(LLVM_PROFDATA_EXECUTABLE llvm-profdata)
    if(LLVM_PROFDATA_EXECUTABLE)
        add_custom_target(run-pgo-merge-profiles
            COMMAND ${LLVM_PROFDATA_EXECUTABLE} merge -output=${PROFILE_FILE} ${PROFILE_OUTPUT_DIR}/pgo-*.profraw
            COMMENT "Merge PGO profile data"
        )
    else()
        message(WARNING "llvm-profdata not found")
    endif()
endif()

option(ENABLE_PGO_USE "Enable PGO use" OFF)
if(ENABLE_PGO_USE)
    add_compile_options(-fprofile-instr-use=${PROFILE_FILE})
    add_link_options(-fprofile-instr-use=${PROFILE_FILE})
endif()

### EXAMPLE ###

add_executable(app
    example/main.cpp
    example/process.cpp
)
target_include_directories(app PRIVATE ${CMAKE_SOURCE_DIR}/example)

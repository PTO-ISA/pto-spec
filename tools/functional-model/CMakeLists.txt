cmake_minimum_required(VERSION 3.20)
project(PTOFunctionalModelExperimental LANGUAGES C CXX)

include(CTest)
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
find_package(Python3 REQUIRED COMPONENTS Interpreter)

option(PTO_FUNCTIONAL_MODEL_SANITIZERS
       "Build functional-model tests with AddressSanitizer and UBSan" OFF)

set(PTO_REPOSITORY_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../..")
set(PTO_GENERATED_ROOT "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(PTO_GENERATED_MIR "${PTO_GENERATED_ROOT}/pto-mir-v1.json")
set(PTO_GENERATED_EXECUTABLE_MIR
    "${PTO_GENERATED_ROOT}/pto-executable-mir-v1.json")
set(PTO_GENERATED_RUNTIME_HEADER
    "${PTO_GENERATED_ROOT}/pto_generated_runtime_image.h")
set(PTO_GENERATED_RUNTIME_SOURCE
    "${PTO_GENERATED_ROOT}/pto_generated_runtime_image.cpp")
set(PTO_GENERATED_RESET_SOURCE
    "${PTO_GENERATED_ROOT}/pto_generated_reset_image.cpp")
set(PTO_GENERATED_CASES_HEADER
    "${PTO_GENERATED_ROOT}/pto_generated_determine_length_cases.h")
set(PTO_GENERATED_DESCRIPTOR
    "${PTO_GENERATED_ROOT}/share/pto/model-descriptor.json")
set(PTO_GENERATED_DESCRIPTOR_READINESS
    "${PTO_GENERATED_ROOT}/descriptor-readiness.json")
set(PTO_GENERATED_DESCRIPTOR_HEADER
    "${PTO_GENERATED_ROOT}/pto_generated_descriptor.h")
set(PTO_GENERATED_DESCRIPTOR_SOURCE
    "${PTO_GENERATED_ROOT}/pto_generated_descriptor.cpp")

file(GLOB_RECURSE PTO_ASL_SOURCES CONFIGURE_DEPENDS
    "${PTO_REPOSITORY_ROOT}/asl/*.asl")

add_custom_command(
    OUTPUT
        "${PTO_GENERATED_MIR}"
        "${PTO_GENERATED_ROOT}/mir-readiness.json"
    COMMAND "${Python3_EXECUTABLE}"
            "${PTO_REPOSITORY_ROOT}/scripts/generate-functional-model-inventory"
            --output "${PTO_GENERATED_ROOT}/asl-constructs.json"
            --mir-output "${PTO_GENERATED_MIR}"
            --readiness-output "${PTO_GENERATED_ROOT}/mir-readiness.json"
    DEPENDS
        ${PTO_ASL_SOURCES}
        "${PTO_REPOSITORY_ROOT}/scripts/generate-functional-model-inventory"
        "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/pto_mir.py"
        "${PTO_REPOSITORY_ROOT}/spec/schemas/pto-mir-v1.schema.json"
    WORKING_DIRECTORY "${PTO_REPOSITORY_ROOT}"
    COMMENT "Generating complete PTO MIR input")

add_custom_command(
    OUTPUT
        "${PTO_GENERATED_EXECUTABLE_MIR}"
        "${PTO_GENERATED_ROOT}/executable-mir-readiness.json"
    COMMAND "${Python3_EXECUTABLE}"
            "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/generate-executable-mir"
            --input "${PTO_GENERATED_MIR}"
            --output "${PTO_GENERATED_EXECUTABLE_MIR}"
            --readiness-output
            "${PTO_GENERATED_ROOT}/executable-mir-readiness.json"
    DEPENDS
        "${PTO_GENERATED_MIR}"
        "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/generate-executable-mir"
        "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/pto_executable_mir.py"
        "${PTO_REPOSITORY_ROOT}/spec/schemas/pto-executable-mir-v1.schema.json"
    COMMENT "Generating complete executable PTO MIR")

add_custom_command(
    OUTPUT
        "${PTO_GENERATED_RUNTIME_HEADER}"
        "${PTO_GENERATED_RUNTIME_SOURCE}"
        "${PTO_GENERATED_RESET_SOURCE}"
        "${PTO_GENERATED_CASES_HEADER}"
    COMMAND "${Python3_EXECUTABLE}"
            "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/emit_runtime_image.py"
            --input "${PTO_GENERATED_EXECUTABLE_MIR}"
            --header "${PTO_GENERATED_RUNTIME_HEADER}"
            --source "${PTO_GENERATED_RUNTIME_SOURCE}"
            --reset-source "${PTO_GENERATED_RESET_SOURCE}"
            --cases
            "${CMAKE_CURRENT_SOURCE_DIR}/tests/determine_length_cases.json"
            --cases-header "${PTO_GENERATED_CASES_HEADER}"
    DEPENDS
        "${PTO_GENERATED_EXECUTABLE_MIR}"
        "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/emit_runtime_image.py"
        "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/runtime-capabilities-v1.json"
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/determine_length_cases.json"
    COMMENT "Lowering the real DeterminePTOInstructionLength entrypoint")

add_custom_command(
    OUTPUT
        "${PTO_GENERATED_DESCRIPTOR}"
        "${PTO_GENERATED_DESCRIPTOR_READINESS}"
    COMMAND "${Python3_EXECUTABLE}"
            "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/generate-descriptor"
            --pto-mir "${PTO_GENERATED_MIR}"
            --executable-image "${PTO_GENERATED_EXECUTABLE_MIR}"
            --mir-readiness "${PTO_GENERATED_ROOT}/mir-readiness.json"
            --executable-readiness
            "${PTO_GENERATED_ROOT}/executable-mir-readiness.json"
            --output "${PTO_GENERATED_DESCRIPTOR}"
            --readiness-output "${PTO_GENERATED_DESCRIPTOR_READINESS}"
    DEPENDS
        "${PTO_GENERATED_MIR}"
        "${PTO_GENERATED_EXECUTABLE_MIR}"
        "${PTO_GENERATED_ROOT}/mir-readiness.json"
        "${PTO_GENERATED_ROOT}/executable-mir-readiness.json"
        "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/generate-descriptor"
        "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/descriptor.py"
        "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/runtime-capabilities-v1.json"
        "${CMAKE_CURRENT_SOURCE_DIR}/include/pto/pto_asl_model.h"
        "${PTO_REPOSITORY_ROOT}/spec/release-manifest.json"
        "${PTO_REPOSITORY_ROOT}/spec/schemas/pto-functional-model-descriptor-v1.schema.json"
    WORKING_DIRECTORY "${PTO_REPOSITORY_ROOT}"
    COMMENT "Generating clean-tree functional-model descriptor")

add_custom_command(
    OUTPUT
        "${PTO_GENERATED_DESCRIPTOR_HEADER}"
        "${PTO_GENERATED_DESCRIPTOR_SOURCE}"
    COMMAND "${Python3_EXECUTABLE}"
            "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/embed_descriptor.py"
            --input "${PTO_GENERATED_DESCRIPTOR}"
            --header "${PTO_GENERATED_DESCRIPTOR_HEADER}"
            --source "${PTO_GENERATED_DESCRIPTOR_SOURCE}"
    DEPENDS
        "${PTO_GENERATED_DESCRIPTOR}"
        "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/embed_descriptor.py"
    COMMENT "Embedding functional-model descriptor identity")

add_library(pto_asl_model STATIC
    "${PTO_GENERATED_DESCRIPTOR_SOURCE}"
    "${PTO_GENERATED_RUNTIME_SOURCE}"
    "${PTO_GENERATED_RESET_SOURCE}"
    runtime/c_api.cpp
    runtime/interpreter.cpp
    runtime/module.cpp
    runtime/runtime_model.cpp
    runtime/transaction.cpp
    runtime/value.cpp)
target_compile_features(pto_asl_model PUBLIC cxx_std_20)
target_include_directories(pto_asl_model
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    PRIVATE runtime "${PTO_GENERATED_ROOT}")
target_compile_options(pto_asl_model PRIVATE
    -Wall -Wextra -Wpedantic -Werror)

if(PTO_FUNCTIONAL_MODEL_SANITIZERS AND
   CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    target_compile_options(pto_asl_model PRIVATE
        -fsanitize=address,undefined -fno-omit-frame-pointer)
    target_link_options(pto_asl_model PUBLIC -fsanitize=address,undefined)
endif()

install(TARGETS pto_asl_model
    EXPORT PTOASLModelTargets
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")
install(DIRECTORY include/ DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
install(FILES "${PTO_GENERATED_DESCRIPTOR}"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/pto")
install(EXPORT PTOASLModelTargets
    FILE PTOASLModelTargets.cmake
    NAMESPACE PTOASLModel::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/PTOASLModel")

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/PTOASLModelConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/PTOASLModelConfig.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/PTOASLModel")
write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/PTOASLModelConfigVersion.cmake"
    VERSION 0.3.1
    COMPATIBILITY ExactVersion)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/PTOASLModelConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/PTOASLModelConfigVersion.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/PTOASLModel")

if(BUILD_TESTING)
    add_executable(pto_asl_model_abi_c_test tests/abi_c.c)
    target_link_libraries(pto_asl_model_abi_c_test PRIVATE pto_asl_model)
    target_compile_options(pto_asl_model_abi_c_test PRIVATE
        -Wall -Wextra -Wpedantic -Werror)

    add_executable(pto_asl_model_abi_cpp_test tests/abi_cpp.cpp)
    target_link_libraries(pto_asl_model_abi_cpp_test PRIVATE pto_asl_model)
    target_compile_options(pto_asl_model_abi_cpp_test PRIVATE
        -Wall -Wextra -Wpedantic -Werror)

    add_executable(pto_asl_model_runtime_test tests/runtime_tests.cpp)
    target_include_directories(pto_asl_model_runtime_test PRIVATE
        runtime "${PTO_GENERATED_ROOT}")
    target_link_libraries(pto_asl_model_runtime_test PRIVATE pto_asl_model)
    target_compile_options(pto_asl_model_runtime_test PRIVATE
        -Wall -Wextra -Wpedantic -Werror)

    if(PTO_FUNCTIONAL_MODEL_SANITIZERS AND
       CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        foreach(test_target IN ITEMS
                pto_asl_model_abi_c_test
                pto_asl_model_abi_cpp_test
                pto_asl_model_runtime_test)
            target_compile_options(${test_target} PRIVATE
                -fsanitize=address,undefined -fno-omit-frame-pointer)
        endforeach()
    endif()

    add_test(NAME pto_asl_model_abi_c COMMAND pto_asl_model_abi_c_test)
    add_test(NAME pto_asl_model_abi_cpp COMMAND pto_asl_model_abi_cpp_test)
    add_test(NAME pto_asl_model_runtime COMMAND pto_asl_model_runtime_test)
    add_test(
        NAME pto_asl_model_runtime_emitter
        COMMAND "${Python3_EXECUTABLE}"
                "${CMAKE_CURRENT_SOURCE_DIR}/tests/test_runtime_image_emitter.py"
                --emitter
                "${CMAKE_CURRENT_SOURCE_DIR}/modelgen/emit_runtime_image.py"
                --image "${PTO_GENERATED_EXECUTABLE_MIR}"
                --cases
                "${CMAKE_CURRENT_SOURCE_DIR}/tests/determine_length_cases.json")
    add_test(
        NAME pto_asl_model_install_package
        COMMAND "${Python3_EXECUTABLE}"
                "${CMAKE_CURRENT_SOURCE_DIR}/tests/test_install_package.py"
                --cmake "${CMAKE_COMMAND}"
                --build-dir "${CMAKE_CURRENT_BINARY_DIR}"
                --consumer "${CMAKE_CURRENT_SOURCE_DIR}/tests/package_consumer")
endif()

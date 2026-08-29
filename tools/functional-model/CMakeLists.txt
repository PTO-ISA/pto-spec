cmake_minimum_required(VERSION 3.20)
project(PTOFunctionalModelExperimental LANGUAGES C CXX)

include(CTest)

option(PTO_FUNCTIONAL_MODEL_SANITIZERS
       "Build functional-model tests with AddressSanitizer and UBSan" OFF)

add_library(pto_asl_model STATIC
    runtime/c_api.cpp
    runtime/interpreter.cpp
    runtime/module.cpp
    runtime/runtime_model.cpp
    runtime/transaction.cpp
    runtime/value.cpp)
target_compile_features(pto_asl_model PUBLIC cxx_std_20)
target_include_directories(pto_asl_model
    PUBLIC include
    PRIVATE runtime)
target_compile_options(pto_asl_model PRIVATE
    -Wall -Wextra -Wpedantic -Werror)

if(PTO_FUNCTIONAL_MODEL_SANITIZERS AND
   CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
    target_compile_options(pto_asl_model PRIVATE
        -fsanitize=address,undefined -fno-omit-frame-pointer)
    target_link_options(pto_asl_model PUBLIC -fsanitize=address,undefined)
endif()

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
    target_include_directories(pto_asl_model_runtime_test PRIVATE runtime)
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
endif()

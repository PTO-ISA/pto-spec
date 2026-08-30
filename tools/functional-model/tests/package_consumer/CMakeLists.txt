cmake_minimum_required(VERSION 3.20)
project(PTOASLModelPackageConsumer LANGUAGES C CXX)

find_package(PTOASLModel 0.3.2 EXACT REQUIRED CONFIG)

add_executable(package_consumer_c consumer.c)
target_link_libraries(package_consumer_c PRIVATE PTOASLModel::pto_asl_model)
target_compile_options(package_consumer_c PRIVATE -Wall -Wextra -Wpedantic -Werror)

add_executable(package_consumer_cpp consumer.cpp)
target_link_libraries(package_consumer_cpp PRIVATE PTOASLModel::pto_asl_model)
target_compile_options(package_consumer_cpp PRIVATE -Wall -Wextra -Wpedantic -Werror)

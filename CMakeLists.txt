cmake_minimum_required(VERSION 3.21)
project(
  sample-grpc
  LANGUAGES CXX
  VERSION 1.0
  DESCRIPTION "A sample gRPC project"
)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 --coverage -fno-inline -fno-inline-small-functions -fno-default-inline")

# gRPC and Protocol Buffers settings
find_package(Protobuf REQUIRED)
find_package(gRPC REQUIRED)
# find_package(OpenSSL CONFIG REQUIRED)

message(STATUS "Using protobuf: ${Protobuf_VERSION}")

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(GNUInstallDirs)


# Define .proto files
file(GLOB_RECURSE PROTO_FILES ${CMAKE_SOURCE_DIR}/src/proto/*.proto)

set(PROTO_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
set(PROTO_IMPORT_DIRS "${CMAKE_SOURCE_DIR}/src/proto")

# Add the include directory for Protobuf
list(APPEND PROTO_IMPORT_DIRS ${Protobuf_INCLUDE_DIRS})

# Add library of code generated from .proto files
add_library(${PROJECT_NAME}-grpc-lib OBJECT ${PROTO_FILES})
get_target_property(grpc_cpp_plugin_location gRPC::grpc_cpp_plugin LOCATION)
message(STATUS "gRPC C++ plugin location: ${grpc_cpp_plugin_location}")
# Generate protobuf code
protobuf_generate(
  TARGET ${PROJECT_NAME}-grpc-lib
  LANGUAGE cpp
  IMPORT_DIRS ${PROTO_IMPORT_DIRS}
  OUT_VAR ${PROJECT_NAME}-proto-srcs
)
message(STATUS "Generated protobuf sources: ${${PROJECT_NAME}-proto-srcs}")
# Generate gRPC code
protobuf_generate(
  TARGET ${PROJECT_NAME}-grpc-lib
  LANGUAGE grpc
  GENERATE_EXTENSIONS .grpc.pb.h .grpc.pb.cc
  PLUGIN "protoc-gen-grpc=${grpc_cpp_plugin_location}"
  PLUGIN_OPTIONS "generate_mock_code=true"
  IMPORT_DIRS ${PROTO_IMPORT_DIRS}
  OUT_VAR ${PROJECT_NAME}-grpc-srcs
)
message(STATUS "Generated gRPC sources: ${${PROJECT_NAME}-grpc-srcs}")
target_link_libraries(
  ${PROJECT_NAME}-grpc-lib PUBLIC protobuf::libprotobuf gRPC::grpc++
)
target_include_directories(
  ${PROJECT_NAME}-grpc-lib
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${_INCLUDE_PREFIX}>
)

# Add client app
add_executable(${PROJECT_NAME}
  src/main.cpp
  src/client.cpp
  src/client.hpp
)
target_link_libraries(${PROJECT_NAME}
  ${PROJECT_NAME}-grpc-lib
)

install(
  TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Enable testing
find_package(GTest REQUIRED)
enable_testing()
add_executable(${PROJECT_NAME}-test
  test/test_client.cpp
  src/client.cpp
)
add_dependencies(${PROJECT_NAME}-test ${PROJECT_NAME}-grpc-lib)
target_include_directories(${PROJECT_NAME}-test
  PRIVATE ${CMAKE_SOURCE_DIR}/src
)
target_link_libraries(${PROJECT_NAME}-test
  PRIVATE
    GTest::GTest
    GTest::Main
    GTest::gmock
    ${PROJECT_NAME}-grpc-lib
)

# Add test to CMake
add_test(NAME ${PROJECT_NAME}-test COMMAND ${PROJECT_NAME}-test)

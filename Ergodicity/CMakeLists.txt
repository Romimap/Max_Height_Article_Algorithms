cmake_minimum_required(VERSION 2.8)                            
project(Ergodicity)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)


#Open CV
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})


#Open MP
find_package(OpenMP)
if (OPENMP_FOUND)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
endif()


include_directories(${PROJECT_SOURCE_DIR})
add_executable(Ergodicity "src/main.cpp")


target_link_libraries (Ergodicity ${OpenCV_LIBS})         


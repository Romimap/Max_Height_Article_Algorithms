cmake_minimum_required(VERSION 2.8)                            
project(Ergodicity)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

#Set the two textures to test here (only works for .png files)
set(T1 Forest.png)
set(T2 Paving.png)

#Open CV
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})


#Open MP
find_package(OpenMP)
if (OPENMP_FOUND)
    set (CMAKE_C_FLAGS ${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS})
    set (CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS})
    set (CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS})
endif()

include_directories(${PROJECT_SOURCE_DIR} /usr/include/opencv4 /usr/include)
add_executable(Ergodicity src/main.cpp)

add_custom_target(build-time-make-directory ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/bin/out)

add_custom_command(
    TARGET Ergodicity POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/textures/${T1}
            ${CMAKE_BINARY_DIR}/bin/textures/T1.png)

add_custom_command(
    TARGET Ergodicity POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/textures/${T2}
            ${CMAKE_BINARY_DIR}/bin/textures/T2.png)
            


target_link_libraries (Ergodicity ${OpenCV_LIBS})         


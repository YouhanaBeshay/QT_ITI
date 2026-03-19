cmake_minimum_required(VERSION 3.15)

project(mygpio)

add_library(mygpio SHARED mygpio.cpp)

target_include_directories(mygpio PUBLIC ${CMAKE_CURRENT_LIST_DIR})
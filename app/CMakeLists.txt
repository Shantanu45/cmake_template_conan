add_executable(${PROJECT_NAME} main.cpp
)

target_link_libraries(
  ${PROJECT_NAME}
  PRIVATE cmake_template_project::cmake_template_project_options
          cmake_template_project::cmake_template_project_warnings
          CLI11::CLI11
          fmt::fmt
          spdlog::spdlog)


cmake_template_project_configure_linker(${PROJECT_NAME})

target_include_directories(${PROJECT_NAME} PRIVATE
  "${CMAKE_BINARY_DIR}/generated/include"
  "${CMAKE_SOURCE_DIR}/include"
  "${CMAKE_SOURCE_DIR}/app")

# Apply WASM-specific configuration
if(EMSCRIPTEN)
  cmake_template_project_configure_wasm_target(${PROJECT_NAME}
    TITLE "${PROJECT_NAME}"
    DESCRIPTION "${PROJECT_DESCRIPTION}"
  )
endif()

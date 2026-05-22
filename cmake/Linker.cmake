macro(cmake_template_project_configure_linker project_name)
  set(cmake_template_project_USER_LINKER_OPTION
    "DEFAULT"
      CACHE STRING "Linker to be used")
    set(cmake_template_project_USER_LINKER_OPTION_VALUES "DEFAULT" "SYSTEM" "LLD" "GOLD" "BFD" "MOLD" "SOLD" "APPLE_CLASSIC" "MSVC")
  set_property(CACHE cmake_template_project_USER_LINKER_OPTION PROPERTY STRINGS ${cmake_template_project_USER_LINKER_OPTION_VALUES})
  list(
    FIND
    cmake_template_project_USER_LINKER_OPTION_VALUES
    ${cmake_template_project_USER_LINKER_OPTION}
    cmake_template_project_USER_LINKER_OPTION_INDEX)

  if(${cmake_template_project_USER_LINKER_OPTION_INDEX} EQUAL -1)
    message(
      STATUS
        "Using custom linker: '${cmake_template_project_USER_LINKER_OPTION}', explicitly supported entries are ${cmake_template_project_USER_LINKER_OPTION_VALUES}")
  endif()

  set_target_properties(${project_name} PROPERTIES LINKER_TYPE "${cmake_template_project_USER_LINKER_OPTION}")
endmacro()

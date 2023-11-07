CLASS lcl_tvarvc_util DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS get_select_options
      IMPORTING variable_name TYPE sychar30
      RETURNING VALUE(return) TYPE oij_el_range_t.

ENDCLASS.

CLASS lcl_tvarvc_util IMPLEMENTATION.
  METHOD get_select_options.
    "Return select-option and parameter as select-options
    SELECT FROM tvarvc FIELDS
    CASE type
    WHEN 'S' THEN sign
    WHEN 'P' THEN 'I'
    END AS sign,
    CASE type
    WHEN 'S' THEN opti
    WHEN 'P' THEN 'EQ'
    END AS option,
    low, high
    WHERE name = @variable_name
    INTO CORRESPONDING FIELDS OF TABLE @return.
  ENDMETHOD.
ENDCLASS.
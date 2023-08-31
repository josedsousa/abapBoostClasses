CLASS lcl_salv DEFINITION FINAL.
    PUBLIC SECTION.
      METHODS constructor
        IMPORTING salv_data TYPE table
        RAISING   cx_salv_msg.
  
      METHODS set_all_functions.
  
      METHODS optimize_columns.
  
      METHODS set_icon
        IMPORTING column_name TYPE lvc_fname
        RAISING   cx_salv_not_found.
  
      METHODS set_column_texts
        IMPORTING column_name TYPE lvc_fname
                  !short      TYPE scrtext_s
                  !medium     TYPE SCRTEXT_m OPTIONAL
                  !long       TYPE SCRTEXT_l OPTIONAL
        RAISING   cx_salv_not_found.
  
      METHODS display.
  
    PRIVATE SECTION.
      DATA output_data TYPE REF TO data.
      DATA table       TYPE REF TO cl_salv_table.
      DATA columns     TYPE REF TO cl_salv_columns_table.
      DATA functions   TYPE REF TO cl_salv_functions.
  
  ENDCLASS.
  
  
  CLASS lcl_salv IMPLEMENTATION.
    METHOD constructor.
      CREATE DATA me->output_data LIKE salv_data.
      ASSIGN me->output_data->* TO FIELD-SYMBOL(<me_salv_data>).
      <me_salv_data> = salv_data.
  
      cl_salv_table=>factory( IMPORTING r_salv_table = table
                              CHANGING  t_table      = <me_salv_data> ).
  
      columns = table->get_columns( ).
      functions = table->get_functions( ).
    ENDMETHOD.
  
    METHOD set_all_functions.
      functions->set_all( ).
    ENDMETHOD.
  
    METHOD optimize_columns.
      columns->set_optimize( ).
    ENDMETHOD.
  
    METHOD set_column_texts.
      DATA column TYPE REF TO cl_salv_column_table.
  
      column ?= columns->get_column( column_name ).
      column->set_short_text( short ).
  
      IF medium IS INITIAL.
        column->set_medium_text( CONV #( short ) ).
      ELSE.
        column->set_medium_text( medium ).
      ENDIF.
  
      IF long IS INITIAL.
        column->set_long_text( CONV #( short ) ).
      ELSE.
        column->set_long_text( long ).
      ENDIF.
    ENDMETHOD.
  
    METHOD display.
      table->display( ).
    ENDMETHOD.
  
    METHOD set_icon.
      DATA column TYPE REF TO cl_salv_column_table.
  
      column ?= columns->get_column( column_name ).
      column->set_icon( ).
    ENDMETHOD.
  ENDCLASS.
CLASS lcl_file_handler DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS get_file_data
      EXPORTING file_data TYPE ANY TABLE
      RAISING   zcx_bo_i071.

    METHODS constructor
      IMPORTING file_name TYPE string.

  PRIVATE SECTION.
    CONSTANTS csv_separator TYPE c LENGTH 1 VALUE ','.
    CONSTANTS csv_extension TYPE string     VALUE '*.CSV'.
    CONSTANTS txt_extension TYPE string     VALUE '*.TXT'.

    DATA file_name           TYPE string.
    DATA file_data_in_string TYPE stringtab.

    METHODS read_file_to_string_table
      RAISING zcx_bo_i071.

    METHODS get_separator
      RETURNING VALUE(result) TYPE char01.

    METHODS format_value
      IMPORTING !value  TYPE any
      EXPORTING !result TYPE any
      RAISING   cx_abap_datfm_no_date
                cx_abap_datfm_invalid_date
                cx_abap_datfm_format_unknown
                cx_abap_datfm_ambiguous.
ENDCLASS.


CLASS lcl_file_handler IMPLEMENTATION.
  METHOD get_file_data.
    DATA file_data_str TYPE REF TO data.

    FIELD-SYMBOLS <file_data>     TYPE ANY TABLE.
    FIELD-SYMBOLS <file_data_str> TYPE any.

    ASSIGN file_data TO <file_data>.

    CREATE DATA file_data_str LIKE LINE OF <file_data>.

    ASSIGN file_data_str->* TO <file_data_str>.

    read_file_to_string_table( ).

    LOOP AT file_data_in_string ASSIGNING FIELD-SYMBOL(<file_line>).
      SPLIT <file_line> AT get_separator( ) INTO TABLE DATA(line_segments).

      LOOP AT line_segments ASSIGNING FIELD-SYMBOL(<line_segment>).
        ASSIGN COMPONENT sy-tabix OF STRUCTURE <file_data_str> TO FIELD-SYMBOL(<componente_value>).

        TRY.
            format_value( EXPORTING value  = <line_segment>
                          IMPORTING result = <componente_value> ).
          CATCH cx_abap_datfm_no_date cx_abap_datfm_invalid_date cx_abap_datfm_format_unknown cx_abap_datfm_ambiguous.
            RAISE EXCEPTION NEW zcx_bo_i071( textid = zcx_bo_i071=>error_uploading_file ).
        ENDTRY.
      ENDLOOP.

      INSERT <file_data_str> INTO TABLE file_data.
    ENDLOOP.
  ENDMETHOD.

  METHOD constructor.
    me->file_name = file_name.
  ENDMETHOD.

  METHOD read_file_to_string_table.
    cl_gui_frontend_services=>gui_upload( EXPORTING  filename                = file_name
                                          CHANGING   data_tab                = file_data_in_string
                                          EXCEPTIONS file_open_error         = 1
                                                     file_read_error         = 2
                                                     no_batch                = 3
                                                     gui_refuse_filetransfer = 4
                                                     invalid_type            = 5
                                                     no_authority            = 6
                                                     unknown_error           = 7
                                                     bad_data_format         = 8
                                                     header_not_allowed      = 9
                                                     separator_not_allowed   = 10
                                                     header_too_long         = 11
                                                     unknown_dp_error        = 12
                                                     access_denied           = 13
                                                     dp_out_of_memory        = 14
                                                     disk_full               = 15
                                                     dp_timeout              = 16
                                                     not_supported_by_gui    = 17
                                                     error_no_gui            = 18
                                                     OTHERS                  = 19 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_bo_i071( textid = zcx_bo_i071=>error_uploading_file ).
    ENDIF.
  ENDMETHOD.

  METHOD get_separator.
    IF file_name CP lcl_file_handler=>csv_extension.
      result = lcl_file_handler=>csv_separator.
    ELSEIF file_name CP lcl_file_handler=>txt_extension.
      result = cl_abap_char_utilities=>horizontal_tab.
    ENDIF.
  ENDMETHOD.

  METHOD format_value.
    CASE cl_abap_typedescr=>describe_by_data( result )->type_kind.
      WHEN cl_abap_typedescr=>typekind_date.
        cl_abap_datfm=>conv_date_ext_to_int( EXPORTING im_datext = value
                                             IMPORTING ex_datint = result ).
      WHEN cl_abap_typedescr=>typekind_packed.
        " TODO: Method to format decimals!
      WHEN OTHERS.
        result = value.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
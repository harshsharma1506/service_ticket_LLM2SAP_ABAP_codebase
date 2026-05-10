CLASS lhc_zi_ai_incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_ai_incident RESULT result.

    METHODS setinitialvalues FOR DETERMINATION zi_ai_incident~setinitialvalues
      IMPORTING keys FOR zi_ai_incident.

ENDCLASS.
CLASS lhc_zi_ai_incident IMPLEMENTATION.

  METHOD get_instance_authorizations.
    " Provide authorization logic here if needed
    " For unrestricted access, leave the result table empty
  ENDMETHOD.

  METHOD setinitialvalues.


    READ ENTITIES OF zi_ai_incident IN LOCAL MODE
      ENTITY zi_ai_incident
      FIELDS ( created_at created_by status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_incidents).

    LOOP AT lt_incidents ASSIGNING FIELD-SYMBOL(<ls>).

      "Defaults
      DATA(lv_now) = utclong_current( ).

      IF <ls>-created_at IS INITIAL.
        GET TIME STAMP FIELD <ls>-created_at.
      ENDIF.

      IF <ls>-created_by IS INITIAL.
        <ls>-created_by = cl_abap_context_info=>get_user_technical_name( ).
      ENDIF.

      "⚠️ FORCE status ALWAYS
      <ls>-status = 'PROCESSED'.

    ENDLOOP.

    "IMPORTANT: write back using control structure
    MODIFY ENTITIES OF zi_ai_incident IN LOCAL MODE
      ENTITY zi_ai_incident
        UPDATE FIELDS ( created_at created_by status )
        WITH VALUE #(
          FOR ls IN lt_incidents (
            %tky = ls-%tky
            created_at = ls-created_at
            created_by = ls-created_by
            status = ls-status

            %control-created_at = if_abap_behv=>mk-on
            %control-created_by = if_abap_behv=>mk-on
            %control-status     = if_abap_behv=>mk-on
          )
        ).

  ENDMETHOD.

ENDCLASS.

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

  " Read entities being created
  READ ENTITIES OF zi_ai_incident IN LOCAL MODE
    ENTITY zi_ai_incident
      FIELDS (
        incident_id
        created_at
        created_by
        status
      )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_incidents).

  " Keep only records without UUID
  DELETE lt_incidents
    WHERE incident_id IS NOT INITIAL.

  IF lt_incidents IS INITIAL.
    RETURN.
  ENDIF.

  " Populate system-managed fields
  LOOP AT lt_incidents ASSIGNING FIELD-SYMBOL(<fs_incident>).

    TRY.

        <fs_incident>-incident_id =
          cl_system_uuid=>create_uuid_x16_static( ).

      CATCH cx_uuid_error.

        CONTINUE.

    ENDTRY.

    GET TIME STAMP FIELD <fs_incident>-created_at.

    <fs_incident>-created_by =
      cl_abap_context_info=>get_user_technical_name( ).

    <fs_incident>-status = 'NEW'.

  ENDLOOP.

  " Update transactional buffer
  MODIFY ENTITIES OF zi_ai_incident IN LOCAL MODE
    ENTITY zi_ai_incident
      UPDATE FIELDS (
        incident_id
        created_at
        created_by
        status
      )
      WITH VALUE #(
        FOR ls_incident IN lt_incidents (
          %tky        = ls_incident-%tky
          incident_id = ls_incident-incident_id
          created_at  = ls_incident-created_at
          created_by  = ls_incident-created_by
          status      = ls_incident-status
        )
      )
    REPORTED DATA(lt_reported).

  reported =
    CORRESPONDING #( BASE ( reported ) lt_reported ).

ENDMETHOD.

ENDCLASS.

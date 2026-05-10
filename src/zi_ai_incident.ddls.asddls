@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'AI Incident Root Entity'

define root view entity ZI_AI_INCIDENT
  as select from zai_incident
{
  key incident_id,
      raw_input,
      business_summary,
      technical_summary,
      llm_model,
      sap_module,
      incident_type,
      priority,
      business_impact,
      probable_root_cause,
      suggested_team,
      sap_object,
      keywords,
      reproducibility,
      debugging_steps,
      confidence_score,
      status,
      created_at,
      created_by
}

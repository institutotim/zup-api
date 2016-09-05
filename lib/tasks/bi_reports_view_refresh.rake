desc 'Refresh the views used by the BI module'
task refresh_bi_views: :environment do
  puts 'Refreshing BI views...'
  ActiveRecord::Base.connection.execute <<-SQL
  DROP VIEW IF EXISTS bi_reports_items;

  CREATE VIEW bi_reports_items AS
  SELECT ri.*,
    round(CAST((EXTRACT(EPOCH FROM avg_resolve_table.resolve_time) / 60 / 60) as numeric), 2) resolve_time_hours,
    round(CAST((EXTRACT(EPOCH FROM avg_resolve_table.resolve_time) / 60 / 60 / 24) as numeric), 2) resolve_time_days,
    round(CAST((EXTRACT(EPOCH FROM avg_resolve_table.overdue_time) / 60 / 60) as numeric), 2) overdue_time_hours,
    round(CAST((EXTRACT(EPOCH FROM avg_resolve_table.overdue_time) / 60 / 60 / 24) as numeric), 2) overdue_time_days
  FROM reports_items ri
  LEFT OUTER JOIN (
    SELECT id as report_id,
     (resolved_at - created_at) resolve_time,
     (COALESCE(resolved_at, now()) - overdue_at) overdue_time
    FROM reports_items
    WHERE reports_status_id IN (
      SELECT rs.reports_status_id
      FROM reports_statuses_reports_categories rs
      WHERE rs.reports_category_id = reports_category_id
      AND rs.final IS TRUE OR (overdue_at IS NOT NULL AND resolved_at IS NULL)
    )
  ) avg_resolve_table ON ri.id = avg_resolve_table.report_id;

  DROP VIEW IF EXISTS bi_inventory_items;

  CREATE VIEW bi_inventory_items AS
  SELECT ii.id, ii.inventory_category_id, ii.user_id, ii.inventory_status_id, ii.created_at, ii.updated_at
  FROM inventory_items ii;

  DROP VIEW IF EXISTS bi_inventory_fields;

  CREATE VIEW bi_inventory_fields AS
  SELECT ivf.id, isec.inventory_category_id, ivf.options -> 'label' as label FROM inventory_fields ivf
  JOIN inventory_sections isec ON isec.id = ivf.inventory_section_id
  WHERE ivf.kind IN ('radio', 'checkbox', 'select', 'date', 'years', 'months', 'days', 'hours', 'seconds', 'angle', 'time', 'integer', 'decimal', 'centimeters', 'kilometers');

  DROP VIEW IF EXISTS bi_inventory_fields_data;

  CREATE VIEW bi_inventory_fields_data AS
  SELECT outer_iid.id, outer_iid.inventory_item_id, outer_iid.inventory_field_id, unnest(content_array.label) as label, unnest(content_array.val) as value
  FROM inventory_item_data outer_iid, LATERAL (
    SELECT
      CASE
        WHEN iid.inventory_field_option_ids IS NOT NULL THEN (
          SELECT array_agg(ifo.value) FROM inventory_item_data inner_iid
          JOIN inventory_field_options ifo ON ifo.id = ANY(inner_iid.inventory_field_option_ids)
          WHERE outer_iid.id = inner_iid.id
        )
        WHEN iid.content IS NOT NULL THEN iid.content
      END AS label,
    CASE
        WHEN iid.inventory_field_option_ids IS NOT NULL THEN (
          SELECT array_agg(ifo.id::text) FROM inventory_item_data inner_iid
          JOIN inventory_field_options ifo ON ifo.id = ANY(inner_iid.inventory_field_option_ids)
          WHERE outer_iid.id = inner_iid.id
        )
        WHEN iid.content IS NOT NULL THEN iid.content
      END AS val
    FROM inventory_item_data iid
    WHERE (iid.inventory_field_option_ids IS NOT NULL OR iid.content IS NOT NULL) AND outer_iid.id = iid.id
  ) content_array;

  DROP VIEW IF EXISTS bi_case_fields;

  CREATE VIEW bi_case_fields AS
  SELECT fields.id, fields.title as label FROM fields
  WHERE fields.field_type IN ('radio', 'checkbox', 'select', 'date', 'years', 'months', 'days', 'hours', 'seconds', 'angle', 'time', 'integer', 'decimal', 'centimeters', 'kilometers');

  DROP VIEW IF EXISTS bi_case_fields_data;

  CREATE VIEW bi_case_fields_data AS
  SELECT csdf.id, cs.case_id, csdf.field_id, json_array_elements_text(csdf.value::json) as value FROM case_step_data_fields csdf
  JOIN fields f ON csdf.field_id = f.id
  JOIN case_steps cs ON csdf.case_step_id = cs.id
  WHERE f.field_type IN ('checkbox')
  UNION
  SELECT csdf.id, cs.case_id, csdf.field_id, csdf.value as value FROM case_step_data_fields csdf
  JOIN fields f ON csdf.field_id = f.id
  JOIN case_steps cs ON csdf.case_step_id = cs.id
  WHERE f.field_type IN ('radio', 'select', 'date', 'years', 'months', 'days', 'hours', 'seconds', 'angle', 'time', 'integer', 'decimal', 'centimeters', 'kilometers');

  DROP VIEW IF EXISTS bi_cases;

  CREATE VIEW bi_cases AS
  SELECT c.id, cs.latest_executed_step_id, c.namespace_id, c.created_by_id, c.updated_by_id, c.status, c.initial_flow_id, c.responsible_user, c.source_reports_category_id, c.resolution_state_id FROM cases c,
  LATERAL (SELECT step_id as latest_executed_step_id FROM case_steps WHERE case_id = c.id ORDER BY created_at DESC LIMIT 1) cs
  WHERE c.status != 'inactive';
  SQL
end

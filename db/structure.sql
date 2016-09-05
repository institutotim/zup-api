--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


SET search_path = public, pg_catalog;

--
-- Name: users_tsv_updater(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION users_tsv_updater() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        begin
          new.tsv_name := setweight(to_tsvector('simple', unaccent(coalesce(new.name,''))), 'A');

          new.tsv_document := setweight(to_tsvector('simple', unaccent(coalesce(new.document,''))), 'A');

          new.tsv_query := (
            setweight(to_tsvector('simple', unaccent(coalesce(new.name,''))), 'A') ||
            setweight(to_tsvector('simple', unaccent(coalesce(new.document,''))), 'A')
          );

          return new;
        end
      $$;


--
-- Name: array_agg(anyelement); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE array_agg(anyelement) (
    SFUNC = array_append,
    STYPE = anyarray,
    INITCOND = '{}'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE access_keys (
    id integer NOT NULL,
    user_id integer,
    key character varying(255),
    expired boolean DEFAULT false NOT NULL,
    expired_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    expires_at timestamp without time zone NOT NULL,
    permanent boolean DEFAULT false NOT NULL
);


--
-- Name: access_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE access_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE access_keys_id_seq OWNED BY access_keys.id;


--
-- Name: fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fields (
    id integer NOT NULL,
    title character varying(255),
    field_type character varying(255),
    category_inventory_id integer[] DEFAULT '{}'::integer[],
    category_report_id integer[] DEFAULT '{}'::integer[],
    origin_field_id integer,
    active boolean DEFAULT true,
    step_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    multiple boolean DEFAULT false,
    filter character varying(255),
    requirements hstore,
    user_id integer,
    origin_field_version integer,
    draft boolean DEFAULT true,
    "values" character varying(255)[] DEFAULT '{}'::character varying[],
    field_id integer
);


--
-- Name: bi_case_fields; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW bi_case_fields AS
 SELECT fields.id,
    fields.title AS label
   FROM fields
  WHERE ((fields.field_type)::text = ANY ((ARRAY['radio'::character varying, 'checkbox'::character varying, 'select'::character varying, 'date'::character varying, 'years'::character varying, 'months'::character varying, 'days'::character varying, 'hours'::character varying, 'seconds'::character varying, 'angle'::character varying, 'time'::character varying, 'integer'::character varying, 'decimal'::character varying, 'centimeters'::character varying, 'kilometers'::character varying])::text[]));


--
-- Name: case_step_data_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE case_step_data_fields (
    id integer NOT NULL,
    case_step_id integer NOT NULL,
    field_id integer NOT NULL,
    value text
);


--
-- Name: case_steps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE case_steps (
    id integer NOT NULL,
    case_id integer,
    step_id integer,
    step_version integer DEFAULT 1,
    created_by_id integer,
    updated_by_id integer,
    trigger_ids integer[] DEFAULT '{}'::integer[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    responsible_user_id integer,
    responsible_group_id integer
);


--
-- Name: bi_case_fields_data; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW bi_case_fields_data AS
 SELECT csdf.id,
    cs.case_id,
    csdf.field_id,
    json_array_elements_text((csdf.value)::json) AS value
   FROM ((case_step_data_fields csdf
     JOIN fields f ON ((csdf.field_id = f.id)))
     JOIN case_steps cs ON ((csdf.case_step_id = cs.id)))
  WHERE ((f.field_type)::text = 'checkbox'::text)
UNION
 SELECT csdf.id,
    cs.case_id,
    csdf.field_id,
    csdf.value
   FROM ((case_step_data_fields csdf
     JOIN fields f ON ((csdf.field_id = f.id)))
     JOIN case_steps cs ON ((csdf.case_step_id = cs.id)))
  WHERE ((f.field_type)::text = ANY ((ARRAY['radio'::character varying, 'select'::character varying, 'date'::character varying, 'years'::character varying, 'months'::character varying, 'days'::character varying, 'hours'::character varying, 'seconds'::character varying, 'angle'::character varying, 'time'::character varying, 'integer'::character varying, 'decimal'::character varying, 'centimeters'::character varying, 'kilometers'::character varying])::text[]));


--
-- Name: steps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE steps (
    id integer NOT NULL,
    title character varying(255),
    description text,
    step_type character varying(255),
    flow_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT true,
    child_flow_id integer,
    child_flow_version integer,
    conduction_mode_open boolean DEFAULT true,
    draft boolean DEFAULT true,
    user_id integer,
    fields_versions json DEFAULT '{}'::json,
    triggers_versions json DEFAULT '{}'::json
);


--
-- Name: bi_case_latest_step; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW bi_case_latest_step AS
 SELECT s.id,
    s.case_id,
    s.step_id,
    s.title,
    s.step_rank
   FROM ( SELECT cs.id,
            cs.case_id,
            cs.step_id,
            s_1.title,
            rank() OVER (PARTITION BY cs.case_id ORDER BY cs.created_at DESC) AS step_rank
           FROM (case_steps cs
             JOIN steps s_1 ON ((cs.step_id = s_1.id)))) s
  WHERE (s.step_rank = 1);


--
-- Name: cases; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cases (
    id integer NOT NULL,
    created_by_id integer NOT NULL,
    updated_by_id integer,
    responsible_user integer,
    responsible_group integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    initial_flow_id integer NOT NULL,
    flow_version integer DEFAULT 1,
    status character varying(255) DEFAULT 'active'::character varying,
    disabled_steps integer[] DEFAULT '{}'::integer[],
    resolution_state_id integer,
    original_case_id integer,
    old_status character varying(255),
    source_reports_category_id integer,
    namespace_id integer
);


--
-- Name: bi_cases; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW bi_cases AS
 SELECT c.id,
    cs.latest_executed_step_id,
    c.namespace_id,
    c.created_by_id,
    c.updated_by_id,
    c.status,
    c.initial_flow_id,
    c.responsible_user,
    c.source_reports_category_id,
    c.resolution_state_id
   FROM cases c,
    LATERAL ( SELECT case_steps.step_id AS latest_executed_step_id
           FROM case_steps
          WHERE (case_steps.case_id = c.id)
          ORDER BY case_steps.created_at DESC
         LIMIT 1) cs
  WHERE ((c.status)::text <> 'inactive'::text);


--
-- Name: inventory_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_fields (
    id integer NOT NULL,
    title character varying(255),
    kind character varying(255),
    size character varying(255),
    "position" integer,
    inventory_section_id integer,
    options hstore,
    permissions hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    required boolean DEFAULT false NOT NULL,
    maximum integer,
    minimum integer,
    available_values character varying(255)[],
    disabled boolean DEFAULT false,
    use_as_title boolean DEFAULT false
);


--
-- Name: inventory_sections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_sections (
    id integer NOT NULL,
    title character varying(255),
    inventory_category_id integer,
    permissions hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "position" integer,
    required boolean NOT NULL,
    location boolean DEFAULT false NOT NULL,
    disabled boolean DEFAULT false
);


--
-- Name: bi_inventory_fields; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW bi_inventory_fields AS
 SELECT ivf.id,
    isec.inventory_category_id,
    (ivf.options -> 'label'::text) AS label
   FROM (inventory_fields ivf
     JOIN inventory_sections isec ON ((isec.id = ivf.inventory_section_id)))
  WHERE ((ivf.kind)::text = ANY ((ARRAY['radio'::character varying, 'checkbox'::character varying, 'select'::character varying, 'date'::character varying, 'years'::character varying, 'months'::character varying, 'days'::character varying, 'hours'::character varying, 'seconds'::character varying, 'angle'::character varying, 'time'::character varying, 'integer'::character varying, 'decimal'::character varying, 'centimeters'::character varying, 'kilometers'::character varying])::text[]));


--
-- Name: inventory_field_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_field_options (
    id integer NOT NULL,
    inventory_field_id integer,
    value character varying(255),
    disabled boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_item_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_item_data (
    id integer NOT NULL,
    inventory_item_id integer,
    inventory_field_id integer,
    content text[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    inventory_field_option_ids integer[]
);


--
-- Name: bi_inventory_fields_data; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW bi_inventory_fields_data AS
 SELECT outer_iid.id,
    outer_iid.inventory_item_id,
    outer_iid.inventory_field_id,
    unnest(content_array.label) AS label,
    unnest(content_array.val) AS value
   FROM inventory_item_data outer_iid,
    LATERAL ( SELECT
                CASE
                    WHEN (iid.inventory_field_option_ids IS NOT NULL) THEN ( SELECT pg_catalog.array_agg(ifo.value) AS array_agg
                       FROM (inventory_item_data inner_iid
                         JOIN inventory_field_options ifo ON ((ifo.id = ANY (inner_iid.inventory_field_option_ids))))
                      WHERE (outer_iid.id = inner_iid.id))
                    WHEN (iid.content IS NOT NULL) THEN (iid.content)::character varying[]
                    ELSE NULL::character varying[]
                END AS label,
                CASE
                    WHEN (iid.inventory_field_option_ids IS NOT NULL) THEN ( SELECT pg_catalog.array_agg((ifo.id)::text) AS array_agg
                       FROM (inventory_item_data inner_iid
                         JOIN inventory_field_options ifo ON ((ifo.id = ANY (inner_iid.inventory_field_option_ids))))
                      WHERE (outer_iid.id = inner_iid.id))
                    WHEN (iid.content IS NOT NULL) THEN iid.content
                    ELSE NULL::text[]
                END AS val
           FROM inventory_item_data iid
          WHERE (((iid.inventory_field_option_ids IS NOT NULL) OR (iid.content IS NOT NULL)) AND (outer_iid.id = iid.id))) content_array;


--
-- Name: inventory_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_items (
    id integer NOT NULL,
    inventory_category_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "position" geometry(Point),
    title character varying(255),
    address character varying(255),
    inventory_status_id integer,
    locked boolean DEFAULT false,
    locked_at timestamp without time zone,
    locker_id integer,
    sequence integer,
    namespace_id integer
);


--
-- Name: bi_inventory_items; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW bi_inventory_items AS
 SELECT ii.id,
    ii.inventory_category_id,
    ii.user_id,
    ii.inventory_status_id,
    ii.created_at,
    ii.updated_at
   FROM inventory_items ii;


--
-- Name: reports_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_items (
    id integer NOT NULL,
    address text,
    description text,
    reports_status_id integer,
    reports_category_id integer,
    user_id integer,
    inventory_item_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "position" geometry(Point),
    protocol bigint,
    reference character varying(255),
    confidential boolean DEFAULT false,
    reporter_id integer,
    overdue boolean DEFAULT false,
    comments_count integer DEFAULT 0,
    uuid uuid,
    external_category_id integer,
    is_solicitation boolean,
    is_report boolean,
    assigned_group_id integer,
    assigned_user_id integer,
    number character varying(255),
    district character varying(255),
    postal_code character varying(255),
    city character varying(255),
    state character varying(255),
    country character varying(255),
    offensive boolean DEFAULT false,
    resolved_at timestamp without time zone,
    overdue_at timestamp without time zone,
    version integer DEFAULT 1,
    last_version_at timestamp without time zone,
    reports_perimeter_id integer,
    from_webhook boolean DEFAULT false,
    sync_at timestamp without time zone,
    case_id integer,
    namespace_id integer
);


--
-- Name: reports_statuses_reports_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_statuses_reports_categories (
    reports_status_id integer,
    reports_category_id integer,
    id integer NOT NULL,
    initial boolean DEFAULT false,
    final boolean DEFAULT false,
    private boolean DEFAULT false,
    active boolean DEFAULT true,
    color character varying(255),
    create_case boolean,
    flow_id integer,
    responsible_group_id integer,
    namespace_id integer
);


--
-- Name: bi_reports_items; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW bi_reports_items AS
 SELECT ri.id,
    ri.address,
    ri.description,
    ri.reports_status_id,
    ri.reports_category_id,
    ri.user_id,
    ri.inventory_item_id,
    ri.created_at,
    ri.updated_at,
    ri."position",
    ri.protocol,
    ri.reference,
    ri.confidential,
    ri.reporter_id,
    ri.overdue,
    ri.comments_count,
    ri.uuid,
    ri.external_category_id,
    ri.is_solicitation,
    ri.is_report,
    ri.assigned_group_id,
    ri.assigned_user_id,
    ri.number,
    ri.district,
    ri.postal_code,
    ri.city,
    ri.state,
    ri.country,
    ri.offensive,
    ri.resolved_at,
    ri.overdue_at,
    ri.version,
    ri.last_version_at,
    ri.reports_perimeter_id,
    ri.from_webhook,
    ri.sync_at,
    ri.case_id,
    ri.namespace_id,
    round((((date_part('epoch'::text, avg_resolve_table.resolve_time) / (60)::double precision) / (60)::double precision))::numeric, 2) AS resolve_time_hours,
    round(((((date_part('epoch'::text, avg_resolve_table.resolve_time) / (60)::double precision) / (60)::double precision) / (24)::double precision))::numeric, 2) AS resolve_time_days,
    round((((date_part('epoch'::text, avg_resolve_table.overdue_time) / (60)::double precision) / (60)::double precision))::numeric, 2) AS overdue_time_hours,
    round(((((date_part('epoch'::text, avg_resolve_table.overdue_time) / (60)::double precision) / (60)::double precision) / (24)::double precision))::numeric, 2) AS overdue_time_days
   FROM (reports_items ri
     LEFT JOIN ( SELECT reports_items.id AS report_id,
            (reports_items.resolved_at - reports_items.created_at) AS resolve_time,
            (COALESCE((reports_items.resolved_at)::timestamp with time zone, now()) - (reports_items.overdue_at)::timestamp with time zone) AS overdue_time
           FROM reports_items
          WHERE (reports_items.reports_status_id IN ( SELECT rs.reports_status_id
                   FROM reports_statuses_reports_categories rs
                  WHERE (((rs.reports_category_id = rs.reports_category_id) AND (rs.final IS TRUE)) OR ((reports_items.overdue_at IS NOT NULL) AND (reports_items.resolved_at IS NULL)))))) avg_resolve_table ON ((ri.id = avg_resolve_table.report_id)));


--
-- Name: business_reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE business_reports (
    id integer NOT NULL,
    title character varying(255),
    user_id integer,
    summary text,
    begin_date timestamp without time zone,
    end_date timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    params json,
    namespace_id integer
);


--
-- Name: business_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE business_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: business_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE business_reports_id_seq OWNED BY business_reports.id;


--
-- Name: case_step_data_attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE case_step_data_attachments (
    id integer NOT NULL,
    attachment character varying(255),
    file_name character varying(255),
    case_step_data_field_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: case_step_data_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE case_step_data_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_step_data_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE case_step_data_attachments_id_seq OWNED BY case_step_data_attachments.id;


--
-- Name: case_step_data_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE case_step_data_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_step_data_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE case_step_data_fields_id_seq OWNED BY case_step_data_fields.id;


--
-- Name: case_step_data_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE case_step_data_images (
    id integer NOT NULL,
    image character varying(255),
    file_name character varying(255),
    case_step_data_field_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: case_step_data_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE case_step_data_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_step_data_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE case_step_data_images_id_seq OWNED BY case_step_data_images.id;


--
-- Name: case_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE case_steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: case_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE case_steps_id_seq OWNED BY case_steps.id;


--
-- Name: cases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cases_id_seq OWNED BY cases.id;


--
-- Name: cases_log_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cases_log_entries (
    id integer NOT NULL,
    user_id integer,
    action character varying(255) NOT NULL,
    flow_id integer,
    step_id integer,
    case_id integer,
    before_user_id integer,
    after_user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    flow_version integer,
    new_flow_id integer,
    before_group_id integer,
    after_group_id integer,
    child_case_id integer
);


--
-- Name: cases_log_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cases_log_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cases_log_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cases_log_entries_id_seq OWNED BY cases_log_entries.id;


--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE chat_messages (
    id integer NOT NULL,
    chattable_id integer,
    chattable_type character varying(255),
    kind integer,
    user_id integer,
    text text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE chat_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE chat_messages_id_seq OWNED BY chat_messages.id;


--
-- Name: chat_rooms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE chat_rooms (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    namespace_id integer
);


--
-- Name: chat_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE chat_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE chat_rooms_id_seq OWNED BY chat_rooms.id;


--
-- Name: feature_flags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE feature_flags (
    id integer NOT NULL,
    name character varying(255),
    status integer DEFAULT 0,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: feature_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feature_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: feature_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feature_flags_id_seq OWNED BY feature_flags.id;


--
-- Name: fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fields_id_seq OWNED BY fields.id;


--
-- Name: flows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE flows (
    id integer NOT NULL,
    title character varying(255),
    description text,
    created_by_id integer NOT NULL,
    updated_by_id integer,
    initial boolean DEFAULT false,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    status character varying(255) DEFAULT 'active'::character varying,
    step_id integer,
    current_version integer,
    draft boolean DEFAULT true,
    resolution_states_versions json DEFAULT '{}'::json,
    steps_versions json DEFAULT '{}'::json,
    steps_order integer[] DEFAULT '{}'::integer[]
);


--
-- Name: flows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE flows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE flows_id_seq OWNED BY flows.id;


--
-- Name: group_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_permissions (
    id integer NOT NULL,
    group_id integer,
    manage_flows boolean DEFAULT false,
    manage_users boolean DEFAULT false,
    manage_inventory_categories boolean DEFAULT false,
    manage_inventory_items boolean DEFAULT false,
    manage_groups boolean DEFAULT false,
    manage_reports_categories boolean DEFAULT false,
    manage_reports boolean DEFAULT false,
    manage_inventory_formulas boolean DEFAULT false,
    manage_config boolean DEFAULT false,
    delete_inventory_items boolean DEFAULT false,
    delete_reports boolean DEFAULT false,
    edit_inventory_items boolean DEFAULT false,
    edit_reports boolean DEFAULT false,
    view_categories boolean DEFAULT false,
    view_sections boolean DEFAULT false,
    panel_access boolean DEFAULT false,
    groups_can_edit integer[] DEFAULT '{}'::integer[],
    groups_can_view integer[] DEFAULT '{}'::integer[],
    reports_categories_can_edit integer[] DEFAULT '{}'::integer[],
    reports_categories_can_view integer[] DEFAULT '{}'::integer[],
    inventory_categories_can_edit integer[] DEFAULT '{}'::integer[],
    inventory_categories_can_view integer[] DEFAULT '{}'::integer[],
    inventory_sections_can_view integer[] DEFAULT '{}'::integer[],
    inventory_sections_can_edit integer[] DEFAULT '{}'::integer[],
    inventory_fields_can_edit integer[] DEFAULT '{}'::integer[],
    inventory_fields_can_view integer[] DEFAULT '{}'::integer[],
    flow_can_view_all_steps integer[] DEFAULT '{}'::integer[],
    flow_can_execute_all_steps integer[] DEFAULT '{}'::integer[],
    can_view_step integer[] DEFAULT '{}'::integer[],
    can_execute_step integer[] DEFAULT '{}'::integer[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    create_reports_from_panel boolean DEFAULT false,
    flow_can_delete_all_cases integer[] DEFAULT '{}'::integer[],
    flow_can_delete_own_cases integer[] DEFAULT '{}'::integer[],
    users_full_access boolean DEFAULT false,
    groups_full_access boolean DEFAULT false,
    reports_full_access boolean DEFAULT false,
    inventories_full_access boolean DEFAULT false,
    inventories_formulas_full_access boolean DEFAULT false,
    group_edit integer[] DEFAULT '{}'::integer[],
    group_read_only integer[] DEFAULT '{}'::integer[],
    reports_items_read_public integer[] DEFAULT '{}'::integer[],
    reports_items_create integer[] DEFAULT '{}'::integer[],
    reports_items_edit integer[] DEFAULT '{}'::integer[],
    reports_items_delete integer[] DEFAULT '{}'::integer[],
    reports_categories_edit integer[] DEFAULT '{}'::integer[],
    inventories_items_read_only integer[] DEFAULT '{}'::integer[],
    inventories_items_create integer[] DEFAULT '{}'::integer[],
    inventories_items_edit integer[] DEFAULT '{}'::integer[],
    inventories_items_delete integer[] DEFAULT '{}'::integer[],
    inventories_categories_edit integer[] DEFAULT '{}'::integer[],
    inventories_category_manage_triggers integer[] DEFAULT '{}'::integer[],
    reports_items_read_private integer[] DEFAULT '{}'::integer[],
    reports_items_forward integer[] DEFAULT '{}'::integer[],
    reports_items_create_internal_comment integer[] DEFAULT '{}'::integer[],
    reports_items_create_comment integer[] DEFAULT '{}'::integer[],
    reports_items_alter_status integer[] DEFAULT '{}'::integer[],
    users_edit integer[] DEFAULT '{}'::integer[],
    business_reports_edit boolean,
    business_reports_view integer[] DEFAULT '{}'::integer[],
    reports_items_send_notification integer[] DEFAULT '{}'::integer[],
    reports_items_restart_notification integer[] DEFAULT '{}'::integer[],
    manage_chat_rooms boolean,
    chat_rooms_read integer[] DEFAULT '{}'::integer[],
    cases_with_reports_view integer[] DEFAULT '{}'::integer[],
    manage_cases boolean DEFAULT false,
    users_read_private boolean DEFAULT false,
    manage_namespaces boolean DEFAULT false NOT NULL,
    namespaces_access integer[] DEFAULT '{}'::integer[],
    user_id integer,
    manage_services boolean DEFAULT false NOT NULL
);


--
-- Name: group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_permissions_id_seq OWNED BY group_permissions.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    name character varying(255),
    permissions hstore,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    guest boolean DEFAULT false NOT NULL,
    namespace_id integer
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: groups_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups_users (
    group_id integer,
    user_id integer
);


--
-- Name: groups_users_tables; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups_users_tables (
    id integer NOT NULL
);


--
-- Name: groups_users_tables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_users_tables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_users_tables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_users_tables_id_seq OWNED BY groups_users_tables.id;


--
-- Name: inventory_analysis_scores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_analysis_scores (
    id integer NOT NULL,
    inventory_field_id integer,
    inventory_analysis_id integer,
    content character varying(255)[],
    score numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    operator character varying(255)
);


--
-- Name: inventory_analysis_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_analysis_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_analysis_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_analysis_scores_id_seq OWNED BY inventory_analysis_scores.id;


--
-- Name: inventory_analyzes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_analyzes (
    id integer NOT NULL,
    inventory_category_id integer,
    title character varying(255),
    expression character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_analyzes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_analyzes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_analyzes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_analyzes_id_seq OWNED BY inventory_analyzes.id;


--
-- Name: inventory_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_categories (
    id integer NOT NULL,
    title character varying(255),
    description character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    icon character varying(255),
    marker character varying(255),
    color character varying(255),
    pin character varying(255),
    plot_format character varying(255),
    require_item_status boolean DEFAULT false NOT NULL,
    locked boolean DEFAULT false,
    locked_at timestamp without time zone,
    locker_id integer,
    namespace_id integer
);


--
-- Name: inventory_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_categories_id_seq OWNED BY inventory_categories.id;


--
-- Name: inventory_categories_reports_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_categories_reports_categories (
    reports_category_id integer,
    inventory_category_id integer
);


--
-- Name: inventory_field_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_field_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_field_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_field_options_id_seq OWNED BY inventory_field_options.id;


--
-- Name: inventory_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_fields_id_seq OWNED BY inventory_fields.id;


--
-- Name: inventory_formula_alerts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_formula_alerts (
    id integer NOT NULL,
    inventory_formula_id integer,
    groups_alerted integer[],
    sent_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    level integer
);


--
-- Name: inventory_formula_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_formula_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_formula_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_formula_alerts_id_seq OWNED BY inventory_formula_alerts.id;


--
-- Name: inventory_formula_conditions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_formula_conditions (
    id integer NOT NULL,
    inventory_formula_id integer,
    conditionable_id integer,
    operator character varying(255),
    content character varying(255)[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    conditionable_type character varying(255)
);


--
-- Name: inventory_formula_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_formula_conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_formula_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_formula_conditions_id_seq OWNED BY inventory_formula_conditions.id;


--
-- Name: inventory_formula_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_formula_histories (
    id integer NOT NULL,
    inventory_formula_id integer,
    inventory_item_id integer,
    inventory_formula_alert_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_formula_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_formula_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_formula_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_formula_histories_id_seq OWNED BY inventory_formula_histories.id;


--
-- Name: inventory_formulas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_formulas (
    id integer NOT NULL,
    inventory_category_id integer,
    inventory_status_id integer,
    inventory_field_id integer,
    operator character varying(255),
    content character varying(255)[],
    groups_to_alert integer[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_formulas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_formulas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_formulas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_formulas_id_seq OWNED BY inventory_formulas.id;


--
-- Name: inventory_item_data_attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_item_data_attachments (
    id integer NOT NULL,
    inventory_item_data_id integer,
    attachment character varying(255)
);


--
-- Name: inventory_item_data_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_item_data_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_item_data_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_item_data_attachments_id_seq OWNED BY inventory_item_data_attachments.id;


--
-- Name: inventory_item_data_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_item_data_histories (
    id integer NOT NULL,
    inventory_item_history_id integer NOT NULL,
    inventory_item_data_id integer NOT NULL,
    previous_content character varying(255),
    new_content text,
    previous_selected_options_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    new_selected_options_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_item_data_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_item_data_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_item_data_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_item_data_histories_id_seq OWNED BY inventory_item_data_histories.id;


--
-- Name: inventory_item_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_item_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_item_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_item_data_id_seq OWNED BY inventory_item_data.id;


--
-- Name: inventory_item_data_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_item_data_images (
    id integer NOT NULL,
    inventory_item_data_id integer,
    image character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_item_data_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_item_data_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_item_data_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_item_data_images_id_seq OWNED BY inventory_item_data_images.id;


--
-- Name: inventory_item_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_item_histories (
    id integer NOT NULL,
    inventory_item_id integer,
    user_id integer,
    kind character varying(255),
    action text,
    object_type character varying(255),
    objects_ids integer[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_item_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_item_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_item_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_item_histories_id_seq OWNED BY inventory_item_histories.id;


--
-- Name: inventory_item_sequence_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_item_sequence_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_item_sequence_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_item_sequence_seq OWNED BY inventory_items.sequence;


--
-- Name: inventory_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_items_id_seq OWNED BY inventory_items.id;


--
-- Name: inventory_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_sections_id_seq OWNED BY inventory_sections.id;


--
-- Name: inventory_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_statuses (
    id integer NOT NULL,
    inventory_category_id integer,
    color character varying(255) NOT NULL,
    title character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_statuses_id_seq OWNED BY inventory_statuses.id;


--
-- Name: namespaces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE namespaces (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "default" boolean DEFAULT false NOT NULL
);


--
-- Name: namespaces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE namespaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: namespaces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE namespaces_id_seq OWNED BY namespaces.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    user_id integer,
    notificable_id integer,
    notificable_type character varying(255),
    title character varying(255),
    description character varying(255),
    read boolean DEFAULT false,
    read_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: protocol_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE protocol_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: protocol_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE protocol_seq OWNED BY reports_items.protocol;


--
-- Name: reports_categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_categories (
    id integer NOT NULL,
    title character varying(255),
    icon character varying(255),
    marker character varying(255),
    resolution_time integer,
    user_response_time integer,
    active boolean DEFAULT true NOT NULL,
    allows_arbitrary_position boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    color character varying(255),
    parent_id integer,
    confidential boolean DEFAULT false,
    private_resolution_time boolean DEFAULT false,
    resolution_time_enabled boolean DEFAULT false,
    solver_groups_ids integer[] DEFAULT '{}'::integer[],
    default_solver_group_id integer,
    comment_required_when_forwarding boolean DEFAULT false,
    comment_required_when_updating_status boolean DEFAULT false,
    notifications boolean DEFAULT false,
    ordered_notifications boolean DEFAULT false,
    priority integer,
    perimeters boolean DEFAULT false NOT NULL,
    flow_id integer,
    namespace_id integer
);


--
-- Name: reports_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_categories_id_seq OWNED BY reports_categories.id;


--
-- Name: reports_categories_perimeters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_categories_perimeters (
    id integer NOT NULL,
    reports_category_id integer,
    reports_perimeter_id integer,
    solver_group_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    namespace_id integer,
    active boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 0 NOT NULL
);


--
-- Name: reports_categories_perimeters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_categories_perimeters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_categories_perimeters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_categories_perimeters_id_seq OWNED BY reports_categories_perimeters.id;


--
-- Name: reports_category_custom_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_category_custom_fields (
    id integer NOT NULL,
    reports_category_id integer NOT NULL,
    reports_custom_field_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reports_category_custom_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_category_custom_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_category_custom_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_category_custom_fields_id_seq OWNED BY reports_category_custom_fields.id;


--
-- Name: reports_category_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_category_settings (
    id integer NOT NULL,
    reports_category_id integer,
    namespace_id integer,
    resolution_time_enabled boolean DEFAULT false NOT NULL,
    resolution_time integer,
    private_resolution_time boolean DEFAULT false NOT NULL,
    user_response_time integer,
    allows_arbitrary_position boolean DEFAULT false NOT NULL,
    confidential boolean DEFAULT false NOT NULL,
    default_solver_group_id integer,
    solver_groups_ids integer[] DEFAULT '{}'::integer[],
    comment_required_when_forwarding boolean DEFAULT false NOT NULL,
    comment_required_when_updating_status boolean DEFAULT false NOT NULL,
    notifications boolean DEFAULT false NOT NULL,
    ordered_notifications boolean DEFAULT false NOT NULL,
    perimeters boolean DEFAULT false NOT NULL,
    flow_id integer,
    priority integer DEFAULT 0 NOT NULL
);


--
-- Name: reports_category_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_category_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_category_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_category_settings_id_seq OWNED BY reports_category_settings.id;


--
-- Name: reports_comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_comments (
    id integer NOT NULL,
    reports_item_id integer,
    visibility integer DEFAULT 0,
    author_id integer,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    from_webhook boolean DEFAULT false
);


--
-- Name: reports_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_comments_id_seq OWNED BY reports_comments.id;


--
-- Name: reports_custom_field; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_custom_field (
    id integer NOT NULL,
    title text NOT NULL,
    multiline boolean NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reports_custom_field_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_custom_field_data (
    id integer NOT NULL,
    reports_custom_field_id integer NOT NULL,
    reports_item_id integer NOT NULL,
    value text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reports_custom_field_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_custom_field_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_custom_field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_custom_field_id_seq OWNED BY reports_custom_field.id;


--
-- Name: reports_custom_fields_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_custom_fields_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_custom_fields_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_custom_fields_data_id_seq OWNED BY reports_custom_field_data.id;


--
-- Name: reports_feedback_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_feedback_images (
    id integer NOT NULL,
    reports_feedback_id integer,
    image character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reports_feedback_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_feedback_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_feedback_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_feedback_images_id_seq OWNED BY reports_feedback_images.id;


--
-- Name: reports_feedbacks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_feedbacks (
    id integer NOT NULL,
    reports_item_id integer,
    user_id integer,
    kind character varying(255) NOT NULL,
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reports_feedbacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_feedbacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_feedbacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_feedbacks_id_seq OWNED BY reports_feedbacks.id;


--
-- Name: reports_images; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_images (
    id integer NOT NULL,
    image character varying(255),
    reports_item_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    title character varying(255),
    date timestamp without time zone
);


--
-- Name: reports_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_images_id_seq OWNED BY reports_images.id;


--
-- Name: reports_item_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_item_histories (
    id integer NOT NULL,
    reports_item_id integer,
    user_id integer,
    kind character varying(255),
    action text,
    object_type character varying(255),
    objects_ids integer[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    saved_changes json
);


--
-- Name: reports_item_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_item_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_item_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_item_histories_id_seq OWNED BY reports_item_histories.id;


--
-- Name: reports_item_status_histories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_item_status_histories (
    id integer NOT NULL,
    reports_item_id integer,
    previous_status_id integer,
    new_status_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reports_item_status_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_item_status_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_item_status_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_item_status_histories_id_seq OWNED BY reports_item_status_histories.id;


--
-- Name: reports_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_items_id_seq OWNED BY reports_items.id;


--
-- Name: reports_notification_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_notification_types (
    id integer NOT NULL,
    reports_category_id integer NOT NULL,
    title character varying(255),
    "order" integer,
    reports_status_id integer,
    default_deadline_in_days integer DEFAULT 0,
    layout text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT true,
    namespace_id integer
);


--
-- Name: reports_notification_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_notification_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_notification_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_notification_types_id_seq OWNED BY reports_notification_types.id;


--
-- Name: reports_notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_notifications (
    id integer NOT NULL,
    user_id integer,
    reports_item_id integer,
    reports_notification_type_id integer,
    previous_status_id integer,
    deadline_in_days integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    overdue_at timestamp without time zone,
    active boolean DEFAULT true NOT NULL,
    content text
);


--
-- Name: reports_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_notifications_id_seq OWNED BY reports_notifications.id;


--
-- Name: reports_offensive_flags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_offensive_flags (
    id integer NOT NULL,
    reports_item_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reports_offensive_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_offensive_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_offensive_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_offensive_flags_id_seq OWNED BY reports_offensive_flags.id;


--
-- Name: reports_perimeters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_perimeters (
    id integer NOT NULL,
    title character varying(255),
    shp_file character varying(255),
    shx_file character varying(255),
    status integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    geometry geometry(MultiPolygon,4326),
    solver_group_id integer,
    namespace_id integer,
    active boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 0 NOT NULL
);


--
-- Name: reports_perimeters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_perimeters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_perimeters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_perimeters_id_seq OWNED BY reports_perimeters.id;


--
-- Name: reports_statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports_statuses (
    id integer NOT NULL,
    title character varying(255),
    color character varying(255),
    initial boolean DEFAULT false NOT NULL,
    final boolean DEFAULT false NOT NULL,
    reports_category_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT true,
    private boolean DEFAULT false
);


--
-- Name: reports_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_statuses_id_seq OWNED BY reports_statuses.id;


--
-- Name: reports_statuses_reports_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_statuses_reports_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_statuses_reports_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_statuses_reports_categories_id_seq OWNED BY reports_statuses_reports_categories.id;


--
-- Name: resolution_states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE resolution_states (
    id integer NOT NULL,
    flow_id integer,
    title character varying(255),
    "default" boolean DEFAULT false,
    active boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    draft boolean DEFAULT true,
    user_id integer
);


--
-- Name: resolution_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE resolution_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resolution_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE resolution_states_id_seq OWNED BY resolution_states.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    kind integer NOT NULL,
    value character varying(255)[] DEFAULT '{}'::character varying[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: steps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE steps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE steps_id_seq OWNED BY steps.id;


--
-- Name: trigger_conditions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE trigger_conditions (
    id integer NOT NULL,
    field_id integer,
    condition_type character varying(255) NOT NULL,
    "values" character varying(255) NOT NULL,
    trigger_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT true,
    field_version integer DEFAULT 0,
    draft boolean DEFAULT true,
    user_id integer
);


--
-- Name: trigger_conditions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trigger_conditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trigger_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trigger_conditions_id_seq OWNED BY trigger_conditions.id;


--
-- Name: triggers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE triggers (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    action_type character varying(255) NOT NULL,
    action_values character varying(255) NOT NULL,
    step_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT true,
    description text,
    user_id integer,
    draft boolean DEFAULT true,
    trigger_conditions_versions json DEFAULT '{}'::json
);


--
-- Name: triggers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: triggers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE triggers_id_seq OWNED BY triggers.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    encrypted_password character varying(255),
    salt character varying(255),
    reset_password_token character varying(255),
    name character varying(255),
    email character varying(255),
    phone character varying(255),
    document character varying(255),
    address character varying(255),
    address_additional character varying(255),
    postal_code character varying(255),
    district character varying(255),
    password_resetted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    device_token character varying(255),
    device_type character varying(255),
    facebook_user_id integer,
    twitter_user_id integer,
    google_plus_user_id integer,
    email_notifications boolean DEFAULT true,
    unsubscribe_email_token character varying(255),
    disabled boolean DEFAULT false,
    city character varying(255),
    skype character varying(255),
    institution character varying(255),
    "position" character varying(255),
    commercial_phone character varying(255),
    birthdate date,
    namespace_id integer,
    tsv_name tsvector,
    tsv_document tsvector,
    tsv_query tsvector,
    kind integer DEFAULT 0 NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type character varying(255) NOT NULL,
    item_id integer NOT NULL,
    event character varying(255) NOT NULL,
    whodunnit character varying(255),
    object text,
    created_at timestamp without time zone
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_keys ALTER COLUMN id SET DEFAULT nextval('access_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY business_reports ALTER COLUMN id SET DEFAULT nextval('business_reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY case_step_data_attachments ALTER COLUMN id SET DEFAULT nextval('case_step_data_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY case_step_data_fields ALTER COLUMN id SET DEFAULT nextval('case_step_data_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY case_step_data_images ALTER COLUMN id SET DEFAULT nextval('case_step_data_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY case_steps ALTER COLUMN id SET DEFAULT nextval('case_steps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cases ALTER COLUMN id SET DEFAULT nextval('cases_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cases_log_entries ALTER COLUMN id SET DEFAULT nextval('cases_log_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY chat_messages ALTER COLUMN id SET DEFAULT nextval('chat_messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY chat_rooms ALTER COLUMN id SET DEFAULT nextval('chat_rooms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feature_flags ALTER COLUMN id SET DEFAULT nextval('feature_flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fields ALTER COLUMN id SET DEFAULT nextval('fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY flows ALTER COLUMN id SET DEFAULT nextval('flows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_permissions ALTER COLUMN id SET DEFAULT nextval('group_permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users_tables ALTER COLUMN id SET DEFAULT nextval('groups_users_tables_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_analysis_scores ALTER COLUMN id SET DEFAULT nextval('inventory_analysis_scores_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_analyzes ALTER COLUMN id SET DEFAULT nextval('inventory_analyzes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_categories ALTER COLUMN id SET DEFAULT nextval('inventory_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_field_options ALTER COLUMN id SET DEFAULT nextval('inventory_field_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_fields ALTER COLUMN id SET DEFAULT nextval('inventory_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_formula_alerts ALTER COLUMN id SET DEFAULT nextval('inventory_formula_alerts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_formula_conditions ALTER COLUMN id SET DEFAULT nextval('inventory_formula_conditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_formula_histories ALTER COLUMN id SET DEFAULT nextval('inventory_formula_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_formulas ALTER COLUMN id SET DEFAULT nextval('inventory_formulas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_item_data ALTER COLUMN id SET DEFAULT nextval('inventory_item_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_item_data_attachments ALTER COLUMN id SET DEFAULT nextval('inventory_item_data_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_item_data_histories ALTER COLUMN id SET DEFAULT nextval('inventory_item_data_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_item_data_images ALTER COLUMN id SET DEFAULT nextval('inventory_item_data_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_item_histories ALTER COLUMN id SET DEFAULT nextval('inventory_item_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_items ALTER COLUMN id SET DEFAULT nextval('inventory_items_id_seq'::regclass);


--
-- Name: sequence; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_items ALTER COLUMN sequence SET DEFAULT nextval('inventory_item_sequence_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_sections ALTER COLUMN id SET DEFAULT nextval('inventory_sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_statuses ALTER COLUMN id SET DEFAULT nextval('inventory_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY namespaces ALTER COLUMN id SET DEFAULT nextval('namespaces_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_categories ALTER COLUMN id SET DEFAULT nextval('reports_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_categories_perimeters ALTER COLUMN id SET DEFAULT nextval('reports_categories_perimeters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_category_custom_fields ALTER COLUMN id SET DEFAULT nextval('reports_category_custom_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_category_settings ALTER COLUMN id SET DEFAULT nextval('reports_category_settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_comments ALTER COLUMN id SET DEFAULT nextval('reports_comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_custom_field ALTER COLUMN id SET DEFAULT nextval('reports_custom_field_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_custom_field_data ALTER COLUMN id SET DEFAULT nextval('reports_custom_fields_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_feedback_images ALTER COLUMN id SET DEFAULT nextval('reports_feedback_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_feedbacks ALTER COLUMN id SET DEFAULT nextval('reports_feedbacks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_images ALTER COLUMN id SET DEFAULT nextval('reports_images_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_item_histories ALTER COLUMN id SET DEFAULT nextval('reports_item_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_item_status_histories ALTER COLUMN id SET DEFAULT nextval('reports_item_status_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_items ALTER COLUMN id SET DEFAULT nextval('reports_items_id_seq'::regclass);


--
-- Name: protocol; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_items ALTER COLUMN protocol SET DEFAULT nextval('protocol_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_notification_types ALTER COLUMN id SET DEFAULT nextval('reports_notification_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_notifications ALTER COLUMN id SET DEFAULT nextval('reports_notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_offensive_flags ALTER COLUMN id SET DEFAULT nextval('reports_offensive_flags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_perimeters ALTER COLUMN id SET DEFAULT nextval('reports_perimeters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_statuses ALTER COLUMN id SET DEFAULT nextval('reports_statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports_statuses_reports_categories ALTER COLUMN id SET DEFAULT nextval('reports_statuses_reports_categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY resolution_states ALTER COLUMN id SET DEFAULT nextval('resolution_states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY steps ALTER COLUMN id SET DEFAULT nextval('steps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trigger_conditions ALTER COLUMN id SET DEFAULT nextval('trigger_conditions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY triggers ALTER COLUMN id SET DEFAULT nextval('triggers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: access_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY access_keys
    ADD CONSTRAINT access_keys_pkey PRIMARY KEY (id);


--
-- Name: business_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY business_reports
    ADD CONSTRAINT business_reports_pkey PRIMARY KEY (id);


--
-- Name: case_step_data_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY case_step_data_attachments
    ADD CONSTRAINT case_step_data_attachments_pkey PRIMARY KEY (id);


--
-- Name: case_step_data_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY case_step_data_fields
    ADD CONSTRAINT case_step_data_fields_pkey PRIMARY KEY (id);


--
-- Name: case_step_data_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY case_step_data_images
    ADD CONSTRAINT case_step_data_images_pkey PRIMARY KEY (id);


--
-- Name: case_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY case_steps
    ADD CONSTRAINT case_steps_pkey PRIMARY KEY (id);


--
-- Name: cases_log_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cases_log_entries
    ADD CONSTRAINT cases_log_entries_pkey PRIMARY KEY (id);


--
-- Name: cases_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cases
    ADD CONSTRAINT cases_pkey PRIMARY KEY (id);


--
-- Name: chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: chat_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY chat_rooms
    ADD CONSTRAINT chat_rooms_pkey PRIMARY KEY (id);


--
-- Name: feature_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY feature_flags
    ADD CONSTRAINT feature_flags_pkey PRIMARY KEY (id);


--
-- Name: fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- Name: flows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY flows
    ADD CONSTRAINT flows_pkey PRIMARY KEY (id);


--
-- Name: group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_permissions
    ADD CONSTRAINT group_permissions_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: groups_users_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups_users_tables
    ADD CONSTRAINT groups_users_tables_pkey PRIMARY KEY (id);


--
-- Name: inventory_analysis_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_analysis_scores
    ADD CONSTRAINT inventory_analysis_scores_pkey PRIMARY KEY (id);


--
-- Name: inventory_analyzes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_analyzes
    ADD CONSTRAINT inventory_analyzes_pkey PRIMARY KEY (id);


--
-- Name: inventory_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_categories
    ADD CONSTRAINT inventory_categories_pkey PRIMARY KEY (id);


--
-- Name: inventory_field_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_field_options
    ADD CONSTRAINT inventory_field_options_pkey PRIMARY KEY (id);


--
-- Name: inventory_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_fields
    ADD CONSTRAINT inventory_fields_pkey PRIMARY KEY (id);


--
-- Name: inventory_formula_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_formula_alerts
    ADD CONSTRAINT inventory_formula_alerts_pkey PRIMARY KEY (id);


--
-- Name: inventory_formula_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_formula_conditions
    ADD CONSTRAINT inventory_formula_conditions_pkey PRIMARY KEY (id);


--
-- Name: inventory_formula_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_formula_histories
    ADD CONSTRAINT inventory_formula_histories_pkey PRIMARY KEY (id);


--
-- Name: inventory_formulas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_formulas
    ADD CONSTRAINT inventory_formulas_pkey PRIMARY KEY (id);


--
-- Name: inventory_item_data_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_item_data_attachments
    ADD CONSTRAINT inventory_item_data_attachments_pkey PRIMARY KEY (id);


--
-- Name: inventory_item_data_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_item_data_histories
    ADD CONSTRAINT inventory_item_data_histories_pkey PRIMARY KEY (id);


--
-- Name: inventory_item_data_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_item_data_images
    ADD CONSTRAINT inventory_item_data_images_pkey PRIMARY KEY (id);


--
-- Name: inventory_item_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_item_data
    ADD CONSTRAINT inventory_item_data_pkey PRIMARY KEY (id);


--
-- Name: inventory_item_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_item_histories
    ADD CONSTRAINT inventory_item_histories_pkey PRIMARY KEY (id);


--
-- Name: inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_items
    ADD CONSTRAINT inventory_items_pkey PRIMARY KEY (id);


--
-- Name: inventory_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_sections
    ADD CONSTRAINT inventory_sections_pkey PRIMARY KEY (id);


--
-- Name: inventory_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_statuses
    ADD CONSTRAINT inventory_statuses_pkey PRIMARY KEY (id);


--
-- Name: namespaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY namespaces
    ADD CONSTRAINT namespaces_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: reports_categories_perimeters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_categories_perimeters
    ADD CONSTRAINT reports_categories_perimeters_pkey PRIMARY KEY (id);


--
-- Name: reports_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_categories
    ADD CONSTRAINT reports_categories_pkey PRIMARY KEY (id);


--
-- Name: reports_category_custom_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_category_custom_fields
    ADD CONSTRAINT reports_category_custom_fields_pkey PRIMARY KEY (id);


--
-- Name: reports_category_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_category_settings
    ADD CONSTRAINT reports_category_settings_pkey PRIMARY KEY (id);


--
-- Name: reports_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_comments
    ADD CONSTRAINT reports_comments_pkey PRIMARY KEY (id);


--
-- Name: reports_custom_field_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_custom_field
    ADD CONSTRAINT reports_custom_field_pkey PRIMARY KEY (id);


--
-- Name: reports_custom_fields_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_custom_field_data
    ADD CONSTRAINT reports_custom_fields_data_pkey PRIMARY KEY (id);


--
-- Name: reports_feedback_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_feedback_images
    ADD CONSTRAINT reports_feedback_images_pkey PRIMARY KEY (id);


--
-- Name: reports_feedbacks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_feedbacks
    ADD CONSTRAINT reports_feedbacks_pkey PRIMARY KEY (id);


--
-- Name: reports_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_images
    ADD CONSTRAINT reports_images_pkey PRIMARY KEY (id);


--
-- Name: reports_item_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_item_histories
    ADD CONSTRAINT reports_item_histories_pkey PRIMARY KEY (id);


--
-- Name: reports_item_status_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_item_status_histories
    ADD CONSTRAINT reports_item_status_histories_pkey PRIMARY KEY (id);


--
-- Name: reports_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_items
    ADD CONSTRAINT reports_items_pkey PRIMARY KEY (id);


--
-- Name: reports_notification_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_notification_types
    ADD CONSTRAINT reports_notification_types_pkey PRIMARY KEY (id);


--
-- Name: reports_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_notifications
    ADD CONSTRAINT reports_notifications_pkey PRIMARY KEY (id);


--
-- Name: reports_offensive_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_offensive_flags
    ADD CONSTRAINT reports_offensive_flags_pkey PRIMARY KEY (id);


--
-- Name: reports_perimeters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_perimeters
    ADD CONSTRAINT reports_perimeters_pkey PRIMARY KEY (id);


--
-- Name: reports_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_statuses
    ADD CONSTRAINT reports_statuses_pkey PRIMARY KEY (id);


--
-- Name: reports_statuses_reports_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports_statuses_reports_categories
    ADD CONSTRAINT reports_statuses_reports_categories_pkey PRIMARY KEY (id);


--
-- Name: resolution_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resolution_states
    ADD CONSTRAINT resolution_states_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: steps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY steps
    ADD CONSTRAINT steps_pkey PRIMARY KEY (id);


--
-- Name: trigger_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY trigger_conditions
    ADD CONSTRAINT trigger_conditions_pkey PRIMARY KEY (id);


--
-- Name: triggers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY triggers
    ADD CONSTRAINT triggers_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_access_keys_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_access_keys_on_key ON access_keys USING btree (key);


--
-- Name: index_access_keys_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_access_keys_on_user_id ON access_keys USING btree (user_id);


--
-- Name: index_business_reports_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_business_reports_on_namespace_id ON business_reports USING btree (namespace_id);


--
-- Name: index_case_step_data_attachments_on_case_step_data_field_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_case_step_data_attachments_on_case_step_data_field_id ON case_step_data_attachments USING btree (case_step_data_field_id);


--
-- Name: index_case_step_data_fields_on_case_step_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_case_step_data_fields_on_case_step_id ON case_step_data_fields USING btree (case_step_id);


--
-- Name: index_case_step_data_images_on_case_step_data_field_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_case_step_data_images_on_case_step_data_field_id ON case_step_data_images USING btree (case_step_data_field_id);


--
-- Name: index_case_steps_on_case_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_case_steps_on_case_id ON case_steps USING btree (case_id);


--
-- Name: index_case_steps_on_created_by_id_and_updated_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_case_steps_on_created_by_id_and_updated_by_id ON case_steps USING btree (created_by_id, updated_by_id);


--
-- Name: index_case_steps_on_responsible_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_case_steps_on_responsible_group_id ON case_steps USING btree (responsible_group_id);


--
-- Name: index_case_steps_on_responsible_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_case_steps_on_responsible_user_id ON case_steps USING btree (responsible_user_id);


--
-- Name: index_case_steps_on_step_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_case_steps_on_step_id ON case_steps USING btree (step_id);


--
-- Name: index_cases_log_entries_on_case_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_log_entries_on_case_id ON cases_log_entries USING btree (case_id);


--
-- Name: index_cases_log_entries_on_flow_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_log_entries_on_flow_id ON cases_log_entries USING btree (flow_id);


--
-- Name: index_cases_log_entries_on_step_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_log_entries_on_step_id ON cases_log_entries USING btree (step_id);


--
-- Name: index_cases_log_entries_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_log_entries_on_user_id ON cases_log_entries USING btree (user_id);


--
-- Name: index_cases_on_created_by_id_and_updated_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_on_created_by_id_and_updated_by_id ON cases USING btree (created_by_id, updated_by_id);


--
-- Name: index_cases_on_initial_flow_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_on_initial_flow_id ON cases USING btree (initial_flow_id);


--
-- Name: index_cases_on_initial_flow_id_and_flow_version; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_on_initial_flow_id_and_flow_version ON cases USING btree (initial_flow_id, flow_version);


--
-- Name: index_cases_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_on_namespace_id ON cases USING btree (namespace_id);


--
-- Name: index_cases_on_original_case_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_on_original_case_id ON cases USING btree (original_case_id);


--
-- Name: index_cases_on_source_reports_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_on_source_reports_category_id ON cases USING btree (source_reports_category_id);


--
-- Name: index_cases_on_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cases_on_status ON cases USING btree (status);


--
-- Name: index_chat_rooms_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_chat_rooms_on_namespace_id ON chat_rooms USING btree (namespace_id);


--
-- Name: index_fields_on_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fields_on_active ON fields USING btree (active);


--
-- Name: index_fields_on_draft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fields_on_draft ON fields USING btree (draft);


--
-- Name: index_fields_on_field_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fields_on_field_type ON fields USING btree (field_type);


--
-- Name: index_fields_on_step_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fields_on_step_id ON fields USING btree (step_id);


--
-- Name: index_flows_on_initial; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_flows_on_initial ON flows USING btree (initial);


--
-- Name: index_flows_on_status_and_current_version_and_draft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_flows_on_status_and_current_version_and_draft ON flows USING btree (status, current_version, draft);


--
-- Name: index_flows_on_step_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_flows_on_step_id ON flows USING btree (step_id);


--
-- Name: index_group_permissions_on_can_execute_step; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_can_execute_step ON group_permissions USING gin (can_execute_step);


--
-- Name: index_group_permissions_on_can_view_step; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_can_view_step ON group_permissions USING gin (can_view_step);


--
-- Name: index_group_permissions_on_flow_can_delete_all_cases; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_flow_can_delete_all_cases ON group_permissions USING gin (flow_can_delete_all_cases);


--
-- Name: index_group_permissions_on_flow_can_delete_own_cases; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_flow_can_delete_own_cases ON group_permissions USING gin (flow_can_delete_own_cases);


--
-- Name: index_group_permissions_on_flow_can_execute_all_steps; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_flow_can_execute_all_steps ON group_permissions USING gin (flow_can_execute_all_steps);


--
-- Name: index_group_permissions_on_flow_can_view_all_steps; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_flow_can_view_all_steps ON group_permissions USING gin (flow_can_view_all_steps);


--
-- Name: index_group_permissions_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_group_id ON group_permissions USING btree (group_id);


--
-- Name: index_group_permissions_on_groups_can_edit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_groups_can_edit ON group_permissions USING gin (groups_can_edit);


--
-- Name: index_group_permissions_on_groups_can_view; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_groups_can_view ON group_permissions USING gin (groups_can_view);


--
-- Name: index_group_permissions_on_inventory_categories_can_edit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_inventory_categories_can_edit ON group_permissions USING gin (inventory_categories_can_edit);


--
-- Name: index_group_permissions_on_inventory_categories_can_view; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_inventory_categories_can_view ON group_permissions USING gin (inventory_categories_can_view);


--
-- Name: index_group_permissions_on_inventory_fields_can_edit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_inventory_fields_can_edit ON group_permissions USING gin (inventory_fields_can_edit);


--
-- Name: index_group_permissions_on_inventory_fields_can_view; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_inventory_fields_can_view ON group_permissions USING gin (inventory_fields_can_view);


--
-- Name: index_group_permissions_on_inventory_sections_can_edit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_inventory_sections_can_edit ON group_permissions USING gin (inventory_sections_can_edit);


--
-- Name: index_group_permissions_on_inventory_sections_can_view; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_inventory_sections_can_view ON group_permissions USING gin (inventory_sections_can_view);


--
-- Name: index_group_permissions_on_reports_categories_can_edit; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_reports_categories_can_edit ON group_permissions USING gin (reports_categories_can_edit);


--
-- Name: index_group_permissions_on_reports_categories_can_view; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_reports_categories_can_view ON group_permissions USING gin (reports_categories_can_view);


--
-- Name: index_group_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_group_permissions_on_user_id ON group_permissions USING btree (user_id);


--
-- Name: index_groups_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_namespace_id ON groups USING btree (namespace_id);


--
-- Name: index_groups_users_on_group_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_groups_users_on_group_id_and_user_id ON groups_users USING btree (group_id, user_id);


--
-- Name: index_groups_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_users_on_user_id ON groups_users USING btree (user_id);


--
-- Name: index_inventory_categories_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_categories_on_namespace_id ON inventory_categories USING btree (namespace_id);


--
-- Name: index_inventory_field_options_on_inventory_field_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_field_options_on_inventory_field_id ON inventory_field_options USING btree (inventory_field_id);


--
-- Name: index_inventory_fields_on_inventory_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_fields_on_inventory_section_id ON inventory_fields USING btree (inventory_section_id);


--
-- Name: index_inventory_item_data_images_on_inventory_item_data_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_item_data_images_on_inventory_item_data_id ON inventory_item_data_images USING btree (inventory_item_data_id);


--
-- Name: index_inventory_item_data_on_inventory_field_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_item_data_on_inventory_field_id ON inventory_item_data USING btree (inventory_field_id);


--
-- Name: index_inventory_item_data_on_inventory_field_option_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_item_data_on_inventory_field_option_ids ON inventory_item_data USING btree (inventory_field_option_ids);


--
-- Name: index_inventory_item_data_on_inventory_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_item_data_on_inventory_item_id ON inventory_item_data USING btree (inventory_item_id);


--
-- Name: index_inventory_item_histories_on_inventory_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_item_histories_on_inventory_item_id ON inventory_item_histories USING btree (inventory_item_id);


--
-- Name: index_inventory_item_histories_on_kind; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_item_histories_on_kind ON inventory_item_histories USING btree (kind);


--
-- Name: index_inventory_item_histories_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_item_histories_on_user_id ON inventory_item_histories USING btree (user_id);


--
-- Name: index_inventory_items_on_inventory_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_items_on_inventory_category_id ON inventory_items USING btree (inventory_category_id);


--
-- Name: index_inventory_items_on_inventory_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_items_on_inventory_status_id ON inventory_items USING btree (inventory_status_id);


--
-- Name: index_inventory_items_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_items_on_namespace_id ON inventory_items USING btree (namespace_id);


--
-- Name: index_inventory_items_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_items_on_user_id ON inventory_items USING btree (user_id);


--
-- Name: index_inventory_sections_on_inventory_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_sections_on_inventory_category_id ON inventory_sections USING btree (inventory_category_id);


--
-- Name: index_inventory_statuses_on_inventory_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_inventory_statuses_on_inventory_category_id ON inventory_statuses USING btree (inventory_category_id);


--
-- Name: index_item_data_histories_on_item_data_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_data_histories_on_item_data_id ON inventory_item_data_histories USING btree (inventory_item_data_id);


--
-- Name: index_item_data_histories_on_item_history_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_data_histories_on_item_history_id ON inventory_item_data_histories USING btree (inventory_item_history_id);


--
-- Name: index_namespaces_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_namespaces_on_name ON namespaces USING btree (name);


--
-- Name: index_reports_categories_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_categories_on_namespace_id ON reports_categories USING btree (namespace_id);


--
-- Name: index_reports_categories_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_categories_on_parent_id ON reports_categories USING btree (parent_id);


--
-- Name: index_reports_categories_perimeters_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_categories_perimeters_on_namespace_id ON reports_categories_perimeters USING btree (namespace_id);


--
-- Name: index_reports_category_settings_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_category_settings_on_namespace_id ON reports_category_settings USING btree (namespace_id);


--
-- Name: index_reports_category_settings_on_reports_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_category_settings_on_reports_category_id ON reports_category_settings USING btree (reports_category_id);


--
-- Name: index_reports_feedback_images_on_reports_feedback_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_feedback_images_on_reports_feedback_id ON reports_feedback_images USING btree (reports_feedback_id);


--
-- Name: index_reports_feedbacks_on_reports_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_feedbacks_on_reports_item_id ON reports_feedbacks USING btree (reports_item_id);


--
-- Name: index_reports_feedbacks_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_feedbacks_on_user_id ON reports_feedbacks USING btree (user_id);


--
-- Name: index_reports_images_on_reports_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_images_on_reports_item_id ON reports_images USING btree (reports_item_id);


--
-- Name: index_reports_item_histories_on_kind; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_item_histories_on_kind ON reports_item_histories USING btree (kind);


--
-- Name: index_reports_item_histories_on_reports_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_item_histories_on_reports_item_id ON reports_item_histories USING btree (reports_item_id);


--
-- Name: index_reports_item_histories_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_item_histories_on_user_id ON reports_item_histories USING btree (user_id);


--
-- Name: index_reports_items_on_inventory_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_items_on_inventory_item_id ON reports_items USING btree (inventory_item_id);


--
-- Name: index_reports_items_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_items_on_namespace_id ON reports_items USING btree (namespace_id);


--
-- Name: index_reports_items_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_items_on_position ON reports_items USING gist ("position");


--
-- Name: index_reports_items_on_protocol; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_items_on_protocol ON reports_items USING btree (protocol);


--
-- Name: index_reports_items_on_reports_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_items_on_reports_category_id ON reports_items USING btree (reports_category_id);


--
-- Name: index_reports_items_on_reports_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_items_on_reports_status_id ON reports_items USING btree (reports_status_id);


--
-- Name: index_reports_items_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_items_on_user_id ON reports_items USING btree (user_id);


--
-- Name: index_reports_items_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_items_on_uuid ON reports_items USING btree (uuid);


--
-- Name: index_reports_notification_types_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_notification_types_on_namespace_id ON reports_notification_types USING btree (namespace_id);


--
-- Name: index_reports_notifications_on_reports_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_notifications_on_reports_item_id ON reports_notifications USING btree (reports_item_id);


--
-- Name: index_reports_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_notifications_on_user_id ON reports_notifications USING btree (user_id);


--
-- Name: index_reports_offensive_flags_on_reports_item_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_reports_offensive_flags_on_reports_item_id_and_user_id ON reports_offensive_flags USING btree (reports_item_id, user_id);


--
-- Name: index_reports_perimeters_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_perimeters_on_namespace_id ON reports_perimeters USING btree (namespace_id);


--
-- Name: index_reports_statuses_item_and_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_statuses_item_and_status_id ON reports_statuses_reports_categories USING btree (reports_status_id, reports_category_id);


--
-- Name: index_reports_statuses_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_statuses_item_id ON reports_statuses_reports_categories USING btree (reports_category_id);


--
-- Name: index_reports_statuses_on_reports_category_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_statuses_on_reports_category_id ON reports_statuses USING btree (reports_category_id);


--
-- Name: index_reports_statuses_reports_categories_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_statuses_reports_categories_on_namespace_id ON reports_statuses_reports_categories USING btree (namespace_id);


--
-- Name: index_resolution_states_on_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resolution_states_on_active ON resolution_states USING btree (active);


--
-- Name: index_resolution_states_on_default; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resolution_states_on_default ON resolution_states USING btree ("default");


--
-- Name: index_resolution_states_on_draft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resolution_states_on_draft ON resolution_states USING btree (draft);


--
-- Name: index_resolution_states_on_flow_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resolution_states_on_flow_id ON resolution_states USING btree (flow_id);


--
-- Name: index_steps_on_draft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_steps_on_draft ON steps USING btree (draft);


--
-- Name: index_steps_on_flow_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_steps_on_flow_id ON steps USING btree (flow_id);


--
-- Name: index_steps_on_step_type_and_flow_id_and_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_steps_on_step_type_and_flow_id_and_active ON steps USING btree (step_type, flow_id, active);


--
-- Name: index_trigger_conditions_on_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trigger_conditions_on_active ON trigger_conditions USING btree (active);


--
-- Name: index_trigger_conditions_on_draft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trigger_conditions_on_draft ON trigger_conditions USING btree (draft);


--
-- Name: index_trigger_conditions_on_field_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trigger_conditions_on_field_id ON trigger_conditions USING btree (field_id);


--
-- Name: index_trigger_conditions_on_trigger_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_trigger_conditions_on_trigger_id ON trigger_conditions USING btree (trigger_id);


--
-- Name: index_triggers_on_active; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_triggers_on_active ON triggers USING btree (active);


--
-- Name: index_triggers_on_draft; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_triggers_on_draft ON triggers USING btree (draft);


--
-- Name: index_triggers_on_step_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_triggers_on_step_id ON triggers USING btree (step_id);


--
-- Name: index_users_email_trigram; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_email_trigram ON users USING gist (email gist_trgm_ops);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_kind; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_kind ON users USING btree (kind);


--
-- Name: index_users_on_namespace_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_namespace_id ON users USING btree (namespace_id);


--
-- Name: index_users_on_tsv_document; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_tsv_document ON users USING gin (tsv_document);


--
-- Name: index_users_on_tsv_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_tsv_name ON users USING gin (tsv_name);


--
-- Name: index_users_on_tsv_query; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_tsv_query ON users USING gin (tsv_query);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: rep_cat_inv_cat_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX rep_cat_inv_cat_index ON inventory_categories_reports_categories USING btree (reports_category_id, inventory_category_id);


--
-- Name: unique_category_custom_field_relation; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_category_custom_field_relation ON reports_category_custom_fields USING btree (reports_category_id, reports_custom_field_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: users_tsv_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER users_tsv_trigger BEFORE INSERT OR UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE users_tsv_updater();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20131210005139');

INSERT INTO schema_migrations (version) VALUES ('20131211201749');

INSERT INTO schema_migrations (version) VALUES ('20131218213852');

INSERT INTO schema_migrations (version) VALUES ('20131218214403');

INSERT INTO schema_migrations (version) VALUES ('20131219094333');

INSERT INTO schema_migrations (version) VALUES ('20140104151410');

INSERT INTO schema_migrations (version) VALUES ('20140105160701');

INSERT INTO schema_migrations (version) VALUES ('20140105160935');

INSERT INTO schema_migrations (version) VALUES ('20140105161539');

INSERT INTO schema_migrations (version) VALUES ('20140105162437');

INSERT INTO schema_migrations (version) VALUES ('20140105164407');

INSERT INTO schema_migrations (version) VALUES ('20140105174315');

INSERT INTO schema_migrations (version) VALUES ('20140107180058');

INSERT INTO schema_migrations (version) VALUES ('20140109081723');

INSERT INTO schema_migrations (version) VALUES ('20140109162731');

INSERT INTO schema_migrations (version) VALUES ('20140109213920');

INSERT INTO schema_migrations (version) VALUES ('20140109214248');

INSERT INTO schema_migrations (version) VALUES ('20140110013145');

INSERT INTO schema_migrations (version) VALUES ('20140112054205');

INSERT INTO schema_migrations (version) VALUES ('20140112055003');

INSERT INTO schema_migrations (version) VALUES ('20140112062437');

INSERT INTO schema_migrations (version) VALUES ('20140112180211');

INSERT INTO schema_migrations (version) VALUES ('20140112213049');

INSERT INTO schema_migrations (version) VALUES ('20140115012934');

INSERT INTO schema_migrations (version) VALUES ('20140118145938');

INSERT INTO schema_migrations (version) VALUES ('20140130013924');

INSERT INTO schema_migrations (version) VALUES ('20140206035204');

INSERT INTO schema_migrations (version) VALUES ('20140206085452');

INSERT INTO schema_migrations (version) VALUES ('20140220210831');

INSERT INTO schema_migrations (version) VALUES ('20140222041435');

INSERT INTO schema_migrations (version) VALUES ('20140223223133');

INSERT INTO schema_migrations (version) VALUES ('20140225144646');

INSERT INTO schema_migrations (version) VALUES ('20140225162716');

INSERT INTO schema_migrations (version) VALUES ('20140227143733');

INSERT INTO schema_migrations (version) VALUES ('20140228160924');

INSERT INTO schema_migrations (version) VALUES ('20140303161655');

INSERT INTO schema_migrations (version) VALUES ('20140306154659');

INSERT INTO schema_migrations (version) VALUES ('20140309161935');

INSERT INTO schema_migrations (version) VALUES ('20140310191829');

INSERT INTO schema_migrations (version) VALUES ('20140322172226');

INSERT INTO schema_migrations (version) VALUES ('20140323004159');

INSERT INTO schema_migrations (version) VALUES ('20140326013301');

INSERT INTO schema_migrations (version) VALUES ('20140410185937');

INSERT INTO schema_migrations (version) VALUES ('20140410192530');

INSERT INTO schema_migrations (version) VALUES ('20140413155411');

INSERT INTO schema_migrations (version) VALUES ('20140413171638');

INSERT INTO schema_migrations (version) VALUES ('20140413174825');

INSERT INTO schema_migrations (version) VALUES ('20140413225522');

INSERT INTO schema_migrations (version) VALUES ('20140414052026');

INSERT INTO schema_migrations (version) VALUES ('20140414151025');

INSERT INTO schema_migrations (version) VALUES ('20140414163245');

INSERT INTO schema_migrations (version) VALUES ('20140415163548');

INSERT INTO schema_migrations (version) VALUES ('20140417012832');

INSERT INTO schema_migrations (version) VALUES ('20140417155309');

INSERT INTO schema_migrations (version) VALUES ('20140418143032');

INSERT INTO schema_migrations (version) VALUES ('20140418224038');

INSERT INTO schema_migrations (version) VALUES ('20140419030558');

INSERT INTO schema_migrations (version) VALUES ('20140419033015');

INSERT INTO schema_migrations (version) VALUES ('20140421205702');

INSERT INTO schema_migrations (version) VALUES ('20140423020533');

INSERT INTO schema_migrations (version) VALUES ('20140425182032');

INSERT INTO schema_migrations (version) VALUES ('20140426215652');

INSERT INTO schema_migrations (version) VALUES ('20140427035209');

INSERT INTO schema_migrations (version) VALUES ('20140427171701');

INSERT INTO schema_migrations (version) VALUES ('20140427192626');

INSERT INTO schema_migrations (version) VALUES ('20140428005455');

INSERT INTO schema_migrations (version) VALUES ('20140428035831');

INSERT INTO schema_migrations (version) VALUES ('20140428040611');

INSERT INTO schema_migrations (version) VALUES ('20140428193137');

INSERT INTO schema_migrations (version) VALUES ('20140428203113');

INSERT INTO schema_migrations (version) VALUES ('20140429163053');

INSERT INTO schema_migrations (version) VALUES ('20140429183149');

INSERT INTO schema_migrations (version) VALUES ('20140502081441');

INSERT INTO schema_migrations (version) VALUES ('20140502081658');

INSERT INTO schema_migrations (version) VALUES ('20140502081926');

INSERT INTO schema_migrations (version) VALUES ('20140503102834');

INSERT INTO schema_migrations (version) VALUES ('20140506031921');

INSERT INTO schema_migrations (version) VALUES ('20140513030717');

INSERT INTO schema_migrations (version) VALUES ('20140521212036');

INSERT INTO schema_migrations (version) VALUES ('20140522215022');

INSERT INTO schema_migrations (version) VALUES ('20140524232406');

INSERT INTO schema_migrations (version) VALUES ('20140528124819');

INSERT INTO schema_migrations (version) VALUES ('20140528135338');

INSERT INTO schema_migrations (version) VALUES ('20140529065036');

INSERT INTO schema_migrations (version) VALUES ('20140529073626');

INSERT INTO schema_migrations (version) VALUES ('20140531024202');

INSERT INTO schema_migrations (version) VALUES ('20140602232731');

INSERT INTO schema_migrations (version) VALUES ('20140603211607');

INSERT INTO schema_migrations (version) VALUES ('20140604174126');

INSERT INTO schema_migrations (version) VALUES ('20140604180408');

INSERT INTO schema_migrations (version) VALUES ('20140604210601');

INSERT INTO schema_migrations (version) VALUES ('20140611154438');

INSERT INTO schema_migrations (version) VALUES ('20141012155702');

INSERT INTO schema_migrations (version) VALUES ('20141012195527');

INSERT INTO schema_migrations (version) VALUES ('20141016041226');

INSERT INTO schema_migrations (version) VALUES ('20141020033051');

INSERT INTO schema_migrations (version) VALUES ('20141101170347');

INSERT INTO schema_migrations (version) VALUES ('20141104052513');

INSERT INTO schema_migrations (version) VALUES ('20141113234743');

INSERT INTO schema_migrations (version) VALUES ('20141117074254');

INSERT INTO schema_migrations (version) VALUES ('20141117075659');

INSERT INTO schema_migrations (version) VALUES ('20141120145605');

INSERT INTO schema_migrations (version) VALUES ('20141121004316');

INSERT INTO schema_migrations (version) VALUES ('20141130182852');

INSERT INTO schema_migrations (version) VALUES ('20141201053232');

INSERT INTO schema_migrations (version) VALUES ('20141207195345');

INSERT INTO schema_migrations (version) VALUES ('20141211023306');

INSERT INTO schema_migrations (version) VALUES ('20141211023641');

INSERT INTO schema_migrations (version) VALUES ('20141217010925');

INSERT INTO schema_migrations (version) VALUES ('20150110150431');

INSERT INTO schema_migrations (version) VALUES ('20150129161233');

INSERT INTO schema_migrations (version) VALUES ('20150201220437');

INSERT INTO schema_migrations (version) VALUES ('20150201230257');

INSERT INTO schema_migrations (version) VALUES ('20150206015051');

INSERT INTO schema_migrations (version) VALUES ('20150206171519');

INSERT INTO schema_migrations (version) VALUES ('20150210160647');

INSERT INTO schema_migrations (version) VALUES ('20150211193056');

INSERT INTO schema_migrations (version) VALUES ('20150213132937');

INSERT INTO schema_migrations (version) VALUES ('20150213160316');

INSERT INTO schema_migrations (version) VALUES ('20150214182618');

INSERT INTO schema_migrations (version) VALUES ('20150216012932');

INSERT INTO schema_migrations (version) VALUES ('20150223134258');

INSERT INTO schema_migrations (version) VALUES ('20150223143733');

INSERT INTO schema_migrations (version) VALUES ('20150223163753');

INSERT INTO schema_migrations (version) VALUES ('20150223164434');

INSERT INTO schema_migrations (version) VALUES ('20150223171012');

INSERT INTO schema_migrations (version) VALUES ('20150224052905');

INSERT INTO schema_migrations (version) VALUES ('20150224064659');

INSERT INTO schema_migrations (version) VALUES ('20150224065136');

INSERT INTO schema_migrations (version) VALUES ('20150224065538');

INSERT INTO schema_migrations (version) VALUES ('20150224140156');

INSERT INTO schema_migrations (version) VALUES ('20150224142848');

INSERT INTO schema_migrations (version) VALUES ('20150224170659');

INSERT INTO schema_migrations (version) VALUES ('20150225060653');

INSERT INTO schema_migrations (version) VALUES ('20150225061737');

INSERT INTO schema_migrations (version) VALUES ('20150225064808');

INSERT INTO schema_migrations (version) VALUES ('20150225145408');

INSERT INTO schema_migrations (version) VALUES ('20150304022710');

INSERT INTO schema_migrations (version) VALUES ('20150305164102');

INSERT INTO schema_migrations (version) VALUES ('20150309132221');

INSERT INTO schema_migrations (version) VALUES ('20150314163933');

INSERT INTO schema_migrations (version) VALUES ('20150315045045');

INSERT INTO schema_migrations (version) VALUES ('20150315185646');

INSERT INTO schema_migrations (version) VALUES ('20150318055535');

INSERT INTO schema_migrations (version) VALUES ('20150319090902');

INSERT INTO schema_migrations (version) VALUES ('20150324053934');

INSERT INTO schema_migrations (version) VALUES ('20150324061354');

INSERT INTO schema_migrations (version) VALUES ('20150327065607');

INSERT INTO schema_migrations (version) VALUES ('20150330171718');

INSERT INTO schema_migrations (version) VALUES ('20150408054541');

INSERT INTO schema_migrations (version) VALUES ('20150408081906');

INSERT INTO schema_migrations (version) VALUES ('20150408082915');

INSERT INTO schema_migrations (version) VALUES ('20150408083403');

INSERT INTO schema_migrations (version) VALUES ('20150409041753');

INSERT INTO schema_migrations (version) VALUES ('20150409063423');

INSERT INTO schema_migrations (version) VALUES ('20150409170131');

INSERT INTO schema_migrations (version) VALUES ('20150409234826');

INSERT INTO schema_migrations (version) VALUES ('20150417034700');

INSERT INTO schema_migrations (version) VALUES ('20150421072619');

INSERT INTO schema_migrations (version) VALUES ('20150430154737');

INSERT INTO schema_migrations (version) VALUES ('20150507023633');

INSERT INTO schema_migrations (version) VALUES ('20150507150957');

INSERT INTO schema_migrations (version) VALUES ('20150507150958');

INSERT INTO schema_migrations (version) VALUES ('20150512011315');

INSERT INTO schema_migrations (version) VALUES ('20150512013645');

INSERT INTO schema_migrations (version) VALUES ('20150514155459');

INSERT INTO schema_migrations (version) VALUES ('20150514155637');

INSERT INTO schema_migrations (version) VALUES ('20150515181125');

INSERT INTO schema_migrations (version) VALUES ('20150515181219');

INSERT INTO schema_migrations (version) VALUES ('20150521181706');

INSERT INTO schema_migrations (version) VALUES ('20150529012138');

INSERT INTO schema_migrations (version) VALUES ('20150605162625');

INSERT INTO schema_migrations (version) VALUES ('20150606181847');

INSERT INTO schema_migrations (version) VALUES ('20150607033706');

INSERT INTO schema_migrations (version) VALUES ('20150618151455');

INSERT INTO schema_migrations (version) VALUES ('20150629223441');

INSERT INTO schema_migrations (version) VALUES ('20150710081249');

INSERT INTO schema_migrations (version) VALUES ('20150710081250');

INSERT INTO schema_migrations (version) VALUES ('20150710203119');

INSERT INTO schema_migrations (version) VALUES ('20150710220221');

INSERT INTO schema_migrations (version) VALUES ('20150715104914');

INSERT INTO schema_migrations (version) VALUES ('20150715110819');

INSERT INTO schema_migrations (version) VALUES ('20150716190349');

INSERT INTO schema_migrations (version) VALUES ('20150717121654');

INSERT INTO schema_migrations (version) VALUES ('20150819001046');

INSERT INTO schema_migrations (version) VALUES ('20150825142934');

INSERT INTO schema_migrations (version) VALUES ('20150826234058');

INSERT INTO schema_migrations (version) VALUES ('20150911153316');

INSERT INTO schema_migrations (version) VALUES ('20150921175449');

INSERT INTO schema_migrations (version) VALUES ('20150921191622');

INSERT INTO schema_migrations (version) VALUES ('20150921192557');

INSERT INTO schema_migrations (version) VALUES ('20150921192711');

INSERT INTO schema_migrations (version) VALUES ('20150921201214');

INSERT INTO schema_migrations (version) VALUES ('20150923161752');

INSERT INTO schema_migrations (version) VALUES ('20151007122257');

INSERT INTO schema_migrations (version) VALUES ('20151014155924');

INSERT INTO schema_migrations (version) VALUES ('20151019161818');

INSERT INTO schema_migrations (version) VALUES ('20151020091139');

INSERT INTO schema_migrations (version) VALUES ('20151020165528');

INSERT INTO schema_migrations (version) VALUES ('20151021095714');

INSERT INTO schema_migrations (version) VALUES ('20151021151629');

INSERT INTO schema_migrations (version) VALUES ('20151022100029');

INSERT INTO schema_migrations (version) VALUES ('20151022193514');

INSERT INTO schema_migrations (version) VALUES ('20151026152359');

INSERT INTO schema_migrations (version) VALUES ('20151030195232');

INSERT INTO schema_migrations (version) VALUES ('20151103153315');

INSERT INTO schema_migrations (version) VALUES ('20151111142013');

INSERT INTO schema_migrations (version) VALUES ('20151207152021');

INSERT INTO schema_migrations (version) VALUES ('20151207152030');

INSERT INTO schema_migrations (version) VALUES ('20160116114927');

INSERT INTO schema_migrations (version) VALUES ('20160116154953');

INSERT INTO schema_migrations (version) VALUES ('20160119122840');

INSERT INTO schema_migrations (version) VALUES ('20160120151150');

INSERT INTO schema_migrations (version) VALUES ('20160120223835');

INSERT INTO schema_migrations (version) VALUES ('20160121013718');

INSERT INTO schema_migrations (version) VALUES ('20160122024319');

INSERT INTO schema_migrations (version) VALUES ('20160122024320');

INSERT INTO schema_migrations (version) VALUES ('20160126192938');

INSERT INTO schema_migrations (version) VALUES ('20160215215950');

INSERT INTO schema_migrations (version) VALUES ('20160223143515');

INSERT INTO schema_migrations (version) VALUES ('20160224162244');

INSERT INTO schema_migrations (version) VALUES ('20160225181855');

INSERT INTO schema_migrations (version) VALUES ('20160304210015');

INSERT INTO schema_migrations (version) VALUES ('20160308031440');

INSERT INTO schema_migrations (version) VALUES ('20160321112056');

INSERT INTO schema_migrations (version) VALUES ('20160328140406');

INSERT INTO schema_migrations (version) VALUES ('20160328154811');

INSERT INTO schema_migrations (version) VALUES ('20160330141439');

INSERT INTO schema_migrations (version) VALUES ('20160331230826');

INSERT INTO schema_migrations (version) VALUES ('20160401013331');

INSERT INTO schema_migrations (version) VALUES ('20160412102320');

INSERT INTO schema_migrations (version) VALUES ('20160412112506');

INSERT INTO schema_migrations (version) VALUES ('20160418082151');

INSERT INTO schema_migrations (version) VALUES ('20160427112001');

INSERT INTO schema_migrations (version) VALUES ('20160427135428');

INSERT INTO schema_migrations (version) VALUES ('20160428112139');

INSERT INTO schema_migrations (version) VALUES ('20160428150602');

INSERT INTO schema_migrations (version) VALUES ('20160525151435');

INSERT INTO schema_migrations (version) VALUES ('20160530164213');

INSERT INTO schema_migrations (version) VALUES ('20160531082313');

INSERT INTO schema_migrations (version) VALUES ('20160531182525');

INSERT INTO schema_migrations (version) VALUES ('20160607083359');

INSERT INTO schema_migrations (version) VALUES ('20160608152713');

INSERT INTO schema_migrations (version) VALUES ('20160609150742');

INSERT INTO schema_migrations (version) VALUES ('20160614161808');

INSERT INTO schema_migrations (version) VALUES ('20160614163322');

INSERT INTO schema_migrations (version) VALUES ('20160615091728');

INSERT INTO schema_migrations (version) VALUES ('20160615095242');

INSERT INTO schema_migrations (version) VALUES ('20160622103001');

INSERT INTO schema_migrations (version) VALUES ('20160622112955');

INSERT INTO schema_migrations (version) VALUES ('20160622163004');

INSERT INTO schema_migrations (version) VALUES ('20160705141323');

INSERT INTO schema_migrations (version) VALUES ('20160706134218');

INSERT INTO schema_migrations (version) VALUES ('20160725104534');

INSERT INTO schema_migrations (version) VALUES ('20160725150038');

INSERT INTO schema_migrations (version) VALUES ('20160726132902');

INSERT INTO schema_migrations (version) VALUES ('20160729170333');

INSERT INTO schema_migrations (version) VALUES ('20160805124048');

INSERT INTO schema_migrations (version) VALUES ('20160811173308');

INSERT INTO schema_migrations (version) VALUES ('20160829102132');

INSERT INTO schema_migrations (version) VALUES ('20160831172303');

INSERT INTO schema_migrations (version) VALUES ('20160903172943');


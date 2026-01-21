--
-- PostgreSQL database dump
--

\restrict W64pUbfcXEi6DA1sf8fIVHbVZYIlZyx5tHdxKi7oowUi9geOqkn4uUvTLDsisKX

-- Dumped from database version 17.7
-- Dumped by pg_dump version 17.7 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: allocations; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.allocations (
    id integer NOT NULL,
    invoice_id integer NOT NULL,
    company text NOT NULL,
    brand text,
    department text NOT NULL,
    subdepartment text,
    allocation_percent real NOT NULL,
    allocation_value real NOT NULL,
    responsible text,
    reinvoice_to text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    reinvoice_department text,
    reinvoice_subdepartment text,
    reinvoice_brand text,
    locked boolean DEFAULT false,
    comment text
);


ALTER TABLE public.allocations OWNER TO doadmin;

--
-- Name: allocations_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.allocations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.allocations_id_seq OWNER TO doadmin;

--
-- Name: allocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.allocations_id_seq OWNED BY public.allocations.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    company text NOT NULL,
    brands text,
    vat text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.companies OWNER TO doadmin;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.companies_id_seq OWNER TO doadmin;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: connector_sync_log; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.connector_sync_log (
    id integer NOT NULL,
    connector_id integer NOT NULL,
    sync_type text NOT NULL,
    status text NOT NULL,
    invoices_found integer DEFAULT 0,
    invoices_imported integer DEFAULT 0,
    error_message text,
    details jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.connector_sync_log OWNER TO doadmin;

--
-- Name: connector_sync_log_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.connector_sync_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.connector_sync_log_id_seq OWNER TO doadmin;

--
-- Name: connector_sync_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.connector_sync_log_id_seq OWNED BY public.connector_sync_log.id;


--
-- Name: connectors; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.connectors (
    id integer NOT NULL,
    connector_type text NOT NULL,
    name text NOT NULL,
    status text DEFAULT 'disconnected'::text,
    config jsonb DEFAULT '{}'::jsonb,
    credentials jsonb DEFAULT '{}'::jsonb,
    last_sync timestamp without time zone,
    last_error text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.connectors OWNER TO doadmin;

--
-- Name: connectors_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.connectors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.connectors_id_seq OWNER TO doadmin;

--
-- Name: connectors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.connectors_id_seq OWNED BY public.connectors.id;


--
-- Name: department_structure; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.department_structure (
    id integer NOT NULL,
    company text NOT NULL,
    brand text,
    department text NOT NULL,
    subdepartment text,
    manager text,
    marketing text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    responsable_id integer,
    manager_ids integer[],
    marketing_ids integer[],
    cc_email text
);


ALTER TABLE public.department_structure OWNER TO doadmin;

--
-- Name: department_structure_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.department_structure_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.department_structure_id_seq OWNER TO doadmin;

--
-- Name: department_structure_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.department_structure_id_seq OWNED BY public.department_structure.id;


--
-- Name: invoice_templates; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.invoice_templates (
    id integer NOT NULL,
    name text NOT NULL,
    template_type text DEFAULT 'fixed'::text,
    supplier text,
    supplier_vat text,
    customer_vat text,
    currency text DEFAULT 'RON'::text,
    description text,
    invoice_number_regex text,
    invoice_date_regex text,
    invoice_value_regex text,
    date_format text DEFAULT '%Y-%m-%d'::text,
    supplier_regex text,
    supplier_vat_regex text,
    customer_vat_regex text,
    currency_regex text,
    sample_invoice_path text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.invoice_templates OWNER TO doadmin;

--
-- Name: invoice_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.invoice_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoice_templates_id_seq OWNER TO doadmin;

--
-- Name: invoice_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.invoice_templates_id_seq OWNED BY public.invoice_templates.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    supplier text NOT NULL,
    invoice_template text,
    invoice_number text NOT NULL,
    invoice_date date NOT NULL,
    invoice_value real NOT NULL,
    currency text DEFAULT 'RON'::text,
    drive_link text,
    comment text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    value_ron real,
    value_eur real,
    exchange_rate real,
    deleted_at timestamp without time zone,
    status text DEFAULT 'new'::text,
    payment_status text DEFAULT 'not_paid'::text,
    vat_rate real,
    subtract_vat boolean DEFAULT false,
    net_value real
);


ALTER TABLE public.invoices OWNER TO doadmin;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoices_id_seq OWNER TO doadmin;

--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: notification_log; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.notification_log (
    id integer NOT NULL,
    responsable_id integer,
    invoice_id integer,
    notification_type text NOT NULL,
    subject text,
    message text,
    status text DEFAULT 'pending'::text,
    error_message text,
    sent_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notification_log OWNER TO doadmin;

--
-- Name: notification_log_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.notification_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_log_id_seq OWNER TO doadmin;

--
-- Name: notification_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.notification_log_id_seq OWNED BY public.notification_log.id;


--
-- Name: notification_settings; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.notification_settings (
    id integer NOT NULL,
    setting_key text NOT NULL,
    setting_value text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notification_settings OWNER TO doadmin;

--
-- Name: notification_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.notification_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_settings_id_seq OWNER TO doadmin;

--
-- Name: notification_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.notification_settings_id_seq OWNED BY public.notification_settings.id;


--
-- Name: reinvoice_destinations; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.reinvoice_destinations (
    id integer NOT NULL,
    allocation_id integer NOT NULL,
    company text NOT NULL,
    brand text,
    department text,
    subdepartment text,
    percentage real NOT NULL,
    value real,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.reinvoice_destinations OWNER TO doadmin;

--
-- Name: reinvoice_destinations_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.reinvoice_destinations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reinvoice_destinations_id_seq OWNER TO doadmin;

--
-- Name: reinvoice_destinations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.reinvoice_destinations_id_seq OWNED BY public.reinvoice_destinations.id;


--
-- Name: responsables; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.responsables (
    id integer NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    phone text,
    departments text,
    notify_on_allocation boolean DEFAULT true,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.responsables OWNER TO doadmin;

--
-- Name: responsables_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.responsables_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.responsables_id_seq OWNER TO doadmin;

--
-- Name: responsables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.responsables_id_seq OWNED BY public.responsables.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    can_add_invoices boolean DEFAULT false,
    can_delete_invoices boolean DEFAULT false,
    can_view_invoices boolean DEFAULT false,
    can_access_accounting boolean DEFAULT false,
    can_access_settings boolean DEFAULT false,
    can_access_connectors boolean DEFAULT false,
    can_access_templates boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    can_edit_invoices boolean DEFAULT false
);


ALTER TABLE public.roles OWNER TO doadmin;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO doadmin;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: user_events; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.user_events (
    id integer NOT NULL,
    user_id integer,
    user_email text,
    event_type text NOT NULL,
    event_description text,
    entity_type text,
    entity_id integer,
    ip_address text,
    user_agent text,
    details jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.user_events OWNER TO doadmin;

--
-- Name: user_events_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.user_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_events_id_seq OWNER TO doadmin;

--
-- Name: user_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.user_events_id_seq OWNED BY public.user_events.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    phone text,
    is_active boolean DEFAULT true,
    can_add_invoices boolean DEFAULT true,
    can_delete_invoices boolean DEFAULT false,
    can_view_invoices boolean DEFAULT true,
    can_access_accounting boolean DEFAULT true,
    can_access_settings boolean DEFAULT false,
    can_access_connectors boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    role_id integer,
    password_hash text,
    last_login timestamp without time zone,
    last_seen timestamp without time zone
);


ALTER TABLE public.users OWNER TO doadmin;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO doadmin;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vat_rates; Type: TABLE; Schema: public; Owner: doadmin
--

CREATE TABLE public.vat_rates (
    id integer NOT NULL,
    name text NOT NULL,
    rate real NOT NULL,
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.vat_rates OWNER TO doadmin;

--
-- Name: vat_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: doadmin
--

CREATE SEQUENCE public.vat_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vat_rates_id_seq OWNER TO doadmin;

--
-- Name: vat_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: doadmin
--

ALTER SEQUENCE public.vat_rates_id_seq OWNED BY public.vat_rates.id;


--
-- Name: allocations id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.allocations ALTER COLUMN id SET DEFAULT nextval('public.allocations_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: connector_sync_log id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.connector_sync_log ALTER COLUMN id SET DEFAULT nextval('public.connector_sync_log_id_seq'::regclass);


--
-- Name: connectors id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.connectors ALTER COLUMN id SET DEFAULT nextval('public.connectors_id_seq'::regclass);


--
-- Name: department_structure id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.department_structure ALTER COLUMN id SET DEFAULT nextval('public.department_structure_id_seq'::regclass);


--
-- Name: invoice_templates id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.invoice_templates ALTER COLUMN id SET DEFAULT nextval('public.invoice_templates_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: notification_log id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.notification_log ALTER COLUMN id SET DEFAULT nextval('public.notification_log_id_seq'::regclass);


--
-- Name: notification_settings id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.notification_settings ALTER COLUMN id SET DEFAULT nextval('public.notification_settings_id_seq'::regclass);


--
-- Name: reinvoice_destinations id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.reinvoice_destinations ALTER COLUMN id SET DEFAULT nextval('public.reinvoice_destinations_id_seq'::regclass);


--
-- Name: responsables id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.responsables ALTER COLUMN id SET DEFAULT nextval('public.responsables_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: user_events id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.user_events ALTER COLUMN id SET DEFAULT nextval('public.user_events_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vat_rates id; Type: DEFAULT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.vat_rates ALTER COLUMN id SET DEFAULT nextval('public.vat_rates_id_seq'::regclass);


--
-- Data for Name: allocations; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.allocations (id, invoice_id, company, brand, department, subdepartment, allocation_percent, allocation_value, responsible, reinvoice_to, created_at, reinvoice_department, reinvoice_subdepartment, reinvoice_brand, locked, comment) FROM stdin;
509	138	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	1036.96	Madalina Morutan	\N	2026-01-14 09:56:17.349921	\N	\N	\N	f	\N
513	142	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	181.65	Ioan Mezei	\N	2026-01-14 12:57:57.24897	\N	\N	\N	f	\N
518	145	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	100	188.77	Ovidiu Ciobanca	\N	2026-01-14 14:25:03.393413	\N	\N	\N	f	[MERGED] Original campaigns: ID. Family - Q3, ReMKT T-Cross stoc, T-Cross stoc (form), TD VW - general / LinkClick, TD VW General / FB leads, Test - T-Cross stoc (form)
317	92	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	36.12	1263.8387	Ovidiu Bucur	\N	2026-01-12 12:39:51.750537	\N	\N	\N	f	[MERGED] Original campaigns: GENERARE COMENZI Q4, [CA] Traffic - Interese - Modele masini
318	92	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	19.6	685.804	Ovidiu Bucur	\N	2026-01-12 12:39:51.753937	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Traffic - Mazda CX60, [CA] Leads - Mazda CX80
319	92	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	14.84	519.2516	Ovidiu Bucur	\N	2026-01-12 12:39:51.758656	\N	\N	\N	f	[CA] Leads - Modele MG HS
320	92	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	29.44	1030.1056	Ovidiu Bucur	\N	2026-01-12 12:39:51.763538	\N	\N	\N	f	[CA] Leads - Modele mix
83	23	Autoworld ONE S.R.L.	Toyota	Aftersales	Piese si Accesorii	31.39	279.89206	Ovidiu	\N	2025-12-10 13:36:42.802199	\N	\N	\N	f	\N
84	23	Autoworld ONE S.R.L.	Toyota	Sales	\N	68.61	611.76794	Monica Niculae	\N	2025-12-10 13:36:42.802199	\N	\N	\N	f	\N
86	25	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	486	Ioan Mezei	\N	2025-12-11 06:29:50.284827	\N	\N	\N	f	\N
87	26	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	50	Ovidiu Bucur	\N	2025-12-11 06:36:09.879749	\N	\N	\N	f	\N
89	28	Autoworld ONE S.R.L.	Toyota	Sales	\N	100	34.95	Monica Niculae	\N	2025-12-11 08:03:20.42063	\N	\N	\N	f	\N
331	80	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	100	4128.47	Roger Patrasc	\N	2026-01-12 12:56:01.085188	\N	\N	\N	f	\N
333	81	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	100	12938.77	Ovidiu Bucur	\N	2026-01-12 13:00:33.188898	\N	\N	\N	f	\N
99	30	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	21.76	1520.3451	Ovidiu Bucur	\N	2025-12-11 10:47:34.39114	\N	\N	\N	t	\N
100	30	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	34.74	2427.2422	Ovidiu Bucur	Autoworld PLUS S.R.L.	2025-12-11 10:47:34.39114	Sales	\N	Mazda	t	\N
101	30	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	43.5	3039.2927	Ovidiu Bucur	\N	2025-12-11 10:47:34.39114	\N	\N	\N	t	\N
345	88	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	21.72	35.983524	Ovidiu Bucur	\N	2026-01-12 13:08:59.282275	\N	\N	\N	f	GENERARE COMENZI Q4
346	88	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	78.26	129.65334	Ovidiu Bucur	\N	2026-01-12 13:08:59.283892	\N	\N	\N	f	[CA] Leads - Modele Volvo 0 km
347	88	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	0.02	0.033134	Ovidiu Bucur	\N	2026-01-12 13:08:59.287859	\N	\N	\N	f	[CA] Traffic - Interese - Modele masini
113	24	AUTOWORLD S.R.L.	CarFun.ro	Aftersales	Piese si Accesorii	100	17.52		Autoworld INTERNATIONAL S.R.L.	2025-12-15 09:22:27.312991	Aftersales	Piese si Accesorii	Volkswagen (PKW)	f	\N
394	102	Autoworld PRESTIGE S.R.L.	Volvo	Aftersales	Piese si Accesorii	100	585.36	Mihai Ploscar	\N	2026-01-13 08:33:58.907135	\N	\N	\N	f	\N
395	101	Autoworld PLUS S.R.L.	Mazda	Sales	\N	50.28	268.998	Roxana Biris	\N	2026-01-13 08:35:08.408532	\N	\N	\N	f	\N
396	101	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	49.72	266.002	Roxana Biris	\N	2026-01-13 08:35:08.410711	\N	\N	\N	t	\N
119	38	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	421.2		\N	2025-12-17 10:41:31.68115	\N	\N	\N	f	\N
120	39	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	69.59	304.49106		\N	2025-12-17 11:36:33.629017	\N	\N	\N	t	\N
121	39	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	30.41	133.05896		\N	2025-12-17 11:36:33.629017	\N	\N	\N	f	\N
397	100	Autoworld PLUS S.R.L.	Mazda	Sales	\N	42.35	317.1634	Roxana Biris	\N	2026-01-13 08:35:55.567949	\N	\N	\N	t	\N
398	100	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	57.65	431.7466	Roxana Biris	\N	2026-01-13 08:35:55.570147	\N	\N	\N	t	\N
124	41	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	4.13	11.333959		\N	2025-12-17 11:41:06.765566	\N	\N	\N	t	\N
125	41	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	95.87	263.09604		\N	2025-12-17 11:41:06.765566	\N	\N	\N	f	\N
126	36	Autoworld NEXT S.R.L.	Motion	Sales	\N	100	116		\N	2025-12-17 11:41:52.146215	\N	\N	\N	f	\N
127	33	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	4580.46	Sebastian Sabo	Autoworld PLUS S.R.L.	2025-12-17 11:42:29.01105	Sales	\N	MG Motor	f	\N
128	42	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	22.88	125.57917		\N	2025-12-17 11:45:16.167647	\N	\N	\N	f	\N
129	42	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	77.12	423.28082		\N	2025-12-17 11:45:16.167647	\N	\N	\N	t	\N
130	35	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	50	290.155		Autoworld INTERNATIONAL S.R.L.	2025-12-17 11:45:31.745883	Aftersales	Piese si Accesorii	Volkswagen (PKW)	f	\N
131	35	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	50	290.155		Autoworld PREMIUM S.R.L.	2025-12-17 11:45:31.745883	Aftersales	Piese si Accesorii	Audi	f	\N
132	32	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	45.89	Ioan Mezei	\N	2025-12-17 11:45:56.436928	\N	\N	\N	f	\N
133	31	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	100	2799.23	Roger Patrasc	\N	2025-12-17 11:47:47.392972	\N	\N	\N	f	\N
405	96	Autoworld ONE S.R.L.	Toyota	Aftersales	Reparatii Generale	33.17	162.35057	Ovidiu	\N	2026-01-13 08:42:25.747445	\N	\N	\N	t	\N
406	96	Autoworld ONE S.R.L.	Toyota	Sales	\N	66.83	327.09943	Monica Niculae	\N	2026-01-13 08:42:25.74944	\N	\N	\N	f	\N
136	27	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	605.17	Ioan Mezei	Autoworld NEXT S.R.L.	2025-12-17 11:48:09.125111	Sales	\N	Autoworld.ro	f	\N
407	99	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	941.65	Roxana Biris	\N	2026-01-13 08:45:10.218434	\N	\N	\N	f	\N
410	103	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	503	Madalina Morutan	\N	2026-01-13 08:46:48.276667	\N	\N	\N	f	\N
139	45	Autoworld ONE S.R.L.	Toyota	Aftersales	Reparatii Generale	25.27	63.296295		\N	2025-12-17 11:59:48.050294	\N	\N	\N	t	\N
140	45	Autoworld ONE S.R.L.	Toyota	Sales	\N	74.73	187.1837		\N	2025-12-17 11:59:48.050294	\N	\N	\N	f	\N
417	104	Autoworld PLUS S.R.L.	Mazda	Sales	\N	12.74	46.495903	Madalina Morutan	\N	2026-01-13 11:44:06.840472	\N	\N	\N	f	Campanie Black Friday 2025
418	104	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	42.03	153.39268	Mihai Ploscar	\N	2026-01-13 11:44:06.85328	\N	\N	\N	f	Campanie Combustibil Service
419	104	Autoworld PLUS S.R.L.	Mazda	Sales	\N	44.78	163.4291	Madalina Morutan	\N	2026-01-13 11:44:06.862878	\N	\N	\N	f	TD - LP - Carusel
420	104	Autoworld PLUS S.R.L.	Mazda	Sales	\N	0.45	1.64232	Madalina Morutan	\N	2026-01-13 11:44:06.875929	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
424	106	Autoworld PLUS S.R.L.	Mazda	Sales	\N	87.94	122.271774	Madalina Morutan	\N	2026-01-13 11:45:03.565507	\N	\N	\N	f	TD - LP - Carusel
425	106	Autoworld PLUS S.R.L.	Mazda	Sales	\N	12.06	16.768225	Madalina Morutan	\N	2026-01-13 11:45:03.572919	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
444	112	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	1.13	2.471875	Mihai Ploscar	\N	2026-01-13 12:02:12.28755	\N	\N	\N	f	Campanie Combustibil Service
445	112	Autoworld PLUS S.R.L.	Mazda	Sales	\N	79.68	174.3	Madalina Morutan	\N	2026-01-13 12:02:12.292732	\N	\N	\N	f	TD - LP - Carusel
446	112	Autoworld PLUS S.R.L.	Mazda	Sales	\N	19.18	41.95625	Madalina Morutan	\N	2026-01-13 12:02:12.297167	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
459	117	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	99.99	539.46606	Roxana Biris	\N	2026-01-13 12:17:43.746256	\N	\N	\N	f	MG Remat 2025
332	79	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	3176.79	Madalina Morutan	\N	2026-01-12 12:58:45.338832	\N	\N	\N	f	\N
353	93	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	54.08	1329.0538	Ovidiu Bucur	\N	2026-01-12 13:18:30.856521	\N	\N	\N	f	[MERGED] Original campaigns: GENERARE COMENZI Q4, [CA] Traffic - Interese - Modele masini
354	93	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	0	0	Ovidiu Bucur	\N	2026-01-12 13:18:30.858679	\N	\N	\N	f	[CA] Leads - Mazda CX80
355	93	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	18.19	447.03198	Ovidiu Bucur	\N	2026-01-12 13:18:30.862423	\N	\N	\N	f	[CA] Leads - Modele MG HS
356	93	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	27.73	681.48413	Ovidiu Bucur	\N	2026-01-12 13:18:30.865574	\N	\N	\N	f	[CA] Leads - Modele mix
359	84	Autoworld INTERNATIONAL S.R.L.	Volkswagen Comerciale (LNF)	Sales	\N	70	2828.714	Ovidiu Ciobanca	\N	2026-01-12 13:42:23.908841	\N	\N	\N	f	\N
360	84	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales		30	1212.306	Ovidiu Ciobanca	\N	2026-01-12 13:42:23.910484	\N	\N	\N	f	\N
206	56	Autoworld NEXT S.R.L.	\N	Sales	\N	54.05	236.54442	Ovidiu Bucur	\N	2025-12-18 09:08:13.539852	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Traffic - Interese - Modele masini, [CA] Leads - Modele mix
207	56	Autoworld NEXT S.R.L.	\N	Sales	\N	22.18	97.06855	Ovidiu Bucur	\N	2025-12-18 09:08:13.539852	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Mazda CX80, [CA] Traffic - Mazda CX60
208	56	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	0.49	2.144436	Ovidiu Bucur	\N	2025-12-18 09:08:13.539852	\N	\N	\N	f	GENERARE COMENZI Q4
209	56	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	12.98	56.80567	Ovidiu Bucur	\N	2025-12-18 09:08:13.539852	\N	\N	\N	f	[CA] Leads - Modele MG HS
210	56	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	10.31	45.120686	Ovidiu Bucur	\N	2025-12-18 09:08:13.539852	\N	\N	\N	f	[CA] Leads - Modele Volvo 0 km
211	55	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	53.03	116.040245	Ovidiu Bucur	\N	2025-12-18 09:09:54.27114	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Traffic - Interese - Modele masini, [CA] Leads - Modele mix
212	55	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	11.7425	25.694939	Ovidiu Bucur	\N	2025-12-18 09:09:54.27114	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Traffic - Mazda CX60, [CA] Leads - Mazda CX80
213	55	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	11.7425	25.694939	Ovidiu Bucur	\N	2025-12-18 09:09:54.27114	\N	\N	\N	f	GENERARE COMENZI Q4
214	55	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	11.7425	25.694939	Ovidiu Bucur	\N	2025-12-18 09:09:54.27114	\N	\N	\N	f	[CA] Leads - Modele MG HS
215	55	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	11.7425	25.694939	Ovidiu Bucur	\N	2025-12-18 09:09:54.27114	\N	\N	\N	f	[CA] Leads - Modele Volvo 0 km
216	54	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	50.78	444.4672	Ovidiu Bucur	\N	2025-12-18 09:11:29.865315	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Modele mix, [CA] Traffic - Interese - Modele masini
217	54	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	16.406666	143.60428	Ovidiu Bucur	\N	2025-12-18 09:11:29.865315	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Mazda CX80, [CA] Traffic - Mazda CX60
218	54	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	16.406666	143.60428	Ovidiu Bucur	\N	2025-12-18 09:11:29.865315	\N	\N	\N	f	[CA] Leads - Modele MG HS
219	54	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	16.406666	143.60428	Ovidiu Bucur	\N	2025-12-18 09:11:29.865315	\N	\N	\N	f	[CA] Leads - Modele Volvo 0 km
373	98	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	60.63	2633.2458	Ovidiu Bucur	\N	2026-01-12 14:22:59.478972	\N	\N	\N	f	[MERGED] Original campaigns: [CA] S Modele BMW, [CA] S Skoda modele, [CA] S General
374	98	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	39.37	1709.8942	Ovidiu Bucur	\N	2026-01-12 14:22:59.492236	\N	\N	\N	f	[MERGED] Original campaigns: [CA] S Mazda CX60, [CA] S Mazda CX80
411	90	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	30.72	91.16467	Roger Patrasc	\N	2026-01-13 08:47:01.143015	\N	\N	\N	t	\N
412	90	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	69.28	205.59532	Roger Patrasc	\N	2026-01-13 08:47:01.14592	\N	\N	\N	f	\N
421	105	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	1.41	3.430671	Mihai Ploscar	\N	2026-01-13 11:44:43.925142	\N	\N	\N	f	Campanie Combustibil Service
422	105	Autoworld PLUS S.R.L.	Mazda	Sales	\N	77.82	189.34384	Madalina Morutan	\N	2026-01-13 11:44:43.929023	\N	\N	\N	f	TD - LP - Carusel
423	105	Autoworld PLUS S.R.L.	Mazda	Sales	\N	20.77	50.53549	Madalina Morutan	\N	2026-01-13 11:44:43.9339	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
426	107	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	15.29	75.25127	Mihai Ploscar	\N	2026-01-13 11:45:31.177224	\N	\N	\N	f	Campanie Combustibil Service
427	107	Autoworld PLUS S.R.L.	Mazda	Sales	\N	61	300.2176	Madalina Morutan	\N	2026-01-13 11:45:31.182887	\N	\N	\N	f	TD - LP - Carusel
428	107	Autoworld PLUS S.R.L.	Mazda	Sales	\N	23.71	116.69114	Madalina Morutan	\N	2026-01-13 11:45:31.186733	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
429	108	Autoworld PLUS S.R.L.	Mazda	Sales	\N	0.02	0.049216	Madalina Morutan	\N	2026-01-13 11:53:02.432627	\N	\N	\N	f	Campanie Black Friday 2025
430	108	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	14.32	35.238655	Mihai Ploscar	\N	2026-01-13 11:53:02.444322	\N	\N	\N	f	Campanie Combustibil Service
431	108	Autoworld PLUS S.R.L.	Mazda	Sales	\N	60.07	147.82025	Madalina Morutan	\N	2026-01-13 11:53:02.448415	\N	\N	\N	f	TD - LP - Carusel
432	108	Autoworld PLUS S.R.L.	Mazda	Sales	\N	25.59	62.97187	Madalina Morutan	\N	2026-01-13 11:53:02.452432	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
433	109	Autoworld PLUS S.R.L.	Mazda	Aftersales	\N	29.83	36.70283	Mihai Ploscar	\N	2026-01-13 11:53:40.177276	\N	\N	\N	f	Campanie Combustibil Service
434	109	Autoworld PLUS S.R.L.	Mazda	Sales	\N	69.54	85.56202	Madalina Morutan	\N	2026-01-13 11:53:40.195783	\N	\N	\N	f	TD - LP - Carusel
435	109	Autoworld PLUS S.R.L.	Mazda	Sales	\N	0.63	0.775152	Madalina Morutan	\N	2026-01-13 11:53:40.204777	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
436	110	Autoworld PLUS S.R.L.	Mazda	Sales	\N	0.48	4.2	Madalina Morutan	\N	2026-01-13 12:00:04.120049	\N	\N	\N	f	Campanie Black Friday 2025
437	110	Autoworld PLUS S.R.L.	Mazda	Aftersales	\N	14.09	123.2875	Mihai Ploscar	\N	2026-01-13 12:00:04.129041	\N	\N	\N	f	Campanie Combustibil Service
438	110	Autoworld PLUS S.R.L.	Mazda	Sales	\N	67.13	587.3875	Madalina Morutan	\N	2026-01-13 12:00:04.133366	\N	\N	\N	f	TD - LP - Carusel
439	110	Autoworld PLUS S.R.L.	Mazda	Sales	\N	17.94	156.975	Madalina Morutan	\N	2026-01-13 12:00:04.137713	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
440	110	Autoworld PLUS S.R.L.	Mazda	Sales	\N	0.36	3.15	Madalina Morutan	\N	2026-01-13 12:00:04.142248	\N	\N	\N	f	[CA] VOUCHER RABLA  |
447	113	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	19.45	156.48303	Mihai Ploscar	\N	2026-01-13 12:07:23.34353	\N	\N	\N	f	Campanie Combustibil Service
448	113	Autoworld PLUS S.R.L.	Mazda	Sales	\N	69.26	557.2244	Madalina Morutan	\N	2026-01-13 12:07:23.347862	\N	\N	\N	f	TD - LP - Carusel
449	113	Autoworld PLUS S.R.L.	Mazda	Sales	\N	11.29	90.832565	Madalina Morutan	\N	2026-01-13 12:07:23.351262	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
453	115	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	9.93	53.260548	Mihai Ploscar	\N	2026-01-13 12:10:12.687352	\N	\N	\N	f	Campanie Combustibil Service
454	115	Autoworld PLUS S.R.L.	Mazda	Sales	\N	65.98	353.89032	Madalina Morutan	\N	2026-01-13 12:10:12.691569	\N	\N	\N	f	TD - LP - Carusel
455	115	Autoworld PLUS S.R.L.	Mazda	Sales	\N	24.09	129.20912	Madalina Morutan	\N	2026-01-13 12:10:12.699573	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
456	116	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	6.5	19.92185	Mihai Ploscar	\N	2026-01-13 12:10:33.932826	\N	\N	\N	f	Campanie Combustibil Service
510	139	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	2797.91	Madalina Morutan	\N	2026-01-14 09:58:20.336934	\N	\N	\N	f	\N
532	155	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	82.31	Ioan Mezei	\N	2026-01-15 10:34:57.229628	\N	\N	\N	f	\N
340	82	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	2748.87	Roxana Biris	\N	2026-01-12 13:04:12.000324	\N	\N	\N	f	\N
357	97	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	90.85	94.02975	Ovidiu Ciobanca	\N	2026-01-12 13:40:22.049644	\N	\N	\N	t	\N
358	97	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	9.15	9.47025	Ioan Parocescu	\N	2026-01-12 13:40:22.073026	\N	\N	\N	f	\N
543	165	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	82.31	Ioan Mezei	\N	2026-01-15 12:24:39.983006	\N	\N	\N	f	\N
220	53	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	36.58	1279.9342	Ovidiu Bucur	\N	2025-12-18 09:13:08.024357	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Traffic - Interese - Modele masini, [CA] Leads - Modele mix
221	53	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	15.855	554.7665	Ovidiu Bucur	\N	2025-12-18 09:13:08.024357	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Mazda CX80, [CA] Traffic - Mazda CX60
222	53	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	15.855	554.7665	Ovidiu Bucur	\N	2025-12-18 09:13:08.024357	\N	\N	\N	f	GENERARE COMENZI Q4
223	53	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	15.855	554.7665	Ovidiu Bucur	\N	2025-12-18 09:13:08.024357	\N	\N	\N	f	[CA] Leads - Modele MG HS
224	53	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	15.855	554.7665	Ovidiu Bucur	\N	2025-12-18 09:13:08.024357	\N	\N	\N	f	[CA] Leads - Modele Volvo 0 km
225	52	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	33.49	1171.8151	Ovidiu Bucur	\N	2025-12-18 09:15:34.898953	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Modele mix, [CA] Traffic - Interese - Modele masini
226	52	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	17.48	611.6252	Ovidiu Bucur	\N	2025-12-18 09:15:34.898953	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Mazda CX80, [CA] Traffic - Mazda CX60
227	52	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	11.51	402.7349	Ovidiu Bucur	\N	2025-12-18 09:15:34.898953	\N	\N	\N	f	GENERARE COMENZI Q4
228	52	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	11.48	401.6852	Ovidiu Bucur	\N	2025-12-18 09:15:34.898953	\N	\N	\N	f	[CA] Leads - Modele MG HS
229	52	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	26.04	911.1396	Ovidiu Bucur	\N	2025-12-18 09:15:34.898953	\N	\N	\N	f	[CA] Leads - Modele Volvo 0 km
230	50	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	42.9	1501.071	Ovidiu Bucur	\N	2025-12-18 09:18:26.836521	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Modele mix, [CA] Traffic - Interese - Modele masini
231	50	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	14.275	499.48224	Ovidiu Bucur	\N	2025-12-18 09:18:26.836521	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Mazda CX80, [CA] Traffic - Mazda CX60
232	50	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	14.275	499.48224	Ovidiu Bucur	\N	2025-12-18 09:18:26.836521	\N	\N	\N	f	GENERARE COMENZI Q4
233	50	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	14.275	499.48224	Ovidiu Bucur	\N	2025-12-18 09:18:26.836521	\N	\N	\N	f	[CA] Leads - Modele MG HS
234	50	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	14.275	499.48224	Ovidiu Bucur	\N	2025-12-18 09:18:26.836521	\N	\N	\N	f	[CA] Leads - Modele Volvo 0 km
235	49	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	32.8	1215.9452	Ovidiu Bucur	\N	2025-12-18 09:19:55.236167	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Modele mix, [CA] Traffic - Interese - Modele masini
236	49	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	14.93	553.4775	Ovidiu Bucur	\N	2025-12-18 09:19:55.236167	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Mazda CX80, [CA] Traffic - Mazda CX60
237	49	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	16.04	594.62683	Ovidiu Bucur	\N	2025-12-18 09:19:55.236167	\N	\N	\N	f	GENERARE COMENZI Q4
238	49	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	9.06	335.8678	Ovidiu Bucur	\N	2025-12-18 09:19:55.236167	\N	\N	\N	f	[CA] Leads - Modele MG HS
239	49	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	27.18	1007.6034	Ovidiu Bucur	\N	2025-12-18 09:19:55.236167	\N	\N	\N	f	[CA] Leads - Modele Volvo 0 km
240	59	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	114	Sebastian Sabo	\N	2025-12-18 10:20:33.542861	\N	\N	\N	f	\N
242	60	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	1323.22	Ovidiu Bucur	\N	2025-12-18 10:27:47.113806	\N	\N	\N	f	\N
243	61	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	79.05	Ioan Mezei	\N	2025-12-18 11:27:55.752806	\N	\N	\N	f	\N
403	95	Autoworld ONE S.R.L.	Toyota	Aftersales	Reparatii Generale	31.44	206.718	Ovidiu	\N	2026-01-13 08:41:05.776638	\N	\N	\N	t	\N
404	95	Autoworld ONE S.R.L.	Toyota	Sales	\N	68.56	450.782	Monica Niculae	\N	2026-01-13 08:41:05.778759	\N	\N	\N	t	\N
413	89	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	66.23	98.27207	Roger Patrasc	\N	2026-01-13 08:47:56.638015	\N	\N	\N	t	\N
414	89	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	33.77	50.107925	Roger Patrasc	\N	2026-01-13 08:47:56.639962	\N	\N	\N	f	\N
441	111	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	9.21	40.29375	Mihai Ploscar	\N	2026-01-13 12:01:30.858709	\N	\N	\N	f	Campanie Combustibil Service
442	111	Autoworld PLUS S.R.L.	Mazda	Sales	\N	70.15	306.90625	Madalina Morutan	\N	2026-01-13 12:01:30.863549	\N	\N	\N	f	TD - LP - Carusel
254	64	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	100	7035.51	Roger Patrasc	\N	2025-12-19 08:49:15.297194	\N	\N	\N	f	\N
255	62	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	90	Ioan Mezei	\N	2025-12-19 08:52:25.075173	\N	\N	\N	f	Max plan - 5x Dec 1, 2025 – Jan 1, 2026
256	63	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	108.17	Ioan Mezei	\N	2025-12-19 08:52:37.299922	\N	\N	\N	f	[MERGED] Original campaigns: Max plan - 20x Dec 8, 2025 – Jan 8, 2026, Unused time on Max plan - 5x after 08 Dec 2025 Dec 8, 2025 – Jan 1, 2026
443	111	Autoworld PLUS S.R.L.	Mazda	Sales	\N	20.64	90.3	Madalina Morutan	\N	2026-01-13 12:01:30.867378	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
259	40	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	25.03	219.03754		\N	2025-12-19 09:37:49.167455	\N	\N	\N	t	\N
260	40	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	74.97	656.0625		\N	2025-12-19 09:37:49.169121	\N	\N	\N	f	\N
261	43	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	23.49	257.85443		\N	2025-12-19 09:39:36.971069	\N	\N	\N	t	\N
262	43	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	76.51	839.8656		\N	2025-12-19 09:39:36.972868	\N	\N	\N	f	\N
263	44	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	12.8	35.13472		\N	2025-12-19 09:41:14.740664	\N	\N	\N	t	\N
264	44	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	87.2	239.35529		\N	2025-12-19 09:41:14.742244	\N	\N	\N	f	\N
265	65	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	100	1400	Roger Patrasc	\N	2025-12-19 11:10:37.830194	\N	\N	\N	f	\N
267	67	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	100	723.25	Ovidiu Ciobanca	\N	2025-12-19 12:42:16.922755	\N	\N	\N	f	\N
268	68	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	100	98.41	Ioan Parocescu	\N	2025-12-19 12:54:20.337288	\N	\N	\N	f	\N
269	69	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	100	Ioan Mezei	\N	2025-12-23 08:25:50.819814	\N	\N	\N	f	\N
273	73	Autoworld NEXT S.R.L.	Motion	Sales	\N	100	400.26	Ovidiu Bucur	\N	2026-01-09 13:38:27.492089	\N	\N	\N	f	\N
274	74	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	270	Sebastian Sabo	\N	2026-01-09 14:02:28.013859	\N	\N	\N	f	\N
279	77	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	93.5	Ioan Mezei	\N	2026-01-12 08:07:47.836559	\N	\N	\N	f	\N
280	78	Autoworld ONE S.R.L.	Toyota	Sales	\N	100	322.95	Monica Niculae	\N	2026-01-12 08:12:48.320853	\N	\N	\N	f	Subscriptie anuala shopify Toyotapromo.ro 
511	140	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	2184.02	Ioan Mezei	\N	2026-01-14 10:47:36.984352	\N	\N	\N	f	\N
514	76	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	93.47276	1120	Ovidiu Ciobanca	\N	2026-01-14 13:04:21.824234	\N	\N	\N	f	Stoc VW
515	76	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	6.5272365	78.21	Ioan Parocescu	\N	2026-01-14 13:04:21.826852	\N	\N	\N	f	VW Brand | S
516	143	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	82.3	Ioan Mezei	\N	2026-01-14 13:04:35.232431	\N	\N	\N	f	\N
519	146	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	100	377.54	Ovidiu Ciobanca	\N	2026-01-14 14:25:29.88083	\N	\N	\N	f	[MERGED] Original campaigns: ID. Family - Q3, ReMKT T-Cross stoc, T-Cross stoc (form), TD VW - general / LinkClick, TD VW General / FB leads, Test - T-Cross stoc (form)
521	148	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	100	103.32	Ovidiu Ciobanca	\N	2026-01-14 14:27:23.223379	\N	\N	\N	f	[MERGED] Original campaigns: ID. Family - Q3, ReMKT T-Cross stoc, T-Cross stoc (form), TD VW - general / LinkClick, TD VW General / FB leads, Test - T-Cross stoc (form)
524	151	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	95	1131.6875	Ovidiu Ciobanca	\N	2026-01-15 07:10:07.069201	\N	\N	\N	t	\N
525	151	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	5	59.5625	Ioan Parocescu	\N	2026-01-15 07:10:07.075206	\N	\N	\N	f	\N
527	153	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	25.5	600.7111	Madalina Morutan	\N	2026-01-15 08:34:31.103187	\N	\N	\N	f	Experience week 8-12 Decembrie - Leads
528	153	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	50.12	1180.6919	Madalina Morutan	\N	2026-01-15 08:34:31.114558	\N	\N	\N	f	[CA] Traffic - XC90
299	83	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	100	3874.07	Ovidiu Ciobanca	\N	2026-01-12 12:27:13.382756	\N	\N	\N	f	\N
300	72	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	4078.8	Sebastian Sabo	\N	2026-01-12 12:28:44.024782	\N	\N	\N	f	\N
301	71	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	4770.09	Sebastian Sabo	\N	2026-01-12 12:29:13.961646	\N	\N	\N	f	\N
302	70	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	4772.16	Sebastian Sabo	\N	2026-01-12 12:29:25.782	\N	\N	\N	f	\N
303	66	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	700	Sebastian Sabo	\N	2026-01-12 12:29:57.114018	\N	\N	\N	f	\N
529	153	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	12.26	288.8125	Madalina Morutan	\N	2026-01-15 08:34:31.118354	\N	\N	\N	f	[CA] Traffic | EX30
348	91	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	17.05	781.5055	Ovidiu Bucur	\N	2026-01-12 13:10:36.332949	\N	\N	\N	f	[MERGED] Original campaigns: [CA] Leads - Mazda CX80, [CA] Traffic - Mazda CX60
349	91	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	29.14	1335.664	Ovidiu Bucur	\N	2026-01-12 13:10:36.338105	\N	\N	\N	f	[MERGED] Original campaigns: GENERARE COMENZI Q4, [CA] Traffic - Interese - Modele masini
350	91	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	9.09	416.65015	Ovidiu Bucur	\N	2026-01-12 13:10:36.339902	\N	\N	\N	f	[CA] Leads - Modele MG HS
351	91	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	23.42	1073.4814	Ovidiu Bucur	\N	2026-01-12 13:10:36.344588	\N	\N	\N	f	[CA] Leads - Modele Volvo 0 km
352	91	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	21.3	976.30896	Ovidiu Bucur	\N	2026-01-12 13:10:36.348464	\N	\N	\N	f	[CA] Leads - Modele mix
530	153	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	12.13	285.75006	Madalina Morutan	\N	2026-01-15 08:34:31.12226	\N	\N	\N	f	[CA] WB Leads | EX30
291	87	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	4579.83	Sebastian Sabo	\N	2026-01-12 12:01:09.623164	\N	\N	\N	f	\N
287	85	Autoworld PREMIUM S.R.L.	Audi	Aftersales	Piese si Accesorii	76.24	74.99729	Calin Duca	\N	2026-01-12 10:24:41.400164	\N	\N	\N	f	\N
288	85	Autoworld PREMIUM S.R.L.	Audi	Aftersales	Reparatii Generale	23.76	23.372713	Calin Duca	\N	2026-01-12 10:24:41.409326	\N	\N	\N	t	\N
533	156	AUTOWORLD S.R.L.	CarFun.ro	Aftersales	Piese si Accesorii	100	4.36	Alina Amironoaei	\N	2026-01-15 11:05:09.348518	\N	\N	\N	f	\N
535	158	AUTOWORLD S.R.L.	CarFun.ro	Aftersales	Piese si Accesorii	100	297	Alina Amironoaei	\N	2026-01-15 11:18:05.009492	\N	\N	\N	f	Sales Carfun Q2
536	159	AUTOWORLD S.R.L.	CarFun.ro	Aftersales	Piese si Accesorii	100	317	Alina Amironoaei	\N	2026-01-15 11:18:29.351378	\N	\N	\N	f	[MERGED] Original campaigns: Sales Carfun Q2, Postare: „Ghici ce avem noi aici?”
537	160	AUTOWORLD S.R.L.	CarFun.ro	Aftersales	Piese si Accesorii	100	170.33	Alina Amironoaei	\N	2026-01-15 11:18:44.651782	\N	\N	\N	f	Sales Carfun Q2
538	161	AUTOWORLD S.R.L.	CarFun.ro	Aftersales	Piese si Accesorii	100	454.59	Alina Amironoaei	\N	2026-01-15 11:19:00.682149	\N	\N	\N	f	Sales Carfun Q2
408	94	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	7.72	7.159528	Roger Patrasc	\N	2026-01-13 08:46:08.643886	\N	\N	\N	t	\N
409	94	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	92.28	85.580475	Roger Patrasc	\N	2026-01-13 08:46:08.646619	\N	\N	\N	f	\N
415	86	Autoworld ONE S.R.L.	Toyota	Sales	\N	50	1252.455	Monica Niculae	\N	2026-01-13 08:49:23.744654	\N	\N	\N	t	\N
416	86	Autoworld ONE S.R.L.	Toyota	Aftersales	Piese si Accesorii	50	1252.455	Ovidiu	\N	2026-01-13 08:49:23.746164	\N	\N	\N	t	\N
450	114	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	13.71	110.3038	Mihai Ploscar	\N	2026-01-13 12:09:47.827509	\N	\N	\N	f	Campanie Combustibil Service
451	114	Autoworld PLUS S.R.L.	Mazda	Sales	\N	69.21	556.82904	Madalina Morutan	\N	2026-01-13 12:09:47.832815	\N	\N	\N	f	TD - LP - Carusel
452	114	Autoworld PLUS S.R.L.	Mazda	Sales	\N	17.08	137.41714	Madalina Morutan	\N	2026-01-13 12:09:47.840722	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
457	116	Autoworld PLUS S.R.L.	Mazda	Sales	\N	72.71	222.84888	Madalina Morutan	\N	2026-01-13 12:10:33.937507	\N	\N	\N	f	TD - LP - Carusel
458	116	Autoworld PLUS S.R.L.	Mazda	Sales	\N	20.79	63.719273	Madalina Morutan	\N	2026-01-13 12:10:33.943214	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
460	117	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	0.01	0.053952	Roxana Biris	\N	2026-01-13 12:17:43.75044	\N	\N	\N	f	Post: 
461	118	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	3179.11	Roxana Biris	\N	2026-01-13 12:20:49.981496	\N	\N	\N	f	[CA] S Brand Protect
462	119	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	-7.46	Madalina Morutan	\N	2026-01-13 12:24:44.376765	\N	\N	\N	f	\N
464	120	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	2446.9	Madalina Morutan	\N	2026-01-13 12:25:55.299777	\N	\N	\N	f	\N
465	75	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	270	Roxana Biris	\N	2026-01-13 12:26:05.781785	\N	\N	\N	f	\N
466	121	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	0.78	40.002144	Madalina Morutan	\N	2026-01-13 12:28:44.845952	\N	\N	\N	f	Eveniment: Dealer Open Doors - Autoworld Volvo
467	121	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	0	0	Madalina Morutan	\N	2026-01-13 12:28:44.849649	\N	\N	\N	f	Event: Dealer Open Doors - Autoworld Volvo
468	121	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	8.93	457.97327	Madalina Morutan	\N	2026-01-13 12:28:44.853537	\N	\N	\N	f	[CA] Traffic - Campanie stoc - Octombrie
469	121	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	56.42	2893.4885	Madalina Morutan	\N	2026-01-13 12:28:44.857896	\N	\N	\N	f	[CA] Traffic - XC90
470	121	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	16.86	864.66174	Madalina Morutan	\N	2026-01-13 12:28:44.86388	\N	\N	\N	f	[CA] Traffic | EX30
471	121	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	17.01	872.35443	Madalina Morutan	\N	2026-01-13 12:28:44.867577	\N	\N	\N	f	[CA] WB Leads | EX30
472	122	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	13.99	899.9655	Madalina Morutan	\N	2026-01-13 12:29:04.652203	\N	\N	\N	f	DOD 22.11.2025
473	122	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	11.79	758.4413	Madalina Morutan	\N	2026-01-13 12:29:04.657062	\N	\N	\N	f	Experience week 8-12 Decembrie - Leads
474	122	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	46.44	2987.448	Madalina Morutan	\N	2026-01-13 12:29:04.660851	\N	\N	\N	f	[CA] Traffic - XC90
475	122	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	13.89	893.5326	Madalina Morutan	\N	2026-01-13 12:29:04.666486	\N	\N	\N	f	[CA] Traffic | EX30
476	122	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	13.88	892.8893	Madalina Morutan	\N	2026-01-13 12:29:04.670094	\N	\N	\N	f	[CA] WB Leads | EX30
477	123	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	74.03	792.5652	Ioan Parocescu	\N	2026-01-13 12:34:36.850456	\N	\N	\N	t	\N
478	123	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	25.97	278.03482	Ovidiu Ciobanca	\N	2026-01-13 12:34:36.855487	\N	\N	\N	f	\N
512	141	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	179.91	Ioan Mezei	\N	2026-01-14 12:48:05.941143	\N	\N	\N	f	\N
480	37	AUTOWORLD S.R.L.	Autoworld Holding	Conducere		100	3175.07	Ioan Mezei	\N	2026-01-13 14:47:42.869492	\N	\N	\N	f	\N
481	124	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	245.76	Daniel Ivascu	\N	2026-01-13 14:58:29.244918	\N	\N	\N	f	\N
482	125	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	6.41	Daniel Ivascu	\N	2026-01-13 15:07:50.657181	\N	\N	\N	f	\N
483	126	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	80	Daniel Ivascu	\N	2026-01-13 15:08:29.990173	\N	\N	\N	f	\N
484	127	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	80	Daniel Ivascu	\N	2026-01-13 15:08:57.743592	\N	\N	\N	f	\N
485	128	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	48	Daniel Ivascu	\N	2026-01-13 15:09:31.834875	\N	\N	\N	f	\N
486	129	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	60	Daniel Ivascu	\N	2026-01-13 15:10:05.486124	\N	\N	\N	f	\N
487	130	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	48	Daniel Ivascu	\N	2026-01-13 15:10:32.978605	\N	\N	\N	f	\N
488	131	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	40	Daniel Ivascu	\N	2026-01-13 15:11:01.050683	\N	\N	\N	f	\N
489	132	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	22	Daniel Ivascu	\N	2026-01-13 15:11:31.474761	\N	\N	\N	f	\N
490	133	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	40	Daniel Ivascu	\N	2026-01-13 15:12:10.768849	\N	\N	\N	f	\N
491	134	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	22	Daniel Ivascu	\N	2026-01-13 15:12:50.746444	\N	\N	\N	f	\N
492	135	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	100	3478.07	Ovidiu Ciobanca	\N	2026-01-14 06:38:21.901808	\N	\N	\N	f	\N
517	144	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	1247.72	Sebastian Sabo	\N	2026-01-14 13:25:11.667498	\N	\N	\N	f	\N
520	147	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	100	117.98	Ovidiu Ciobanca	\N	2026-01-14 14:25:57.141765	\N	\N	\N	f	[MERGED] Original campaigns: ID. Family - Q3, ReMKT T-Cross stoc, T-Cross stoc (form), TD VW - general / LinkClick, TD VW General / FB leads, Test - T-Cross stoc (form)
522	149	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	891.1	Madalina Morutan	\N	2026-01-14 14:27:57.983583	\N	\N	\N	f	\N
523	150	Autoworld NEXT S.R.L.	Motion	Sales	\N	100	841.06	Ovidiu Bucur	\N	2026-01-14 14:35:27.744406	\N	\N	\N	f	\N
497	47	Autoworld ONE S.R.L.	Toyota	Aftersales		26.32	173.054	Ovidiu	\N	2026-01-14 08:24:41.660724	\N	\N	\N	t	\N
498	47	Autoworld ONE S.R.L.	Toyota	Sales		73.68	484.446	Monica Niculae	\N	2026-01-14 08:24:41.66272	\N	\N	\N	f	\N
499	46	Autoworld ONE S.R.L.	Toyota	Aftersales	Reparatii Generale	29.09	127.5102		\N	2026-01-14 08:26:36.905591	\N	\N	\N	t	\N
500	46	Autoworld ONE S.R.L.	Toyota	Sales	\N	70.91	310.8198		\N	2026-01-14 08:26:36.907954	\N	\N	\N	f	\N
526	152	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	100	6077.69	Roger Patrasc	\N	2026-01-15 07:54:09.05022	\N	\N	\N	f	\N
531	154	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	134.22	Sebastian Sabo	\N	2026-01-15 10:21:25.696205	\N	\N	\N	f	\N
534	157	AUTOWORLD S.R.L.	CarFun.ro	Aftersales	Piese si Accesorii	100	17.29	Alina Amironoaei	\N	2026-01-15 11:08:23.405882	\N	\N	\N	f	\N
539	162	AUTOWORLD S.R.L.	Autoworld Holding	Contabilitate	\N	50	28.57	Claudia Bruslea	\N	2026-01-15 11:35:57.473106	\N	\N	\N	f	\N
505	136	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	1.65	6.022005		\N	2026-01-14 09:40:51.831196	\N	\N	\N	f	Campanie Combustibil Service
506	136	Autoworld PLUS S.R.L.	Mazda	Sales	\N	81.39	297.04907	Madalina Morutan	\N	2026-01-14 09:40:51.834267	\N	\N	\N	f	TD - LP - Carusel
507	136	Autoworld PLUS S.R.L.	Mazda	Sales	\N	14.08	51.387775	Madalina Morutan	\N	2026-01-14 09:40:51.836913	\N	\N	\N	f	[CA] Lead | RMKT | CBO | DB | 1x3 | TD
508	136	Autoworld PLUS S.R.L.	Mazda	Sales	\N	2.89	10.547633	Madalina Morutan	\N	2026-01-14 09:40:51.83875	\N	\N	\N	f	[CA] VOUCHER RABLA  |
540	162	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	50	28.57	Sebastian Sabo	\N	2026-01-15 11:35:57.487721	\N	\N	\N	f	\N
541	163	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	192.44	Ioan Mezei	\N	2026-01-15 11:53:26.736116	\N	\N	\N	f	\N
542	164	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	192.44	Ioan Mezei	\N	2026-01-15 11:55:02.000976	\N	\N	\N	f	\N
544	166	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	192	Ioan Mezei	\N	2026-01-15 12:28:55.660448	\N	\N	\N	f	\N
545	167	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	124	Ioan Mezei	\N	2026-01-15 15:13:35.594778	\N	\N	\N	f	\N
546	168	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	124	Ioan Mezei	\N	2026-01-15 15:14:30.214125	\N	\N	\N	f	\N
547	169	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	90	Ioan Mezei	\N	2026-01-15 15:28:31.955071	\N	\N	\N	f	\N
548	170	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	108.17	Ioan Mezei	\N	2026-01-15 15:28:59.065323	\N	\N	\N	f	\N
549	171	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	180	Ioan Mezei	\N	2026-01-15 15:29:29.018018	\N	\N	\N	f	\N
550	172	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	5.67	Ioan Mezei	\N	2026-01-15 15:31:27.946244	\N	\N	\N	f	\N
551	173	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	100	30	Ioan Mezei	\N	2026-01-15 15:36:03.22801	\N	\N	\N	f	\N
552	174	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	100	1	Roger Patrasc	\N	2026-01-16 08:15:26.99971	\N	\N	\N	t	\N
553	175	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	100	1049.58	Sebastian Sabo	\N	2026-01-16 14:28:12.441069	\N	\N	\N	f	\N
554	176	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	476.71	Daniel Ivascu	\N	2026-01-19 12:46:38.048779	\N	\N	\N	f	\N
555	177	Autoworld PREMIUM S.R.L.	Audi	Aftersales	Piese si Accesorii	100	290.1	Calin Duca	\N	2026-01-19 13:28:16.271163	\N	\N	\N	f	\N
556	178	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	100	386.79	Ioan Parocescu	\N	2026-01-19 13:29:13.250136	\N	\N	\N	f	\N
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.companies (id, company, brands, vat, created_at) FROM stdin;
9	Autoworld PLUS S.R.L.	Mazda & MG	RO 50022994	2025-12-09 11:59:03.373295
10	Autoworld INTERNATIONAL S.R.L.	Volkswagen	RO 50186890	2025-12-09 11:59:03.373295
11	Autoworld PREMIUM S.R.L.	Audi & Audi Approved Plus	RO 50188939	2025-12-09 11:59:03.373295
12	Autoworld PRESTIGE S.R.L.	Volvo	RO 50186920	2025-12-09 11:59:03.373295
13	Autoworld NEXT S.R.L.	DasWeltAuto	RO 50186814	2025-12-09 11:59:03.373295
14	Autoworld INSURANCE S.R.L.	Dep Asigurari - partial	RO 48988808	2025-12-09 11:59:03.373295
15	Autoworld ONE S.R.L.	Toyota	RO 15128629	2025-12-09 11:59:03.373295
16	AUTOWORLD S.R.L.	Admin Conta Mkt PLR	RO 225615	2025-12-09 11:59:03.373295
\.


--
-- Data for Name: connector_sync_log; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.connector_sync_log (id, connector_id, sync_type, status, invoices_found, invoices_imported, error_message, details, created_at) FROM stdin;
\.


--
-- Data for Name: connectors; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.connectors (id, connector_type, name, status, config, credentials, last_sync, last_error, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: department_structure; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.department_structure (id, company, brand, department, subdepartment, manager, marketing, created_at, responsable_id, manager_ids, marketing_ids, cc_email) FROM stdin;
53	TEST	\N	Test_department	\N	\N	\N	2025-12-10 12:52:31.770512	\N	{1,2}	{2}	\N
54	Autoworld PLUS S.R.L.	Mazda	Aftersales	Reparatii Generale	\N	\N	2025-12-10 13:28:19.191809	\N	{25}	{19}	\N
55	Autoworld PLUS S.R.L.	Mazda	Aftersales	Piese si Accesorii	\N	\N	2025-12-10 13:28:49.405806	\N	{25}	{19}	\N
46	Autoworld ONE S.R.L.	Toyota	Aftersales	Piese si Accesorii	Ovidiu	Sebastian Sabo	2025-12-09 11:59:03.373295	\N	{29}	{5}	\N
47	Autoworld ONE S.R.L.	Toyota	Aftersales	Reparatii Generale	Ovidiu	Sebastian Sabo	2025-12-09 11:59:03.373295	\N	{29}	{5}	\N
38	Autoworld PREMIUM S.R.L.	Audi	Aftersales	Piese si Accesorii	Calin Duca	George Pop	2025-12-09 11:59:03.373295	\N	{23}	{18}	\N
31	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	Ioan Parocescu	Raluca Asztalos	2025-12-09 11:59:03.373295	\N	{24}	{20}	\N
32	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Reparatii Generale	Ioan Parocescu	Raluca Asztalos	2025-12-09 11:59:03.373295	\N	{24}	{20}	\N
30	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Sales	\N	Ovidiu Ciobanca	Raluca Asztalos	2025-12-09 11:59:03.373295	\N	{12}	{20}	\N
34	Autoworld INTERNATIONAL S.R.L.	Volkswagen Comerciale (LNF)	Aftersales	Piese si Accesorii	Ioan Parocescu	Raluca Asztalos	2025-12-09 11:59:03.373295	\N	{24}	{20}	\N
35	Autoworld INTERNATIONAL S.R.L.	Volkswagen Comerciale (LNF)	Aftersales	Reparatii Generale	Ioan Parocescu	Raluca Asztalos	2025-12-09 11:59:03.373295	\N	{24}	{20}	\N
33	Autoworld INTERNATIONAL S.R.L.	Volkswagen Comerciale (LNF)	Sales	\N	Ovidiu Ciobanca	Raluca Asztalos	2025-12-09 11:59:03.373295	\N	{12}	{20}	\N
39	Autoworld PREMIUM S.R.L.	Audi	Aftersales	Reparatii Generale	Calin Duca	George Pop	2025-12-09 11:59:03.373295	\N	{23}	{18}	\N
44	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	Ovidiu Bucur	Sebastian Sabo	2025-12-09 11:59:03.373295	\N	{26}	{18}	\N
43	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	Ovidiu Bucur	Raluca Asztalos	2025-12-09 11:59:03.373295	\N	{17}	{20}	\N
45	Autoworld ONE S.R.L.	Toyota	Sales	\N	Monica Niculae	Sebastian Sabo	2025-12-09 11:59:03.373295	\N	{16}	{5}	\N
36	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	Roger Patrasc	George Pop	2025-12-09 11:59:03.373295	\N	{11}	{18}	\N
27	Autoworld PLUS S.R.L.	Mazda	Sales	\N	Roxana Biris	Amanda Gadalean	2025-12-09 11:59:03.373295	\N	{14}	{19}	\N
37	Autoworld PREMIUM S.R.L.	AAP	Sales	\N	Roger Patrasc	George Pop	2025-12-09 11:59:03.373295	\N	{11}	{18}	\N
40	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	Madalina Morutan	Amanda Gadalean	2025-12-09 11:59:03.373295	\N	{14}	{19}	\N
56	AUTOWORLD S.R.L.	CarFun.ro	Aftersales	Piese si Accesorii	\N	\N	2025-12-10 13:42:29.342893	\N	{22}	{22}	\N
49	AUTOWORLD S.R.L.	Autoworld Holding	Administrativ	\N	Istvan Papp	Anyone	2025-12-09 11:59:03.373295	\N	{3}	{27}	\N
48	AUTOWORLD S.R.L.	Autoworld Holding	Conducere	\N	Ioan Mezei	Anyone	2025-12-09 11:59:03.373295	\N	{7}	{27}	\N
52	AUTOWORLD S.R.L.	Autoworld Holding	Contabilitate	\N	Claudia Bruslea	Anyone	2025-12-09 11:59:03.373295	\N	{4}	{27}	\N
50	AUTOWORLD S.R.L.	Autoworld Holding	HR	\N	Diana Deac	Anyone	2025-12-09 11:59:03.373295	\N	{6}	{27}	\N
51	AUTOWORLD S.R.L.	Autoworld Holding	Marketing	\N	Sebastian Sabo	Anyone	2025-12-09 11:59:03.373295	\N	{5}	{27}	\N
57	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	\N	\N	2025-12-11 07:25:10.02234	\N	{13}	{19}	\N
58	Autoworld PLUS S.R.L.	MG Motor	Aftersales	Reparatii Generale	\N	\N	2025-12-11 07:26:05.895869	\N	{25}	{19}	\N
59	Autoworld PLUS S.R.L.	MG Motor	Aftersales	Reparatii Generale	\N	\N	2025-12-11 07:27:37.911838	\N	{25}	{19}	\N
60	Autoworld NEXT S.R.L.	Motion	Sales	\N	\N	\N	2025-12-15 12:35:16.334076	\N	{17}	{20}	\N
41	Autoworld PRESTIGE S.R.L.	Volvo	Aftersales	Piese si Accesorii	Mihai Ploscar	Amanda Gadalean	2025-12-09 11:59:03.373295	\N	{30}	{19}	\N
42	Autoworld PRESTIGE S.R.L.	Volvo	Aftersales	Reparatii Generale	Mihai Ploscar	Amanda Gadalean	2025-12-09 11:59:03.373295	\N	{30}	{19}	\N
\.


--
-- Data for Name: invoice_templates; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.invoice_templates (id, name, template_type, supplier, supplier_vat, customer_vat, currency, description, invoice_number_regex, invoice_date_regex, invoice_value_regex, date_format, supplier_regex, supplier_vat_regex, customer_vat_regex, currency_regex, sample_invoice_path, created_at, updated_at) FROM stdin;
7	Meta Ads Template	fixed	Meta Platforms Ireland Limited	9692928	\N	RON	Template for Meta advertising invoices	Factura\\s+nr\\.\\s*(FBADS-\\d+-\\d+)	Data\\s+facturii/pl[aă]ţii\\s+(\\d{1,2}\\s+\\w{3}\\.?\\s*\\d{4})	Efectuat[aă]?\\s*(\\d+,\\d+)\\s*RON	%d %b. %Y	\N	\N	\N	\N	\N	2025-12-10 13:32:45.616642	2025-12-10 13:32:45.616642
8	Meraki Solutions SRL Template	fixed	MERAKI SOLUTIONS SRL	RO35318954	\N	RON	Invoice template for Meraki Solutions SRL maintenance services	Seria\\s+([A-Z]+)\\s+nr\\.?\\s*(\\d+)	Data\\s+\\(zi/luna/an\\):\\s*(\\d{2}/\\d{2}/\\d{4})	Total\\s+plata\\s+(\\d+\\.\\d{2})	%d/%m/%Y	\N	\N	\N	\N	\N	2025-12-10 14:29:12.261781	2025-12-10 14:29:12.954566
9	Zalau Value Centre Template	fixed	Zalau Value Centre SRL	RO38486464	\N	RON	Chirie spațiu expunere Zalau Center	FACTURA\\s+Seria\\s+([A-Z]+)\\s+Nr\\.?\\s*(\\d+)	Data:\\s*(\\d{2}/\\d{2}/\\d{4})	TOTAL\\s+DE\\s+PLATĂ\\s+-Lei-\\s*([\\d.,]+)	%d/%m/%Y	\N	\N	\N	\N	\N	2025-12-11 12:25:54.948255	2025-12-11 12:25:54.948255
10	SMSLink Invoice Template	fixed	ASTINVEST COM SRL	RO9250710	\N	RON	Template for SMS service invoices from SMSLink platform	Seria\\s+SMS,\\s+Nr\\.?\\s*(\\d+)	din\\s+(\\d{2}-\\d{2}-\\d{4})	Total\\s+factura\\s+\\(lei\\)\\s+([\\d.,]+)	%d-%m-%Y	\N	\N	\N	\N	\N	2025-12-15 09:50:37.10025	2025-12-15 09:50:37.10025
11	NEPI Investment Management SRL Invoice Template	fixed	NEPI Investment Management SRL	RO22342136	RO225615	RON	Template for invoices from NEPI Investment Management SRL for media promotion services	Seria:\\s+RNEP\\s+nr:\\s*(\\d+)	Data:\\s*(\\d{2}\\.\\d{2}\\.\\d{4})	Total\\s+de\\s+plata\\s+\\(-Lei-\\s*\\)\\s+([\\d.,]+)	%d.%m.%Y	\N	\N	\N	\N	\N	2026-01-08 07:30:54.86286	2026-01-08 07:30:54.86286
13	PK TOPAZ Invoice Template	fixed	PK TOPAZ S.R.L.	RO39426673	RO225615	RON	Expunere auto Carolina Mall - Alba	FACTURA\\s+Seria\\s+([A-Z]+)\\s+Nr\\.?\\s*(\\d+)	Data:\\s*(\\d{2}/\\d{2}/\\d{4})	TOTAL\\s+DE\\s+PLATĂ\\s+-Lei-\\s*([\\d.,]+)	%d/%m/%Y	\N	\N	\N	\N	\N	2026-01-08 08:12:49.233712	2026-01-08 08:15:23.506248
14	VGS Romania Invoice Template	fixed	VGS ROMANIA SRL	RO30383145	\N	RON	Template for VGS Romania SRL invoices	Nr\\.\\s+factura\\s+(\\w+\\s*\\d+)	Data\\s+emitere\\s+(\\d{4}-\\d{2}-\\d{2})	TOTAL\\s+PLATA\\s+([\\d.,]+)	%Y-%m-%d	\N	\N	\N	\N	\N	2026-01-08 08:32:37.074225	2026-01-08 08:32:37.074225
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.invoices (id, supplier, invoice_template, invoice_number, invoice_date, invoice_value, currency, drive_link, comment, created_at, updated_at, value_ron, value_eur, exchange_rate, deleted_at, status, payment_status, vat_rate, subtract_vat, net_value) FROM stdin;
152	OLX Online Services SRL		2026/1200233589	2026-01-14	7354.01	RON	https://drive.google.com/file/d/1RGjABAjFIAyHpYiDKBu88NMe6bnwybHc/view?usp=drivesdk		2026-01-15 07:54:09.030641	2026-01-15 07:54:12.912431	7354.01	1444.88	5.0897	\N	new	not_paid	21	t	6077.69
61	OpenAI Ireland Limited		L8ASBX7X-0002	2025-12-10	79.05	EUR	https://drive.google.com/file/d/1YzcpGfalVNVUqb1ftf3D2eMfbe8jwRaQ/view?usp=drivesdk	Chat GPT	2025-12-18 11:27:55.752806	2026-01-14 09:26:57.256828	402.32	79.05	5.0894	\N	processed	paid	\N	f	\N
28	Shopify International Limited		455531737	2025-12-07	34.95	USD	https://drive.google.com/file/d/1PgjLZ6Yv8jfHYvgnUzPra2dUQqQulfeD/view?usp=drivesdk	\N	2025-12-11 08:03:20.42063	2026-01-14 07:18:43.966151	152.76	30	5.0919	\N	processed	paid	\N	f	\N
93	Meta Platforms Ireland Limited		FBADS-416-105269415	2026-01-10	2457.57	RON	https://drive.google.com/file/d/1AYAuR-jJVATfLe1UXbv5o0kN2qWNrf_G/view?usp=drivesdk		2026-01-12 12:41:24.37873	2026-01-12 13:19:10.394958	2457.57	491.51	5	\N	new	paid	\N	f	\N
26	Anthropic, PBC		KCSFWF6E-0001	2025-12-04	50	USD	https://drive.google.com/file/d/1fAbqIQNhEhexPBuvQp4x7lGJdtMz1uQr/view?usp=drivesdk	\N	2025-12-11 06:36:09.879749	2026-01-13 11:57:51.716441	218.2	42.85	5.092	\N	processed	paid	\N	f	\N
33	Zalau Value Centre SRL		PK20252361	2025-12-11	5542.36	RON	https://drive.google.com/file/d/1zGCxfyXNyvEz6Omh4A05k7DTCYTMluRo/view?usp=drivesdk	Curatenie Masina	2025-12-11 12:36:00.466083	2025-12-17 11:42:28.850642	5542.36	1088.92	5.0898	\N	processed	not_paid	21	t	4580.46
27	EFECTRO SRL		EFE-P202512166	2025-12-11	732.26	RON	https://drive.google.com/file/d/1ys-8foIZ-Re40VLDJuqoT_N5e8L4cIL7/view?usp=drivesdk		2025-12-11 08:00:40.451316	2026-01-16 10:36:19.098439	732.26	143.88	5.0894	\N	eronata	not_paid	21	t	605.17
23	Meta Platforms Ireland Limited		FBADS-416-105122906	2025-11-30	891.66	RON	https://drive.google.com/file/d/1yCZ7VcGIL3Lbl81vmnV4Hn_yibkMvNZ9/view?usp=drivesdk	\N	2025-12-10 13:36:42.802199	2026-01-14 07:18:48.877879	891.66	175.16	5.0906	\N	processed	paid	\N	f	\N
40	Meta Platforms Ireland Limited		FBADS-569-105205350	2025-12-11	875.1	RON	https://drive.google.com/file/d/1NEAV6MGEP4mRnG_eS_9b_5nqHrvD-_14/view?usp=drivesdk		2025-12-17 11:38:55.374366	2026-01-12 12:24:51.234271	875.1	171.93	5.0898	\N	processed	paid	\N	f	\N
41	Meta Platforms Ireland Limited		FBADS-569-105210364	2025-12-13	274.43	RON	https://drive.google.com/file/d/1klQuFrutTbpjnZ3P1Glqckfv4AAOmSXa/view?usp=drivesdk		2025-12-17 11:41:06.765566	2026-01-12 12:26:58.551989	274.43	53.91	5.0904	\N	processed	paid	\N	f	\N
32	SENDSMS SOLUTIONS S.R.L.		AMD 30733	2025-12-02	55.53	RON	https://drive.google.com/file/d/17SZweZJiWEQVQ72r71r9eEFycNF37wK7/view?usp=drivesdk		2025-12-11 12:28:12.21872	2026-01-14 08:07:04.365857	55.53	10.91	5.0893	\N	processed	paid	21	t	45.89
42	Meta Platforms Ireland Limited		FBADS-569-105210365	2025-12-13	548.86	RON	https://drive.google.com/file/d/1ntIRQ3KbRRHxnKFoUIFBqPRdfOelhbM_/view?usp=drivesdk		2025-12-17 11:45:16.167647	2026-01-12 12:33:04.430176	548.86	107.82	5.0904	\N	processed	paid	\N	f	\N
85	VGS ROMANIA SRL		VGSR 3459	2025-12-26	119.03	RON	https://drive.google.com/file/d/1z3y3eGAV1wrxfNGmE8K1MpDGAB3LlMOI/view?usp=drivesdk		2026-01-12 10:24:41.39141	2026-01-12 10:39:03.723629	119.03	23.39	5.089	\N	processed	not_paid	21	t	98.37
30	Google Ireland Limited		5431698595	2025-11-30	6986.88	RON	https://drive.google.com/file/d/1FIPMp8_3vEqSL1Ewc4uvn88LkUJ7cgDv/view?usp=drivesdk	\N	2025-12-11 10:47:34.39114	2026-01-13 11:58:31.211962	6986.88	1372.51	5.0906	\N	processed	paid	\N	f	\N
35	ASTINVEST COM SRL		29699	2025-12-15	702.18	RON	https://drive.google.com/file/d/1Q6vdv7eZpQZy07UgoZdmpRFqTG-0ZwGC/view?usp=drivesdk	Rog programare la plata!	2025-12-15 09:55:05.310499	2026-01-16 07:00:00.929221	702.18	137.91	5.0914	\N	processed	not_paid	21	t	580.31
49	Meta Platforms Ireland Limited		FBADS-416-105139379	2025-12-04	3707.15	RON	https://drive.google.com/file/d/1J5lHqkgziCiJWw9yNZza2DQ1inhVHtJD/view?usp=drivesdk		2025-12-18 08:13:26.889544	2026-01-13 12:11:50.702317	3707.15	728.03	5.092	\N	processed	paid	\N	f	\N
50	Meta Platforms Ireland Limited		FBADS-416-105141782	2025-12-05	3499	RON	https://drive.google.com/file/d/1MzH5ni6Y6cJWK2d-tgIzmsBvSrtjor42/view?usp=drivesdk		2025-12-18 08:16:19.97189	2026-01-13 12:14:53.486786	3499	687.17	5.0919	\N	processed	paid	\N	f	\N
52	Meta Platforms Ireland Limited		FBADS-416-105149904	2025-12-07	3499	RON	https://drive.google.com/file/d/1S-zd_0WvKgIUewUidVPR0rwyeAmbeLyE/view?usp=drivesdk		2025-12-18 08:20:09.172671	2026-01-13 12:17:50.646178	3499	687.17	5.0919	\N	processed	paid	\N	f	\N
24	Shopify International Limited		454249619	2025-12-04	17.52	EUR	https://drive.google.com/file/d/1rLEDTtczDc3Wh3hryF8ni08GsWIKZ3po/view?usp=drivesdk		2025-12-10 13:47:57.553439	2026-01-14 09:11:36.230707	89.21	17.52	5.092	\N	processed	paid	\N	f	\N
53	Meta Platforms Ireland Limited		FBADS-416-105158618	2025-12-09	3499	RON	https://drive.google.com/file/d/1dr-OLSXzGOgqlS9-tXcQwLrNbYdTcYWK/view?usp=drivesdk		2025-12-18 08:21:51.139254	2026-01-13 12:19:02.382226	3499	687.47	5.0897	\N	processed	paid	\N	f	\N
54	Meta Platforms Ireland Limited		FBADS-416-105169444	2025-12-12	875.28	RON	https://drive.google.com/file/d/1fvqrxlvxOr_g3_FFWoOhJPmjI-H12R9u/view?usp=drivesdk		2025-12-18 08:24:57.250297	2026-01-13 12:20:23.940127	875.28	171.95	5.0904	\N	processed	paid	\N	f	\N
55	Meta Platforms Ireland Limited		FBADS-416-105169441	2025-12-12	218.82	RON	https://drive.google.com/file/d/162tqswv0W5gloSPtEB6-iVuTxWDkbvdt/view?usp=drivesdk		2025-12-18 08:28:42.236469	2026-01-13 12:27:10.074567	218.82	42.99	5.0904	\N	processed	paid	\N	f	\N
56	Meta Platforms Ireland Limited		FBADS-416-105169443	2025-12-12	437.64	RON	https://drive.google.com/file/d/1W3_rFTK4D3KT_0eaJwTV_YPraHt_xyfD/view?usp=drivesdk		2025-12-18 08:48:48.375123	2026-01-13 12:28:27.299583	437.64	85.97	5.0904	\N	processed	paid	\N	f	\N
139	MERAKI SOLUTIONS SRL		CPY nr. 15683	2026-01-08	3385.47	RON	https://drive.google.com/file/d/1bzFVNqBi_D3byF6TApVJENLdjHefZxbh/view?usp=drivesdk		2026-01-14 09:58:20.321575	2026-01-14 09:58:24.441054	3385.47	664.01	5.0985	\N	new	not_paid	21	t	2797.91
38	Apify Technologies s.r.o.		202507140663	2025-07-14	421.2	USD	https://drive.google.com/file/d/1FcNlmaYX2RNBcMd4ev54rvsvwdwMz8MY/view?usp=drivesdk	SUbscriptia pentru modulul de transfer anunturi din mobile.de	2025-12-17 10:41:31.68115	2025-12-17 13:04:48.232665	1830.87	360.44	5.0795	\N	processed	paid	\N	f	\N
36	VGS ROMANIA SRL		VGSR 3449	2025-12-05	140.36	RON	https://drive.google.com/file/d/1zOJP0UmpsZru0Upj3cMp0EJKLKqnOS-Z/view?usp=drivesdk		2025-12-15 12:53:53.092466	2025-12-17 14:22:22.095951	140.36	27.57	5.0919	\N	processed	not_paid	21	t	116
25	Slack Technologies Limited		SBIE-10163068	2025-11-26	486	EUR	https://drive.google.com/file/d/11GkZq0Lszoq0QZqtXsr7_5zYBNmlOL7w/view?usp=drivesdk	\N	2025-12-11 06:29:50.284827	2026-01-16 06:43:05.691213	2473.89	486	5.0903	\N	processed	paid	\N	f	\N
39	Meta Platforms Ireland Limited		FBADS-569-105205349	2025-12-11	437.55	RON	https://drive.google.com/file/d/1Lgzj45evw4S7pYdX4SuAYvLqydpkSUvU/view?usp=drivesdk		2025-12-17 11:36:33.629017	2025-12-18 14:18:09.830056	437.55	85.97	5.0898	\N	processed	paid	\N	f	\N
43	Meta Platforms Ireland Limited		FBADS-569-105210366	2025-12-13	1097.72	RON	https://drive.google.com/file/d/1CRQyVdBers1324tXn0-lcSu1dqxI1HW5/view?usp=drivesdk		2025-12-17 11:47:50.15789	2025-12-19 09:39:59.630807	1097.72	215.65	5.0904	\N	processed	paid	\N	f	\N
60	MERAKI SOLUTIONS SRL		CPY15597	2025-12-02	1601.1	RON	https://drive.google.com/file/d/1D8rm3TIi16SKUuBEmQGabJTsK2c5w36w/view?usp=drivesdk		2025-12-18 10:26:32.069756	2025-12-23 11:56:03.955905	1601.1	314.6	5.0893	\N	processed	not_paid	21	t	1323.22
59	Globo Software Solution., JSC		20251511	2025-07-17	114	USD	https://drive.google.com/file/d/1azgEtVNubhVdg-XnDhBkuSGgXIA074sZ/view?usp=drivesdk	Customizare modul catalog Autoworld.ro	2025-12-18 10:20:33.542861	2026-01-16 06:41:09.783957	498.77	98.33	5.0724	\N	processed	paid	\N	f	\N
77	Awesome Projects SRL		FF-348515	2026-01-01	113.14	RON	https://drive.google.com/file/d/1KPK1R-20IF7sROmR_7Z7p6ASuuIlioH2/view?usp=drivesdk	Plata domeniu samsaru.ro	2026-01-12 08:06:24.127175	2026-01-12 08:07:47.697243	113.14	22.19	5.0985	\N	new	paid	21	t	93.5
72	PK TOPAZ S.R.L.		PK20260012	2026-01-05	4935.35	RON	https://drive.google.com/file/d/1K9lE1CptUwxlEnYrGnSMJG0dkZ0hYRTE/view?usp=drivesdk	Spatiu expunere Alba (Audi + Mazda)	2026-01-08 08:14:38.680245	2026-01-12 12:28:43.78013	4935.35	969.52	5.0905	\N	new	not_paid	21	t	4078.8
79	OLX Online Services SRL		2026/1200219759	2025-12-22	3843.91	RON	https://drive.google.com/file/d/1ml4XYg9iYJA0vwijraJRUDEHtGZLevfX/view?usp=drivesdk		2026-01-12 09:19:52.251903	2026-01-14 07:15:36.621013	3843.91	755.47	5.0881	\N	processed	not_paid	21	t	3176.79
63	Anthropic, PBC		RLOPHA9P 0006	2025-12-08	108.17	EUR	https://drive.google.com/file/d/12TZb0mIyHotRF_nLE0bZoyfBtryn2qeH/view?usp=drivesdk		2025-12-18 13:42:41.672061	2026-01-14 09:21:47.834343	550.57	108.17	5.0899	\N	processed	paid	\N	f	\N
69	OpenAI, LLC		2943F109-0009	2025-12-23	100	USD	https://drive.google.com/file/d/1bC-DtVtH9fPkpPcK1o81PSeYXSXVBAV6/view?usp=drivesdk	Chat GPT Credits - Conversie oferte Mobile.de	2025-12-23 08:25:50.810054	2026-01-14 09:34:12.650773	433.64	85.23	5.0881	\N	processed	paid	\N	f	\N
95	Meta Platforms Ireland Limited		FBADS-416-105191330	2025-12-18	657.5	RON	https://drive.google.com/file/d/1dcmB1Qcw_RQ9D4gL2UAtvPoggsG1hIV_/view?usp=drivesdk		2026-01-12 12:51:38.447223	2026-01-14 07:18:24.691869	657.5	129.15	5.0911	\N	processed	paid	\N	f	\N
80	OLX Online Services SRL		2026/1200225655	2026-01-03	4995.45	RON	https://drive.google.com/file/d/1aghl6PbKFvMM7KCSLymo2-i4x-WzNNLy/view?usp=drivesdk		2026-01-12 09:22:16.348449	2026-01-14 15:24:59.47616	4995.45	979.79	5.0985	\N	eronata	not_paid	21	t	4128.47
83	CRUSH DISTRIBUTION SRL		CRD-F2519988	2025-11-28	4687.63	RON	https://drive.google.com/file/d/1hgiA-8S3RxXo9Sn2NmvR5ZfpSvth9k-6/view?usp=drivesdk	Rog plata urgent!	2026-01-12 09:55:06.188992	2026-01-14 10:14:35.148499	4687.63	920.84	5.0906	\N	processed	not_paid	21	t	3874.07
86	Google Ireland Limited		5457877229	2025-12-31	2504.91	RON	https://drive.google.com/file/d/1kP_3TRG5XPFFMxsE2SvjIyk-u_x8xre7/view?usp=drivesdk		2026-01-12 11:33:39.019082	2026-01-14 07:18:26.895078	2504.91	491.3	5.0985	\N	processed	paid	\N	f	\N
78	Shopify International Limited		469842557	2026-01-07	322.95	USD	https://drive.google.com/file/d/1B2MsVpkfeT0OxDRqfxIUA8u9iop9Nh5T/view?usp=drivesdk		2026-01-12 08:12:48.295602	2026-01-14 07:26:25.013928	1402.15	275.01	5.0985	\N	processed	paid	\N	f	\N
74	LUCI DETAILING AND COSMETIC AUTO SRL		3	2026-01-05	270	RON	https://drive.google.com/file/d/1xBezs5kvQxuPVOp6aTx_tXbWJyHKjuYS/view?usp=drivesdk	Intretinere auto Carolina Mall	2026-01-09 14:02:27.972911	2026-01-09 14:02:27.972911	270	52.96	5.0985	\N	new	not_paid	\N	f	\N
68	Mailchimp c/o The Rocket Science Group, LLC		MC22270407	2025-12-16	98.41	EUR	https://drive.google.com/file/d/12feFiitBNUYTAy1xpmzwExOizZGMnSoB/view?usp=drivesdk		2025-12-19 12:54:20.323174	2026-01-14 13:07:29.909706	501.1	98.41	5.092	\N	processed	paid	\N	f	\N
64	OLX Online Services SRL		2026/1200213871	2025-12-14	8512.97	RON	https://drive.google.com/file/d/1q4Q8hlwaW5-mibMW7lMIckk-HWsu6Iju/view?usp=drivesdk		2025-12-18 13:52:49.185186	2025-12-19 08:49:15.180872	8512.97	1672.36	5.0904	\N	processed	not_paid	21	t	7035.51
76	Google Ireland Limited		5456946208	2025-12-31	1198.21	RON	https://drive.google.com/file/d/19VC6dj01JZtLYbY-bJybjxZ7Greg_hWi/view?usp=drivesdk		2026-01-09 14:33:56.906852	2026-01-14 13:08:59.938979	1198.21	235.01	5.0985	\N	processed	paid	\N	f	\N
67	Meta Platforms Ireland Limited		FBADS-528-105219425	2025-12-15	723.25	RON	https://drive.google.com/file/d/1RPsB-y7bAybVkD6_jBYyISCVr0auheZq/view?usp=drivesdk		2025-12-19 12:42:16.878694	2026-01-14 12:27:15.799154	723.25	142.05	5.0914	\N	processed	paid	\N	f	\N
65	SKYTA ECO CLEAN SRL		041	2025-12-18	1400	RON	https://drive.google.com/file/d/1dkla-r7pTDuGZp6Zt9znPxOutZkqbnzH/view?usp=drivesdk		2025-12-19 11:10:37.772378	2025-12-23 11:56:20.761465	1400	274.99	5.0911	\N	processed	not_paid	\N	f	\N
81	OLX Online Services SRL		2026/1200225660	2026-01-03	15655.91	RON	https://drive.google.com/file/d/1D_thMHMaX6GOr_Iu22CCRVf0eY05Cb1H/view?usp=drivesdk		2026-01-12 09:33:46.324867	2026-01-12 13:00:33.095012	15655.91	3070.69	5.0985	\N	new	not_paid	21	t	12938.77
62	Anthropic, PBC		RLOPHA9P 0005	2025-12-02	90	EUR	https://drive.google.com/file/d/1UXCA2NbxprRLqFphIjoqhT1IencczrAV/view?usp=drivesdk		2025-12-18 13:42:21.906734	2026-01-14 08:35:34.068188	458.04	90	5.0893	\N	processed	paid	\N	f	\N
31	Rubikdesign S.R.L.		Rt-01-22 nr. 0177	2025-12-11	3387.07	RON	https://drive.google.com/file/d/1KhYkf44WvU9-nXVHSRyiRbNX_dFe_j8l/view?usp=drivesdk		2025-12-11 11:41:23.605404	2026-01-12 12:16:33.752124	3387.07	665.46	5.0898	\N	processed	not_paid	21	t	2799.23
71	NEPI Investment Management SRL		RNEP nr: 2025003243	2025-12-23	5771.81	RON	https://drive.google.com/file/d/17-CqDhJZs3jIft-AKm9lmpmee1O-i8LN/view?usp=drivesdk	Expunere Sibiu - Volvo 	2026-01-08 07:34:18.072638	2026-01-16 07:04:36.171392	5771.81	1133.77	5.0908	\N	processed	not_paid	21	t	4770.09
98	Google Ireland Limited		5459181905	2025-12-31	4343.14	RON	https://drive.google.com/file/d/161liLkeiGwJuRoIkeDTDugIVobWjW_C3/view?usp=drivesdk		2026-01-12 14:22:59.469266	2026-01-14 12:54:49.842409	4343.14	851.85	5.0985	\N	processed	paid	\N	f	\N
97	Meta Platforms Ireland Limited		FBADS-528-105315964	2026-01-11	103.5	RON	https://drive.google.com/file/d/1JlN_KNnnhWt0CeGSuQ1S4PqyRiuibdas/view?usp=drivesdk		2026-01-12 13:40:21.981631	2026-01-14 12:17:06.68189	103.5	20.7	5	\N	processed	paid	\N	f	\N
92	Meta Platforms Ireland Limited		FBADS-416-105195236	2025-12-19	3499	RON	https://drive.google.com/file/d/1SP2M4TpSttSln1v-BaSXwNomlnInkXHh/view?usp=drivesdk		2026-01-12 12:39:51.747085	2026-01-13 14:34:34.953917	3499	687.48	5.0896	\N	processed	paid	\N	f	\N
70	NEPI Investment Management SRL		RNEP nr: 2025002880	2025-11-27	5774.31	RON	https://drive.google.com/file/d/17-CqDhJZs3jIft-AKm9lmpmee1O-i8LN/view?usp=drivesdk	Expunere Siviu - Volvo! Rog Plata urgent!	2026-01-08 07:33:11.064156	2026-01-16 07:04:30.074156	5774.31	1134.42	5.0901	\N	processed	not_paid	21	t	4772.16
88	Meta Platforms Ireland Limited		FBADS-416-105174343	2025-12-14	165.67	RON	https://drive.google.com/file/d/1toxKIjzfneWQht6QL7aDy7zD_YlRwLZC/view?usp=drivesdk		2026-01-12 12:31:36.627631	2026-01-13 12:29:39.126584	165.67	32.55	5.0904	\N	processed	paid	\N	f	\N
82	OLX Online Services SRL		2026/1200226916	2026-01-05	3326.13	RON	https://drive.google.com/file/d/1EZN2sSbmS20BPhG4puSuw67w89EqvRdr/view?usp=drivesdk		2026-01-12 09:38:49.596772	2026-01-15 12:04:03.852855	3326.13	652.37	5.0985	\N	processed	not_paid	21	t	2748.87
66	SERV COMPANY SRL		560	2025-12-19	847	RON	https://drive.google.com/file/d/1FpYtumACWpbmYQFMc0eDBLGFmy7SXPAT/view?usp=drivesdk	Servicii curatenie expunere Volvo Sibiu	2025-12-19 12:18:03.241288	2026-01-16 07:03:26.139074	847	166.42	5.0896	\N	processed	not_paid	21	t	700
87	Zalau Value Centre SRL		PK20260057	2026-01-12	5541.59	RON	https://drive.google.com/file/d/1ivhFWfvWlNfocu7QrrPsZyLpG5uJp2dH/view?usp=drivesdk		2026-01-12 12:01:09.602333	2026-01-12 12:01:16.856519	5541.59	1088.81	5.0896	\N	new	not_paid	21	t	4579.83
73	SOFTIMPERA SRL		SI10391	2025-12-26	400.26	RON	https://drive.google.com/file/d/1xBezs5kvQxuPVOp6aTx_tXbWJyHKjuYS/view?usp=drivesdk	Servicii hosting website motionrentacar.ro	2026-01-09 13:38:27.488769	2026-01-13 12:33:07.689945	400.26	78.65	5.089	\N	processed	not_paid	\N	f	\N
89	Meta Platforms Ireland Limited		FBADS-569-105264677	2025-12-26	148.38	RON	https://drive.google.com/file/d/1klvt7mBBLyRS3nSeyRf-qv0IoEGs9owD/view?usp=drivesdk		2026-01-12 12:33:43.070501	2026-01-13 15:08:20.347595	148.38	29.16	5.089	\N	processed	paid	\N	f	\N
94	Meta Platforms Ireland Limited		FBADS-569-105267260	2025-12-27	92.74	RON	https://drive.google.com/file/d/1xNgYWJylQpPNOvcg24BQStAZB425Gk7G/view?usp=drivesdk		2026-01-12 12:45:57.054329	2026-01-13 15:12:01.455893	92.74	18.22	5.089	\N	processed	paid	\N	f	\N
99	LUNA CLEANING MAGIC S.R.L.		LUNA nr. 2822	2025-12-29	1139.4	RON	https://drive.google.com/file/d/1YRh8RB3wTGPPEIpXuUM-0ikk13ptcUB-/view?usp=drivesdk		2026-01-13 07:28:45.738011	2026-01-13 08:51:59.182593	1139.4	223.76	5.092	\N	processed	not_paid	21	t	941.65
84	OLX Online Services SRL		2026120025486	2025-12-16	4889.64	RON	https://drive.google.com/file/d/1uWnjMTa-hVe7BbJRxiBopE0YPID32DsY/view?usp=drivesdk		2026-01-12 10:05:13.819279	2026-01-13 13:10:27.335539	4889.64	960.26	5.092	\N	processed	not_paid	21	t	4041.02
143	Google Cloud EMEA Limited		5461397540	2025-12-31	82.3	USD	https://drive.google.com/file/d/1Jh6GckDCWSBwteiBcTjgk06jBFKYmLdy/view?usp=drivesdk		2026-01-14 13:04:35.228233	2026-01-14 14:31:49.06499	357.32	70.08	5.0985	\N	processed	paid	\N	f	\N
140	Polus Transilvania Companie de Investitii S.A.		R045-4115012258	2025-12-02	2642.66	RON	https://drive.google.com/file/d/1AjxUY3KVe5RKHyy_JOpr2sFetLDIdZvU/view?usp=drivesdk		2026-01-14 10:47:36.938727	2026-01-16 07:06:39.953372	2642.66	519.26	5.0893	\N	processed	not_paid	21	t	2184.02
148	Meta Platforms Ireland Limited		FBADS-528-105206037	2025-12-12	103.32	RON	https://drive.google.com/file/d/1AazVin4qkGtvf7-gu1DxQgYJHmFG_qro/view?usp=drivesdk		2026-01-14 14:27:23.219099	2026-01-14 15:17:52.723612	103.32	20.3	5.0904	\N	processed	paid	\N	f	\N
147	Meta Platforms Ireland Limited		FBADS-528-105205218	2025-12-12	117.98	RON	https://drive.google.com/file/d/1WOeM7tiIYq3uziMqyMXcpAhDpFjbKPUC/view?usp=drivesdk		2026-01-14 14:25:57.137644	2026-01-14 15:19:45.754367	117.98	23.18	5.0904	\N	processed	paid	\N	f	\N
47	Meta Platforms Ireland Limited		FBADS-416-105183180	2025-12-16	657.5	RON	https://drive.google.com/file/d/1F45wBpH-dRz5KL_yzVrD2Y-BZdy2r6Wx/view?usp=drivesdk		2025-12-17 12:05:45.025498	2026-01-15 06:19:06.793102	657.5	129.12	5.092	\N	eronata	paid	\N	f	\N
153	Meta Platforms Ireland Limited		FBADS-215-105273987	2026-01-14	2355.73	RON	https://drive.google.com/file/d/1KgzN-2XOrAU2h7dYQLQubM7bjJgklz16/view?usp=drivesdk		2026-01-15 08:34:31.064204	2026-01-15 08:34:40.76374	2355.73	462.84	5.0897	\N	new	paid	\N	f	\N
155	Google Cloud EMEA Limited		5326102266	2025-07-31	82.31	USD	https://drive.google.com/file/d/1G9Mj9DPjGiNt3SOQrHSpKbaYk-5EeYii/view?usp=drivesdk		2026-01-15 10:34:57.216482	2026-01-16 07:08:18.788969	365.34	71.97	5.0764	\N	processed	paid	\N	f	\N
166	Cursor		KXNTXJYM-0002	2025-09-07	192	USD	https://drive.google.com/file/d/1wO66ePolmkiFbWw5mOhWWisncZUtQYsK/view?usp=drivesdk		2026-01-15 12:28:55.632338	2026-01-16 07:44:39.755519	834.49	164.31	5.0787	\N	processed	paid	\N	f	\N
173	X AI LLC		371-536-126-069	2025-10-15	30	USD	https://drive.google.com/file/d/1HvlovZNInc_xmA14sV68E9Hteun9Ikso/view?usp=drivesdk		2026-01-15 15:36:03.191446	2026-01-16 07:50:37.697422	131.21	25.79	5.0885	\N	processed	not_paid	\N	f	\N
161	Meta Platforms Ireland Limited		FBADS-125-105271839	2026-01-01	454.59	RON	https://drive.google.com/file/d/1szr-Azg6d1BsE0j3tuZ1YqdPAK-5-LGy/view?usp=drivesdk		2026-01-15 11:19:00.67888	2026-01-15 11:19:48.82366	\N	\N	\N	\N	incomplete	paid	\N	f	\N
160	Meta Platforms Ireland Limited		FBADS-125-105277202	2026-01-03	170.33	RON	https://drive.google.com/file/d/1937T7_jsF8HJaRFPXvjjvTOdMX0rdT7b/view?usp=drivesdk		2026-01-15 11:18:44.641998	2026-01-15 11:19:49.989328	\N	\N	\N	\N	incomplete	paid	\N	f	\N
159	Meta Platforms Ireland Limited		FBADS-125-105315570	2026-01-12	317	RON	https://drive.google.com/file/d/1NWBbifjIYzGb0Le1KqJzqmyFKcQCmU_p/view?usp=drivesdk		2026-01-15 11:18:29.347911	2026-01-15 11:19:51.006308	\N	\N	\N	\N	incomplete	paid	\N	f	\N
169	Anthropic, PBC		RLQPHA9P-0005	2025-12-02	90	EUR	https://drive.google.com/file/d/1PrMcDB8Tz96ByEX_0XpHEPtEFQUnZyHl/view?usp=drivesdk		2026-01-15 15:28:31.935342	2026-01-16 14:36:03.061946	458.04	90	5.0893	\N	processed	paid	\N	f	\N
175	Meta Platforms Ireland Limited		FBADS-167-104773906	2025-08-22	1049.58	RON	https://drive.google.com/file/d/1gYvmOtT4fvtFBONRuMP6y_dEco17AEvR/view?usp=drivesdk		2026-01-16 14:28:12.414079	2026-01-16 14:59:34.44169	1049.58	207.65	5.0545	\N	processed	paid	\N	f	\N
124	Shopify International Limited		464031740	2025-12-24	245.76	EUR	https://drive.google.com/file/d/1ZXpoSMGyOzzZKR1VqH7D1A76R1RTvlE-/view?usp=drivesdk		2026-01-13 14:58:29.201038	2026-01-13 15:31:14.065667	1250.67	245.76	5.089	\N	processed	paid	\N	f	\N
125	TikTok Information Technologies UK Limited		BDUK20253636260	2025-10-01	6.41	RON	https://drive.google.com/file/d/1VSfckafKQHR2Pj4J5UKzMKM2isrMWHSv/view?usp=drivesdk		2026-01-13 15:07:50.63117	2026-01-13 15:31:58.307441	6.41	1.26	5.082	\N	processed	paid	\N	f	\N
128	TikTok Information Technologies UK Limited		BDUK2025344182	2025-09-19	48	RON	https://drive.google.com/file/d/1gdtj9D7j-NTjResl3aUBzrNMEZcpDxCQ/view?usp=drivesdk		2026-01-13 15:09:31.831001	2026-01-13 15:32:23.172876	48	9.46	5.0719	\N	processed	paid	\N	f	\N
142	Hetzner Online GmbH		086000539734	2025-11-22	181.65	EUR	https://drive.google.com/file/d/1FxiGENMFGgIKTvXHVxVqcBMBzlJO9n-j/view?usp=drivesdk		2026-01-14 12:57:57.205988	2026-01-14 14:26:02.969812	924.44	181.65	5.0891	\N	processed	paid	\N	f	\N
106	Meta Platforms Ireland Limited		FBADS-271-105149887	2025-12-16	139.04	RON	https://drive.google.com/file/d/1Rb0QA6U3voZE08hZjOhQIHEn_OaLUCDs/view?usp=drivesdk		2026-01-13 11:45:03.555827	2026-01-14 08:35:28.65429	139.04	27.31	5.092	\N	processed	paid	\N	f	\N
105	Meta Platforms Ireland Limited		FBADS-271-105149896	2025-12-16	243.31	RON	https://drive.google.com/file/d/1BlVGHOXtHt6Ch6Q2aRooCfbWAWp7LTBC/view?usp=drivesdk		2026-01-13 11:44:43.921738	2026-01-14 08:32:57.581452	243.31	47.78	5.092	\N	processed	paid	\N	f	\N
127	TikTok Information Technologies UK Limited		BDUK2025463735	2025-09-21	80	RON	https://drive.google.com/file/d/1-DT7F_cd75iGRrFerjdgF6AOaRlPR0Pn/view?usp=drivesdk		2026-01-13 15:08:57.738995	2026-01-13 15:32:35.609553	80	15.77	5.0719	\N	processed	paid	\N	f	\N
121	Meta Platforms Ireland Limited		FBADS-215-105141145	2025-12-10	5128.48	RON	https://drive.google.com/file/d/1sGoER42WJBwiwiacRsLbm6AR8Bd7QRi6/view?usp=drivesdk		2026-01-13 12:28:44.839458	2026-01-14 06:58:50.694041	5128.48	1007.68	5.0894	\N	processed	paid	\N	f	\N
75	SC FIRSTCLEAN SRL		FCL 2731	2026-01-05	326.7	RON	https://drive.google.com/file/d/1PAbqGKKGeO9OCviwFus8hMB7E2sXcwWI/view?usp=drivesdk		2026-01-09 14:05:17.121896	2026-01-13 12:26:05.663301	326.7	64.08	5.0985	\N	new	not_paid	21	t	270
126	TikTok Information Technologies UK Limited		BDUK20253475989	2025-09-22	80	RON	https://drive.google.com/file/d/1XYMlhEQb-LkbU_8GPLlNEYuXHjrVVfTT/view?usp=drivesdk		2026-01-13 15:08:29.985181	2026-01-13 15:35:11.294707	80	15.76	5.0753	\N	processed	paid	\N	f	\N
100	VGS ROMANIA SRL		VGSR 3458	2025-12-26	906.18	RON	https://drive.google.com/file/d/1W-tZp2OztdNReBqxvj6UOPg7ikg7OHVk/view?usp=drivesdk		2026-01-13 07:38:56.362406	2026-01-13 08:51:57.740448	906.18	178.07	5.089	\N	processed	not_paid	21	t	748.91
118	Google Ireland Limited		5456072388	2025-12-31	3179.11	RON	https://drive.google.com/file/d/19rLdB7i6jW-2l4hHTpdOLHDjQWAFFL0a/view?usp=drivesdk		2026-01-13 12:20:49.978068	2026-01-14 09:25:06.720661	3179.11	623.54	5.0985	\N	processed	paid	\N	f	\N
101	VGS ROMANIA SRL		VGSR 3442	2025-12-04	647.35	RON	https://drive.google.com/file/d/1PeW-AZnaq6EhQfO0N6tdbbu-bvSjIQ4s/view?usp=drivesdk		2026-01-13 07:51:10.802683	2026-01-13 08:35:08.252445	647.35	127.13	5.092	\N	processed	not_paid	21	t	535
120	Google Ireland Limited		5457633052	2025-12-31	2446.9	RON	https://drive.google.com/file/d/14J3iu9B7nEbJkxZb6fclLdAInMVy7hte/view?usp=drivesdk		2026-01-13 12:25:55.29631	2026-01-14 07:03:04.475878	2446.9	479.93	5.0985	\N	processed	paid	\N	f	\N
116	Meta Platforms Ireland Limited		FBADS-271-105237788	2026-01-09	306.49	RON	https://drive.google.com/file/d/1Iyj_f8rbKPMyKnrnNmLs1fTYmQGV9qnV/view?usp=drivesdk		2026-01-13 12:10:33.92888	2026-01-13 12:11:40.643871	306.49	60.11	5.0985	\N	new	paid	\N	f	\N
115	Meta Platforms Ireland Limited		FBADS-271-105237812	2026-01-09	536.36	RON	https://drive.google.com/file/d/1tWWTWH0tMNWosF1DyEB_v9ScVBBDLuW9/view?usp=drivesdk		2026-01-13 12:10:12.683424	2026-01-13 12:11:41.732248	536.36	105.2	5.0985	\N	new	paid	\N	f	\N
114	Meta Platforms Ireland Limited		FBADS-271-105237838	2026-01-09	804.55	RON	https://drive.google.com/file/d/1TiUAlUIaolMHJFOjsAYyDUyX4QUVtPm6/view?usp=drivesdk		2026-01-13 12:09:47.82295	2026-01-13 12:11:42.782517	804.55	157.8	5.0985	\N	new	paid	\N	f	\N
113	Meta Platforms Ireland Limited		FBADS-271-105237862	2026-01-09	804.54	RON	https://drive.google.com/file/d/1u6f8qIcBpcpmESQarLRaiLWCAOrg6PTm/view?usp=drivesdk		2026-01-13 12:07:23.332222	2026-01-13 12:11:45.376637	804.54	157.8	5.0985	\N	new	paid	\N	f	\N
117	Meta Platforms Ireland Limited		FBADS-733-105205142	2025-12-06	539.52	RON	https://drive.google.com/file/d/1Ch4tWBlkyZLysQq8QfeSYPyVJ1b6kJ2y/view?usp=drivesdk		2026-01-13 12:17:43.72701	2026-01-14 09:23:31.608503	539.52	105.96	5.0919	\N	processed	paid	\N	f	\N
119	Google Ireland Limited		5457901727	2025-12-31	-7.46	RON	https://drive.google.com/file/d/1NATrame6lYJZoW2Cq_uS-phYBv6lI9ss/view?usp=drivesdk		2026-01-13 12:24:44.37308	2026-01-14 09:35:23.517362	-7.46	-1.46	5.0985	\N	processed	paid	\N	f	\N
112	Meta Platforms Ireland Limited		FBADS-271-105142069	2025-12-14	218.75	RON	https://drive.google.com/file/d/110oIjB3YzWlZTRjKkmTjDCSPo1FDF6ED/view?usp=drivesdk		2026-01-13 12:02:12.281377	2026-01-14 09:21:14.997425	218.75	42.97	5.0904	\N	processed	paid	\N	f	\N
111	Meta Platforms Ireland Limited		FBADS-271-105142070	2025-12-14	437.5	RON	https://drive.google.com/file/d/1N2jesfZbkjTIjqKFBS72pdxblFaJydjM/view?usp=drivesdk		2026-01-13 12:01:30.853647	2026-01-14 09:19:21.939301	437.5	85.95	5.0904	\N	processed	paid	\N	f	\N
110	Meta Platforms Ireland Limited		FBADS-271-105142071	2025-12-14	875	RON	https://drive.google.com/file/d/1Opnr0Y6EgeQ0dNId5Nhq1h4oJY6nL2hS/view?usp=drivesdk		2026-01-13 12:00:04.11625	2026-01-14 08:56:48.662125	875	171.89	5.0904	\N	processed	paid	\N	f	\N
109	Meta Platforms Ireland Limited		FBADS-271-105144540	2025-12-15	123.04	RON	https://drive.google.com/file/d/1Cm-hIaXNqaoZptr4AzAcGgl2j7OE_Ed0/view?usp=drivesdk		2026-01-13 11:53:40.17306	2026-01-14 08:55:09.955507	123.04	24.17	5.0914	\N	processed	paid	\N	f	\N
103	VGS ROMANIA SRL		VGSR 3443	2025-12-04	608.63	RON	https://drive.google.com/file/d/1Msvn87cXlmfQKI4HrHGsmxuj2F1n7gta/view?usp=drivesdk		2026-01-13 08:05:38.87548	2026-01-14 07:13:28.789848	608.63	119.53	5.092	\N	processed	not_paid	21	t	503
102	VGS ROMANIA SRL		VGSR 3457	2025-12-26	708.29	RON	https://drive.google.com/file/d/1ByDJz_CZRWos8Vugpg2YOOaBbsCUEp6n/view?usp=drivesdk		2026-01-13 08:04:15.48575	2026-01-14 07:15:14.9991	708.29	139.18	5.089	\N	processed	not_paid	21	t	585.36
37	CRUSH DISTRIBUTION SRL		CRD-F2520703	2025-12-10	3841.83	RON	https://drive.google.com/file/d/1b7VxIBkXsDCBwVdC5hrqM6jFJS38XuyS/view?usp=drivesdk	Fidelizare clienti corporate Autoworld	2025-12-15 13:01:55.777912	2026-01-14 08:07:00.521489	3841.83	754.87	5.0894	\N	processed	not_paid	21	t	3175.07
104	Meta Platforms Ireland Limited		FBADS-271-105149915	2025-12-16	364.96	RON	https://drive.google.com/file/d/1uMAKyVFbDYUzuqsmK-oQrhivqN_akJpJ/view?usp=drivesdk		2026-01-13 11:44:06.817112	2026-01-14 08:24:05.020634	364.96	71.67	5.092	\N	processed	paid	\N	f	\N
108	Meta Platforms Ireland Limited		FBADS-271-105144541	2025-12-15	246.08	RON	https://drive.google.com/file/d/14_kuI-phfL1XZpLsdldQ6CxIGH_dZfqU/view?usp=drivesdk		2026-01-13 11:53:02.407854	2026-01-14 08:53:28.970848	246.08	48.33	5.0914	\N	processed	paid	\N	f	\N
96	Meta Platforms Ireland Limited		FBADS-416-105234039	2025-12-31	489.45	RON	https://drive.google.com/file/d/1nODdvqBJuj4j9ikyA9HxEs9cVMOe_lPc/view?usp=drivesdk		2026-01-12 12:53:44.208571	2026-01-14 07:18:22.908242	489.45	96	5.0985	\N	processed	paid	\N	f	\N
123	VGS ROMANIA SRL		VGSR 3453	2025-12-25	1295.43	RON	https://drive.google.com/file/d/1D5S5Ifi8lukQ1FuWCt-ogc5QW8kRAC6N/view?usp=drivesdk		2026-01-13 12:34:36.827775	2026-01-13 13:01:02.497648	1295.43	254.55	5.089	\N	processed	not_paid	21	t	1070.6
90	Meta Platforms Ireland Limited		FBADS-569-105264679	2025-12-26	296.76	RON	https://drive.google.com/file/d/1SeYBvbBaVweJZGNe7BvpcelHmz72A3jx/view?usp=drivesdk		2026-01-12 12:35:47.909019	2026-01-13 15:10:19.243505	296.76	58.31	5.089	\N	processed	paid	\N	f	\N
141	Hetzner Online GmbH		088000662705	2025-12-22	179.91	EUR	https://drive.google.com/file/d/1SVqkuZUVe2CwXirNAkkRXNMTWDFTXyTF/view?usp=drivesdk		2026-01-14 12:48:05.92311	2026-01-14 14:26:00.718882	915.4	179.91	5.0881	\N	processed	paid	\N	f	\N
129	TikTok Information Technologies UK Limited		BDUK20253412070	2025-09-18	60	RON	https://drive.google.com/file/d/1dBgNqQObGN81VCeEUfM-kUZmHPG28rlf/view?usp=drivesdk		2026-01-13 15:10:05.481203	2026-01-13 15:36:56.796594	60	11.84	5.0695	\N	processed	paid	\N	f	\N
130	TikTok Information Technologies UK Limited		BDUK2025342607	2025-09-18	48	RON	https://drive.google.com/file/d/1DAdQ0RIWbnuRY_cIz9H5Mt_9o8aKcfoq/view?usp=drivesdk		2026-01-13 15:10:32.975244	2026-01-13 15:37:51.757304	48	9.47	5.0695	\N	processed	paid	\N	f	\N
149	RACEPOINT CAFE S.R.L.		RACE0001	2025-12-07	891.1	RON	https://drive.google.com/file/d/1UcsR-es_589uHvMkaIG4rBiZXWRkMJFL/view?usp=drivesdk		2026-01-14 14:27:57.968204	2026-01-14 14:28:02.305668	891.1	175	5.0919	\N	new	not_paid	\N	f	\N
131	TikTok Information Technologies UK Limited		BDUK2025394960	2025-09-17	40	RON	https://drive.google.com/file/d/1IdkMLRMrMampKMdXkttg86LgwwKDNue1/view?usp=drivesdk		2026-01-13 15:11:01.046587	2026-01-13 15:38:50.09294	40	7.89	5.067	\N	processed	paid	\N	f	\N
150	Google Ireland Limited		5459006386	2025-12-31	841.06	RON	https://drive.google.com/file/d/1k12CEP1OvdW6BHRlOin9Mc6lxAY_-4ct/view?usp=drivesdk		2026-01-14 14:35:27.741206	2026-01-14 14:35:32.182656	841.06	164.96	5.0985	\N	new	paid	\N	f	\N
45	Meta Platforms Ireland Limited		FBADS-416-105183158	2025-12-16	250.48	RON	https://drive.google.com/file/d/1MCqmFLd23VMQ1JlYqtIT3KkXk-BEdgoQ/view?usp=drivesdk		2025-12-17 11:59:48.050294	2026-01-14 07:18:41.711872	250.48	49.19	5.092	\N	processed	paid	\N	f	\N
46	Meta Platforms Ireland Limited		FBADS-416-105183170	2025-12-16	438.33	RON	https://drive.google.com/file/d/1EHN3uiELxUksZg64uW9Wp9pIZyl5l838/view?usp=drivesdk		2025-12-17 12:02:11.83272	2026-01-14 08:26:36.813664	438.33	86.08	5.092	\N	new	paid	\N	f	\N
132	TikTok Information Technologies UK Limited		BDUK20253372566	2025-09-16	22	RON	https://drive.google.com/file/d/1Oa1tdaXCqfc3s4UbdHP6qfLsUBpgbsW3/view?usp=drivesdk		2026-01-13 15:11:31.471187	2026-01-13 15:39:51.953822	22	4.34	5.0634	\N	processed	paid	\N	f	\N
44	Meta Platforms Ireland Limited		FBADS-569-105210367	2025-12-13	274.49	RON	https://drive.google.com/file/d/1BHZe4Xz3EYxlxgaF2wDLTGHKNLo7r5G9/view?usp=drivesdk		2025-12-17 11:50:50.915596	2025-12-19 09:41:14.582366	274.49	53.92	5.0904	\N	processed	paid	\N	f	\N
91	Meta Platforms Ireland Limited		FBADS-416-105187620	2025-12-17	4583.61	RON	https://drive.google.com/file/d/1RIm51iFTbdeb65E_7yghyxUtCfo681TK/view?usp=drivesdk		2026-01-12 12:38:07.971788	2026-01-13 14:28:34.709244	4583.61	900.11	5.0923	\N	processed	paid	\N	f	\N
107	Meta Platforms Ireland Limited		FBADS-271-105144542	2025-12-15	492.16	RON	https://drive.google.com/file/d/14H0QV-p1u6RdHEKNtqBA4Z4oXzhhwYRK/view?usp=drivesdk		2026-01-13 11:45:31.173884	2026-01-14 08:37:32.646916	492.16	96.66	5.0914	\N	processed	paid	\N	f	\N
122	Meta Platforms Ireland Limited		FBADS-215-105249506	2026-01-09	6432.92	RON	https://drive.google.com/file/d/1DJIS8m44R_j7pH3MxDHNqylrg2cc5Dwh/view?usp=drivesdk		2026-01-13 12:29:04.648036	2026-01-14 07:17:50.405587	6432.92	1261.73	5.0985	\N	processed	paid	\N	f	\N
135	CRUSH DISTRIBUTION SRL		CRD-F2521773	2025-12-19	4208.47	RON	https://drive.google.com/file/d/1HqpxbvfMVmEMeWwL1CtCdjvHCrAqdLgc/view?usp=drivesdk		2026-01-14 06:38:21.857059	2026-01-14 10:13:58.034226	4208.47	826.88	5.0896	\N	processed	not_paid	21	t	3478.07
164	OpenAI Ireland Limited		RIICX51Z-0004	2025-09-16	192.44	EUR	https://drive.google.com/file/d/1_G0BSjzylBdBOvrrx3wGJQQWgirqXdhv/view?usp=drivesdk		2026-01-15 11:55:01.977809	2026-01-16 07:09:51.324664	974.4	192.44	5.0634	\N	processed	paid	\N	f	\N
136	Meta Platforms Ireland Limited		FBADS-271-105149910	2025-12-16	364.97	RON	https://drive.google.com/file/d/13TM-OA5hWc9QCOwA97VlQn6CXCzl6QBx/view?usp=drivesdk		2026-01-14 09:40:13.641594	2026-01-14 09:44:55.242453	364.97	71.68	5.092	\N	processed	paid	\N	f	\N
156	Shopify International Limited		474248795	2026-01-15	4.36	EUR	https://drive.google.com/file/d/1Y_qBrWJWbpj2ZdNcb-fb_gOB6iQnIhOm/view?usp=drivesdk		2026-01-15 11:05:09.331186	2026-01-15 11:05:13.70807	22.19	4.36	5.0891	\N	new	paid	\N	f	\N
163	OpenAI Ireland Limited		RIICX51Z-0003	2025-08-16	192.44	EUR	https://drive.google.com/file/d/15G60dd0o2Ue7aQ8oQvHvZ9A_l2ZGR6qr/view?usp=drivesdk		2026-01-15 11:53:26.710974	2026-01-16 07:09:52.903461	974.29	192.44	5.0628	\N	processed	paid	\N	f	\N
144	Meta Platforms Ireland Limited		FBADS-167-104809153	2025-09-01	1247.72	RON	https://drive.google.com/file/d/18t3UVxnrQ_tcyOTj9baVFMNT7OQ4SFkV/view?usp=drivesdk		2026-01-14 13:25:11.648222	2026-01-16 10:33:03.15413	1247.72	245.98	5.0725	\N	processed	paid	\N	f	\N
162	OpenAI Ireland Limited		L8ASBX7X-0003	2026-01-10	57.14	EUR	https://drive.google.com/file/d/1NBaN1aZYzH0H8UCYqZxyIlobBUt69-uD/view?usp=drivesdk		2026-01-15 11:35:57.457699	2026-01-15 12:47:10.873957	\N	\N	\N	\N	new	paid	\N	f	\N
171	Anthropic, PBC		RLOPHA9P-0007	2026-01-08	180	EUR	https://drive.google.com/file/d/1XuW-SL885uaxd8pG4rq5o1ZhhwJYyhK9/view?usp=drivesdk		2026-01-15 15:29:29.012348	2026-01-16 14:36:00.262787	917.73	180	5.0985	\N	new	paid	\N	f	\N
167	Alaio Inc.		74340440-148373552	2025-10-17	124	USD	https://drive.google.com/file/d/1I-6CyHNVKmlNLyJMUhLP7O3zOJpqqJpt/view?usp=drivesdk		2026-01-15 15:13:35.56577	2026-01-16 14:36:10.224042	539.26	105.97	5.0889	\N	processed	paid	\N	f	\N
176	Alaio Cloud Limited		76205845-151955781	2026-01-19	476.71	EUR	https://drive.google.com/file/d/1Y-lIiYpEGciISweKs0XGG_sELqe6Iqqx/view?usp=drivesdk		2026-01-19 12:46:38.018899	2026-01-19 12:46:42.213366	2427.45	476.71	5.0921	\N	new	not_paid	\N	f	\N
133	TikTok Information Technologies UK Limited		BDUK20253382429	2025-09-16	40	RON	https://drive.google.com/file/d/1OxOks1DXR1X-k1cMCYfPyGK7SPliuQg3/view?usp=drivesdk		2026-01-13 15:12:10.764429	2026-01-13 15:40:38.747717	40	7.9	5.0634	\N	processed	paid	\N	f	\N
174	Shopify International Limited		452751407	2025-11-30	1	EUR	https://drive.google.com/file/d/1nK0Rdp7JM9zlBYAwwNqd2ZWCBPVqa6Ht/view?usp=drivesdk		2026-01-16 08:15:26.989808	2026-01-16 08:40:18.831062	5.09	1	5.0906	\N	processed	paid	\N	f	\N
134	TikTok Information Technologies UK Limited		BDUK20253368656	2025-09-15	22	RON	https://drive.google.com/file/d/1amDUU5Bk9Le-mQQn5F5K1HcjTt9RFlHb/view?usp=drivesdk		2026-01-13 15:12:50.74167	2026-01-13 15:41:21.671641	22	4.35	5.0632	\N	processed	paid	\N	f	\N
138	CRUSH DISTRIBUTION SRL		CRD-F2600193	2026-01-09	1254.72	RON	https://drive.google.com/file/d/1U3SSQIJ6NCSwiM9u2S-qfUHUiRFyM4Yj/view?usp=drivesdk		2026-01-14 09:56:17.318856	2026-01-14 09:56:21.53988	1254.72	246.1	5.0985	\N	new	not_paid	21	t	1036.96
172	Anthropic, PBC		RLOPHA9P-0003	2025-10-02	5.67	EUR	https://drive.google.com/file/d/1DE777dgs1VnOeyhcAhdv8dp4iZOphVPv/view?usp=drivesdk		2026-01-15 15:31:27.94312	2026-01-16 14:35:57.647108	28.82	5.67	5.0837	\N	processed	paid	\N	f	\N
151	Google Ireland Limited		5433853933	2025-11-30	1191.25	RON	https://drive.google.com/file/d/1HGig20UMQQZPWJNRD0lAo_6tmspIr75g/view?usp=drivesdk		2026-01-15 07:10:07.064406	2026-01-15 07:13:18.00883	1191.25	234.01	5.0906	\N	processed	paid	\N	f	\N
146	Meta Platforms Ireland Limited		FBADS-528-105202072	2025-12-11	377.54	RON	https://drive.google.com/file/d/1kwLt5vbpnkaqGeBEVwAXlbeRmZXHG_uW/view?usp=drivesdk		2026-01-14 14:25:29.855568	2026-01-14 15:22:50.911138	377.54	74.18	5.0898	\N	processed	paid	\N	f	\N
145	Meta Platforms Ireland Limited		FBADS-528-105202071	2025-12-11	188.77	RON	https://drive.google.com/file/d/1b4GC6l_VfJ3oQqVXXZHaaY9NBpwIRhOl/view?usp=drivesdk		2026-01-14 14:25:03.301164	2026-01-14 15:23:08.87522	188.77	37.09	5.0898	\N	processed	paid	\N	f	\N
170	Anthropic, PBC		RLOPHA9P-0006	2025-12-08	108.17	EUR	https://drive.google.com/file/d/1AD0kRwRzt669jAcce5QaCZQz9TticUE3/view?usp=drivesdk		2026-01-15 15:28:59.060428	2026-01-16 14:36:01.379636	550.57	108.17	5.0899	\N	processed	paid	\N	f	\N
168	Alaio Inc.		#74340440-145890370	2025-09-17	124	USD	https://drive.google.com/file/d/1GjWUE1K07oUJy9FIQk2wEtWH7WNg5jF3/view?usp=drivesdk	Bitrix	2026-01-15 15:14:30.208506	2026-01-16 14:36:08.573631	530.45	104.69	5.067	\N	processed	paid	\N	f	\N
158	Meta Platforms Ireland Limited		FBADS-125-105296286	2026-01-08	297	RON	https://drive.google.com/file/d/1njMYSvzDr8SL5Ml66Xo76vGJ1a_bdgvn/view?usp=drivesdk		2026-01-15 11:18:04.990076	2026-01-15 11:19:52.114898	\N	\N	\N	\N	incomplete	paid	\N	f	\N
177	ASTINVEST COM SRL		30067	2026-01-19	351.02	RON	https://drive.google.com/file/d/1Mefn0WMqB14S9RNOYW1GT-Zjv1AcaPbP/view?usp=drivesdk	Campanii SMS - Poro Audi Ianuarie	2026-01-19 13:28:16.226708	2026-01-19 13:28:20.959851	351.02	68.93	5.0921	\N	new	not_paid	21	t	290.1
157	Shopify International Limited		468557001	2026-01-04	17.29	EUR	https://drive.google.com/file/d/1GAWf4_DWiTiS77nYpv5exzTQSQMOdI8g/view?usp=drivesdk		2026-01-15 11:08:23.393334	2026-01-15 12:47:15.766244	88.15	17.29	5.0985	\N	new	paid	\N	f	\N
154	Fiverr International Ltd.		FI80176620325	2025-07-30	134.22	EUR	https://drive.google.com/file/d/12w-xK7pFGT9ies7Fs9Rm124e5g3sGMAr/view?usp=drivesdk	Servicii de procesare informatii pt Autoworld.ro	2026-01-15 10:21:25.625341	2026-01-16 07:07:30.280102	681.43	134.22	5.077	\N	processed	paid	\N	f	\N
165	Google Cloud EMEA Limited		5355399164	2025-08-31	82.31	USD	https://drive.google.com/file/d/1DcN2bALM8FX1ipZ2LS5fOMGlpRJyIaji/view?usp=drivesdk		2026-01-15 12:24:39.96418	2026-01-16 07:44:52.559761	357.58	70.5	5.0722	\N	processed	paid	\N	f	\N
178	ASTINVEST COM SRL		30068	2026-01-19	468.02	RON	https://drive.google.com/file/d/1fVV8v0uXj31BJjx91gYB3dPIxaKtYoES/view?usp=drivesdk	Campanii SMS - PORO VW / Skoda / Audi - Ianuarie	2026-01-19 13:29:13.245968	2026-01-19 13:29:17.426166	468.02	91.91	5.0921	\N	new	not_paid	21	t	386.79
\.


--
-- Data for Name: notification_log; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.notification_log (id, responsable_id, invoice_id, notification_type, subject, message, status, error_message, sent_at, created_at) FROM stdin;
99	5	33	allocation	O noua bugetare MKT - PK20252361	\nO noua bugetare MKT\n\nBuna ziua Sebastian Sabo,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: PK20252361\n- Furnizor: Zalau Value Centre SRL\n- Data factura: 2025-12-11\n- Valoare totala: 5,542.36 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 5,542.36 RON\n\nRefacturare:\n- Companie: Autoworld PLUS S.R.L.\n- Linie de business: MG Motor\n- Departament: Sales\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-11 12:36:02.356101	2025-12-11 12:36:00.622866
100	18	33	allocation	O noua bugetare MKT - PK20252361	\nO noua bugetare MKT\n\nBuna ziua George Pop,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: PK20252361\n- Furnizor: Zalau Value Centre SRL\n- Data factura: 2025-12-11\n- Valoare totala: 5,542.36 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 5,542.36 RON\n\nRefacturare:\n- Companie: Autoworld PLUS S.R.L.\n- Linie de business: MG Motor\n- Departament: Sales\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-11 12:36:02.956051	2025-12-11 12:36:02.367435
101	20	33	allocation	O noua bugetare MKT - PK20252361	\nO noua bugetare MKT\n\nBuna ziua Raluca Asztalos,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: PK20252361\n- Furnizor: Zalau Value Centre SRL\n- Data factura: 2025-12-11\n- Valoare totala: 5,542.36 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 5,542.36 RON\n\nRefacturare:\n- Companie: Autoworld PLUS S.R.L.\n- Linie de business: MG Motor\n- Departament: Sales\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-11 12:36:03.58521	2025-12-11 12:36:02.961021
102	21	33	allocation	O noua bugetare MKT - PK20252361	\nO noua bugetare MKT\n\nBuna ziua Gabriel Suciu,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: PK20252361\n- Furnizor: Zalau Value Centre SRL\n- Data factura: 2025-12-11\n- Valoare totala: 5,542.36 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 5,542.36 RON\n\nRefacturare:\n- Companie: Autoworld PLUS S.R.L.\n- Linie de business: MG Motor\n- Departament: Sales\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-11 12:36:04.316909	2025-12-11 12:36:03.589992
103	22	33	allocation	O noua bugetare MKT - PK20252361	\nO noua bugetare MKT\n\nBuna ziua Alina Amironoaei,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: PK20252361\n- Furnizor: Zalau Value Centre SRL\n- Data factura: 2025-12-11\n- Valoare totala: 5,542.36 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 5,542.36 RON\n\nRefacturare:\n- Companie: Autoworld PLUS S.R.L.\n- Linie de business: MG Motor\n- Departament: Sales\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-11 12:36:04.842411	2025-12-11 12:36:04.323542
104	19	33	allocation	O noua bugetare MKT - PK20252361	\nO noua bugetare MKT\n\nBuna ziua Amanda Gavril,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: PK20252361\n- Furnizor: Zalau Value Centre SRL\n- Data factura: 2025-12-11\n- Valoare totala: 5,542.36 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 5,542.36 RON\n\nRefacturare:\n- Companie: Autoworld PLUS S.R.L.\n- Linie de business: MG Motor\n- Departament: Sales\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-11 12:36:05.423972	2025-12-11 12:36:04.847399
136	27	59	allocation	O noua bugetare MKT - 20251511	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 20251511\n- Furnizor: Globo Software Solution., JSC\n- Data factura: 2025-07-17\n- Valoare totala: 114.00 USD\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 114.00 USD\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-18 10:20:34.746879	2025-12-18 10:20:33.599757
142	27	87	allocation	O noua bugetare MKT - PK20260057	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: PK20260057\n- Furnizor: Zalau Value Centre SRL\n- Data factura: 2026-01-12\n- Valoare totala: 5,541.59 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 5,541.59 RON\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2026-01-12 12:01:12.118901	2026-01-12 12:01:09.664526
137	27	66	allocation	O noua bugetare MKT - 560	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 560\n- Furnizor: SERV COMPANY SRL\n- Data factura: 2025-12-19\n- Valoare totala: 847.00 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 847.00 RON\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-19 12:18:05.024991	2025-12-19 12:18:03.340668
143	27	144	allocation	O noua bugetare MKT - FBADS-167-104809153	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: FBADS-167-104809153\n- Furnizor: Meta Platforms Ireland Limited\n- Data factura: 2025-09-01\n- Valoare totala: 1,247.72 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 1,247.72 RON\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2026-01-14 13:25:13.216435	2026-01-14 13:25:11.714871
111	5	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Sebastian Sabo,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld INTERNATIONAL S.R.L.\n- Linie de business: Volkswagen (PKW)\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:06.200694	2025-12-15 09:55:05.414676
112	18	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua George Pop,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld INTERNATIONAL S.R.L.\n- Linie de business: Volkswagen (PKW)\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:06.926311	2025-12-15 09:55:06.215924
113	20	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Raluca Asztalos,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld INTERNATIONAL S.R.L.\n- Linie de business: Volkswagen (PKW)\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:07.598586	2025-12-15 09:55:06.932661
114	21	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Gabriel Suciu,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld INTERNATIONAL S.R.L.\n- Linie de business: Volkswagen (PKW)\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:08.145881	2025-12-15 09:55:07.604221
115	22	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Alina Amironoaei,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld INTERNATIONAL S.R.L.\n- Linie de business: Volkswagen (PKW)\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:08.862373	2025-12-15 09:55:08.153693
116	19	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Amanda Gavril,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld INTERNATIONAL S.R.L.\n- Linie de business: Volkswagen (PKW)\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:09.538821	2025-12-15 09:55:08.868906
117	23	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Calin Duca,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld INTERNATIONAL S.R.L.\n- Linie de business: Volkswagen (PKW)\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:10.322444	2025-12-15 09:55:09.543887
118	24	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Ioan Parocescu,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld INTERNATIONAL S.R.L.\n- Linie de business: Volkswagen (PKW)\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:10.989464	2025-12-15 09:55:10.327655
119	29	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Ovidiu Oprea,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld INTERNATIONAL S.R.L.\n- Linie de business: Volkswagen (PKW)\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:11.683617	2025-12-15 09:55:10.996171
120	5	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Sebastian Sabo,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld PREMIUM S.R.L.\n- Linie de business: Audi\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:12.852106	2025-12-15 09:55:11.703321
121	18	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua George Pop,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld PREMIUM S.R.L.\n- Linie de business: Audi\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:13.567681	2025-12-15 09:55:12.857052
122	20	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Raluca Asztalos,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld PREMIUM S.R.L.\n- Linie de business: Audi\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:14.411104	2025-12-15 09:55:13.608749
123	21	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Gabriel Suciu,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld PREMIUM S.R.L.\n- Linie de business: Audi\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:15.004411	2025-12-15 09:55:14.415525
124	22	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Alina Amironoaei,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld PREMIUM S.R.L.\n- Linie de business: Audi\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:15.515603	2025-12-15 09:55:15.009505
125	19	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Amanda Gavril,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld PREMIUM S.R.L.\n- Linie de business: Audi\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:16.101384	2025-12-15 09:55:15.524379
138	27	70	allocation	O noua bugetare MKT - RNEP nr: 2025002880	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: RNEP nr: 2025002880\n- Furnizor: NEPI Investment Management SRL\n- Data factura: 2025-11-27\n- Valoare totala: 5,774.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 5,774.31 RON\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2026-01-08 07:33:11.941845	2026-01-08 07:33:11.115377
144	27	154	allocation	O noua bugetare MKT - FI80176620325	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: FI80176620325\n- Furnizor: Fiverr International Ltd.\n- Data factura: 2025-07-30\n- Valoare totala: 134.22 EUR\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 134.22 EUR\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2026-01-15 10:21:27.817694	2026-01-15 10:21:25.800307
126	23	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Calin Duca,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld PREMIUM S.R.L.\n- Linie de business: Audi\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:16.674876	2025-12-15 09:55:16.106268
127	24	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Ioan Parocescu,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld PREMIUM S.R.L.\n- Linie de business: Audi\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:17.394881	2025-12-15 09:55:16.680032
128	29	35	allocation	O noua bugetare MKT - 29699	\nO noua bugetare MKT\n\nBuna ziua Ovidiu Oprea,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 29699\n- Furnizor: ASTINVEST COM SRL\n- Data factura: 2025-12-15\n- Valoare totala: 580.31 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 290.15 RON\n\nRefacturare:\n- Companie: Autoworld PREMIUM S.R.L.\n- Linie de business: Audi\n- Departament: Aftersales\n- Subdepartament: Piese si Accesorii\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 09:55:17.950432	2025-12-15 09:55:17.400121
139	27	71	allocation	O noua bugetare MKT - RNEP nr: 2025003243	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: RNEP nr: 2025003243\n- Furnizor: NEPI Investment Management SRL\n- Data factura: 2025-12-23\n- Valoare totala: 5,771.81 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 5,771.81 RON\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2026-01-08 07:34:18.798849	2026-01-08 07:34:18.110176
145	27	162	allocation	O noua bugetare MKT - L8ASBX7X-0003	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: L8ASBX7X-0003\n- Furnizor: OpenAI Ireland Limited\n- Data factura: 2026-01-10\n- Valoare totala: 57.14 EUR\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 50.0%\n- Valoare alocata: 28.57 EUR\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2026-01-15 11:35:58.160895	2026-01-15 11:35:57.52828
129	3	37	allocation	O noua bugetare MKT - CRD-F2520703	\nO noua bugetare MKT\n\nBuna ziua Istvan Papp,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: CRD-F2520703\n- Furnizor: CRUSH DISTRIBUTION SRL\n- Data factura: 2025-12-10\n- Valoare totala: 3,841.83 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Administrativ\n- Procent alocare: 100.0%\n- Valoare alocata: 3,841.83 RON\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-15 13:01:57.786361	2025-12-15 13:01:55.826733
140	27	72	allocation	O noua bugetare MKT - PK20260012	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: PK20260012\n- Furnizor: PK TOPAZ S.R.L.\n- Data factura: 2026-01-05\n- Valoare totala: 4,935.35 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 4,935.35 RON\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2026-01-08 08:14:39.6826	2026-01-08 08:14:38.726691
146	27	175	allocation	O noua bugetare MKT - FBADS-167-104773906	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: FBADS-167-104773906\n- Furnizor: Meta Platforms Ireland Limited\n- Data factura: 2025-08-22\n- Valoare totala: 1,049.58 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 1,049.58 RON\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2026-01-16 14:28:13.913871	2026-01-16 14:28:12.48747
130	5	38	allocation	O noua bugetare MKT - 202507140663	\nO noua bugetare MKT\n\nBuna ziua Sebastian Sabo,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 202507140663\n- Furnizor: Apify Technologies s.r.o.\n- Data factura: 2025-07-14\n- Valoare totala: 421.20 USD\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 421.20 USD\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-17 10:41:32.73391	2025-12-17 10:41:31.771685
131	18	38	allocation	O noua bugetare MKT - 202507140663	\nO noua bugetare MKT\n\nBuna ziua George Pop,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 202507140663\n- Furnizor: Apify Technologies s.r.o.\n- Data factura: 2025-07-14\n- Valoare totala: 421.20 USD\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 421.20 USD\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-17 10:41:33.533969	2025-12-17 10:41:32.750736
132	20	38	allocation	O noua bugetare MKT - 202507140663	\nO noua bugetare MKT\n\nBuna ziua Raluca Asztalos,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 202507140663\n- Furnizor: Apify Technologies s.r.o.\n- Data factura: 2025-07-14\n- Valoare totala: 421.20 USD\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 421.20 USD\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-17 10:41:34.251699	2025-12-17 10:41:33.539775
133	21	38	allocation	O noua bugetare MKT - 202507140663	\nO noua bugetare MKT\n\nBuna ziua Gabriel Suciu,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 202507140663\n- Furnizor: Apify Technologies s.r.o.\n- Data factura: 2025-07-14\n- Valoare totala: 421.20 USD\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 421.20 USD\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-17 10:41:34.9455	2025-12-17 10:41:34.257891
91	22	23	allocation	New Invoice Allocation - FBADS-416-105122906	\nNew Invoice Allocation\n\nHello Alina Amironoaei,\n\nAn invoice has been allocated to your department:\n\nInvoice Details:\n- Invoice Number: FBADS-416-105122906\n- Supplier: Meta Platforms Ireland Limited\n- Invoice Date: 2025-11-30\n- Total Value: 891.66 RON\n\nYour Allocation:\n- Location: Autoworld ONE S.R.L. / Toyota / Aftersales / Piese si Accesorii\n- Allocation %: 31.39%\n- Allocation Value: 279.89 RON\n\n---\nThis is an automated notification from the Bugetare system.\nPlease do not reply to this email.\n	sent	\N	2025-12-10 13:36:43.54709	2025-12-10 13:36:42.959597
92	23	23	allocation	New Invoice Allocation - FBADS-416-105122906	\nNew Invoice Allocation\n\nHello Calin Duca,\n\nAn invoice has been allocated to your department:\n\nInvoice Details:\n- Invoice Number: FBADS-416-105122906\n- Supplier: Meta Platforms Ireland Limited\n- Invoice Date: 2025-11-30\n- Total Value: 891.66 RON\n\nYour Allocation:\n- Location: Autoworld ONE S.R.L. / Toyota / Aftersales / Piese si Accesorii\n- Allocation %: 31.39%\n- Allocation Value: 279.89 RON\n\n---\nThis is an automated notification from the Bugetare system.\nPlease do not reply to this email.\n	sent	\N	2025-12-10 13:36:44.129315	2025-12-10 13:36:43.600037
93	24	23	allocation	New Invoice Allocation - FBADS-416-105122906	\nNew Invoice Allocation\n\nHello Ioan Parocescu,\n\nAn invoice has been allocated to your department:\n\nInvoice Details:\n- Invoice Number: FBADS-416-105122906\n- Supplier: Meta Platforms Ireland Limited\n- Invoice Date: 2025-11-30\n- Total Value: 891.66 RON\n\nYour Allocation:\n- Location: Autoworld ONE S.R.L. / Toyota / Aftersales / Piese si Accesorii\n- Allocation %: 31.39%\n- Allocation Value: 279.89 RON\n\n---\nThis is an automated notification from the Bugetare system.\nPlease do not reply to this email.\n	sent	\N	2025-12-10 13:36:44.875389	2025-12-10 13:36:44.163018
94	29	23	allocation	New Invoice Allocation - FBADS-416-105122906	\nNew Invoice Allocation\n\nHello Ovidiu Oprea,\n\nAn invoice has been allocated to your department:\n\nInvoice Details:\n- Invoice Number: FBADS-416-105122906\n- Supplier: Meta Platforms Ireland Limited\n- Invoice Date: 2025-11-30\n- Total Value: 891.66 RON\n\nYour Allocation:\n- Location: Autoworld ONE S.R.L. / Toyota / Aftersales / Piese si Accesorii\n- Allocation %: 31.39%\n- Allocation Value: 279.89 RON\n\n---\nThis is an automated notification from the Bugetare system.\nPlease do not reply to this email.\n	sent	\N	2025-12-10 13:36:45.451941	2025-12-10 13:36:44.907692
95	22	24	allocation	New Invoice Allocation - 454249619	\nNew Invoice Allocation\n\nHello Alina Amironoaei,\n\nAn invoice has been allocated to your department:\n\nInvoice Details:\n- Invoice Number: 454249619\n- Supplier: Shopify International Limited\n- Invoice Date: 2025-12-04\n- Total Value: 17.52 EUR\n\nYour Allocation:\n- Location: AUTOWORLD S.R.L. / CarFun.ro / Aftersales / Piese si Accesorii\n- Allocation %: 100.0%\n- Allocation Value: 17.52 EUR\n\n---\nThis is an automated notification from the Bugetare system.\nPlease do not reply to this email.\n	sent	\N	2025-12-10 13:47:58.690845	2025-12-10 13:47:57.759602
96	23	24	allocation	New Invoice Allocation - 454249619	\nNew Invoice Allocation\n\nHello Calin Duca,\n\nAn invoice has been allocated to your department:\n\nInvoice Details:\n- Invoice Number: 454249619\n- Supplier: Shopify International Limited\n- Invoice Date: 2025-12-04\n- Total Value: 17.52 EUR\n\nYour Allocation:\n- Location: AUTOWORLD S.R.L. / CarFun.ro / Aftersales / Piese si Accesorii\n- Allocation %: 100.0%\n- Allocation Value: 17.52 EUR\n\n---\nThis is an automated notification from the Bugetare system.\nPlease do not reply to this email.\n	sent	\N	2025-12-10 13:47:59.360698	2025-12-10 13:47:58.740886
97	24	24	allocation	New Invoice Allocation - 454249619	\nNew Invoice Allocation\n\nHello Ioan Parocescu,\n\nAn invoice has been allocated to your department:\n\nInvoice Details:\n- Invoice Number: 454249619\n- Supplier: Shopify International Limited\n- Invoice Date: 2025-12-04\n- Total Value: 17.52 EUR\n\nYour Allocation:\n- Location: AUTOWORLD S.R.L. / CarFun.ro / Aftersales / Piese si Accesorii\n- Allocation %: 100.0%\n- Allocation Value: 17.52 EUR\n\n---\nThis is an automated notification from the Bugetare system.\nPlease do not reply to this email.\n	sent	\N	2025-12-10 13:48:00.143623	2025-12-10 13:47:59.391122
98	29	24	allocation	New Invoice Allocation - 454249619	\nNew Invoice Allocation\n\nHello Ovidiu Oprea,\n\nAn invoice has been allocated to your department:\n\nInvoice Details:\n- Invoice Number: 454249619\n- Supplier: Shopify International Limited\n- Invoice Date: 2025-12-04\n- Total Value: 17.52 EUR\n\nYour Allocation:\n- Location: AUTOWORLD S.R.L. / CarFun.ro / Aftersales / Piese si Accesorii\n- Allocation %: 100.0%\n- Allocation Value: 17.52 EUR\n\n---\nThis is an automated notification from the Bugetare system.\nPlease do not reply to this email.\n	sent	\N	2025-12-10 13:48:00.830985	2025-12-10 13:48:00.201768
134	22	38	allocation	O noua bugetare MKT - 202507140663	\nO noua bugetare MKT\n\nBuna ziua Alina Amironoaei,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 202507140663\n- Furnizor: Apify Technologies s.r.o.\n- Data factura: 2025-07-14\n- Valoare totala: 421.20 USD\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 421.20 USD\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-17 10:41:35.607879	2025-12-17 10:41:34.953433
135	19	38	allocation	O noua bugetare MKT - 202507140663	\nO noua bugetare MKT\n\nBuna ziua Amanda Gavril,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 202507140663\n- Furnizor: Apify Technologies s.r.o.\n- Data factura: 2025-07-14\n- Valoare totala: 421.20 USD\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 421.20 USD\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2025-12-17 10:41:36.315612	2025-12-17 10:41:35.613782
141	27	74	allocation	O noua bugetare MKT - 3	\nO noua bugetare MKT\n\nBuna ziua Dep. Marketing,\n\nO factura a fost alocata departamentului dumneavoastra:\n\nDetalii factura:\n- Numar factura: 3\n- Furnizor: LUCI DETAILING AND COSMETIC AUTO SRL\n- Data factura: 2026-01-05\n- Valoare totala: 270.00 RON\n\nAlocare:\n- Companie: AUTOWORLD S.R.L.\n- Linie de business: Autoworld Holding\n- Departament: Marketing\n- Procent alocare: 100.0%\n- Valoare alocata: 270.00 RON\n\n---\nAceasta este o notificare automata din sistemul Bugetare.\nVa rugam sa nu raspundeti la acest email.\n	sent	\N	2026-01-09 14:02:28.871365	2026-01-09 14:02:28.06778
\.


--
-- Data for Name: notification_settings; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.notification_settings (id, setting_key, setting_value, created_at, updated_at) FROM stdin;
1	smtp_host	smtp.office365.com	2025-12-10 12:59:03.456172	2025-12-17 12:03:37.839464
2	smtp_port	587	2025-12-10 12:59:03.456172	2025-12-17 12:03:37.839464
3	smtp_tls	true	2025-12-10 12:59:03.456172	2025-12-17 12:03:37.839464
4	smtp_username	client@autoworld.ro	2025-12-10 12:59:03.456172	2025-12-17 12:03:37.839464
5	smtp_password	Zaj15803	2025-12-10 12:59:03.456172	2025-12-17 12:03:37.839464
6	from_email	client@autoworld.ro	2025-12-10 12:59:03.456172	2025-12-17 12:03:37.839464
7	from_name	Bugetare Factura	2025-12-10 12:59:03.456172	2025-12-17 12:03:37.839464
8	notify_on_allocation	true	2025-12-10 12:59:03.456172	2025-12-17 12:03:37.839464
49	global_cc	contabilitate@autoworld.ro	2025-12-10 14:30:04.389625	2025-12-17 12:03:37.839464
86	default_columns_accounting	[{"id":"select","name":"","source":"special.select","format":"special","visible":true,"custom":false},{"id":"id","name":"ID","source":"invoice.id","format":"text","visible":false,"custom":false},{"id":"date","name":"Date","source":"invoice.invoice_date","format":"date","visible":true,"custom":false},{"id":"supplier","name":"Supplier","source":"invoice.supplier","format":"text","visible":true,"custom":false},{"id":"invoice_number","name":"Invoice #","source":"invoice.invoice_number","format":"text","visible":true,"custom":false},{"id":"value","name":"Value","source":"invoice.invoice_value","format":"currency","visible":true,"custom":false},{"id":"net_value","name":"Net Value","source":"invoice.net_value","format":"currency","visible":true,"custom":false},{"id":"currency","name":"Currency","source":"invoice.currency","format":"text","visible":false,"custom":false},{"id":"template","name":"Template","source":"invoice.invoice_template","format":"text","visible":false,"custom":false},{"id":"company","name":"Company","source":"allocation.company","format":"text","visible":true,"custom":false},{"id":"department","name":"Department","source":"allocation.department","format":"text","visible":false,"custom":false},{"id":"brand","name":"Brand","source":"allocation.brand","format":"text","visible":false,"custom":false},{"id":"responsible","name":"Responsible","source":"allocation.responsible","format":"text","visible":true,"custom":false},{"id":"reinvoice_to","name":"Reinvoice To","source":"computed.reinvoice_list","format":"reinvoice","visible":true,"custom":false},{"id":"split_values","name":"Split Values","source":"computed.split_values","format":"split","visible":true,"custom":false},{"id":"comment","name":"Notes","source":"invoice.comment","format":"text","visible":false,"custom":false},{"id":"payment_status","name":"Payment","source":"invoice.payment_status","format":"payment_status","visible":true,"custom":false},{"id":"status","name":"Status","source":"invoice.status","format":"status","visible":true,"custom":false},{"id":"drive","name":"Drive","source":"special.drive","format":"special","visible":true,"custom":false},{"id":"actions","name":"Actions","source":"special.actions","format":"special","visible":true,"custom":false}]	2026-01-13 11:40:24.035972	2026-01-13 11:40:24.035972
\.


--
-- Data for Name: reinvoice_destinations; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.reinvoice_destinations (id, allocation_id, company, brand, department, subdepartment, percentage, value, created_at) FROM stdin;
2	100	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	2427.2422	2025-12-15 13:50:57.619909
4	113	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	100	17.52	2025-12-15 13:50:57.619909
7	119	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	421.2	2025-12-17 10:41:31.68115
8	127	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	4580.46	2025-12-17 11:42:29.01105
9	130	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	100	290.155	2025-12-17 11:45:31.745883
10	131	Autoworld PREMIUM S.R.L.	Audi	Aftersales	Piese si Accesorii	100	290.155	2025-12-17 11:45:31.745883
11	136	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	605.17	2025-12-17 11:48:09.125111
43	209	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	56.80567	2025-12-18 09:08:13.539852
44	210	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	45.120686	2025-12-18 09:08:13.539852
45	212	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	25.694939	2025-12-18 09:09:54.27114
46	214	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	25.694939	2025-12-18 09:09:54.27114
47	215	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	25.694939	2025-12-18 09:09:54.27114
48	217	Autoworld PLUS S.R.L.	Mazda	\N	\N	100	143.60428	2025-12-18 09:11:29.865315
49	218	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	143.60428	2025-12-18 09:11:29.865315
50	219	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	143.60428	2025-12-18 09:11:29.865315
51	221	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	554.7665	2025-12-18 09:13:08.024357
52	223	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	554.7665	2025-12-18 09:13:08.024357
53	224	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	554.7665	2025-12-18 09:13:08.024357
54	226	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	611.6252	2025-12-18 09:15:34.898953
55	228	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	401.6852	2025-12-18 09:15:34.898953
56	229	Autoworld PRESTIGE S.R.L.	Volvo	\N	\N	100	911.1396	2025-12-18 09:15:34.898953
57	233	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	499.48224	2025-12-18 09:18:26.836521
58	234	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	499.48224	2025-12-18 09:18:26.836521
59	236	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	553.4775	2025-12-18 09:19:55.236167
60	238	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	335.8678	2025-12-18 09:19:55.236167
61	239	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	1007.6034	2025-12-18 09:19:55.236167
62	240	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	114	2025-12-18 10:20:33.542861
64	268	Autoworld PREMIUM S.R.L.	Audi	Aftersales	Piese si Accesorii	50	49.205	2025-12-19 12:54:20.342906
65	269	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	100	2025-12-23 08:25:50.821717
70	274	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	50	135	2026-01-09 14:02:28.025354
71	274	Autoworld PLUS S.R.L.	Mazda	Sales	\N	50	135	2026-01-09 14:02:28.027898
75	291	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	5541.59	2026-01-12 12:01:09.637052
78	300	Autoworld PREMIUM S.R.L.	Audi	Sales	\N	50	2039.4	2026-01-12 12:28:44.026753
79	300	Autoworld PLUS S.R.L.	Mazda	Sales	\N	50	2039.4	2026-01-12 12:28:44.02838
80	301	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	4770.09	2026-01-12 12:29:13.964898
81	302	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	4772.16	2026-01-12 12:29:25.78391
82	303	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	700	2026-01-12 12:29:57.115682
87	318	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	685.804	2026-01-12 12:39:51.755564
88	319	Autoworld PLUS S.R.L.	MG Motor	\N	\N	100	519.2516	2026-01-12 12:39:51.760676
91	346	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	129.65334	2026-01-12 13:08:59.285804
92	348	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	781.5055	2026-01-12 13:10:36.334774
93	350	Autoworld PLUS S.R.L.	MG Motor	Sales	\N	100	416.65015	2026-01-12 13:10:36.341913
94	351	Autoworld PRESTIGE S.R.L.	Volvo	Sales	\N	100	1073.4814	2026-01-12 13:10:36.346788
95	354	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	0	2026-01-12 13:18:30.860346
96	355	Autoworld PLUS S.R.L.	MG Motor	\N	\N	100	447.03198	2026-01-12 13:18:30.86406
97	374	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	1709.8942	2026-01-12 14:22:59.495123
98	511	Autoworld PLUS S.R.L.	Mazda	Sales	\N	100	2184.02	2026-01-14 10:47:37.010073
99	512	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	179.91	2026-01-14 12:48:05.960396
100	513	Autoworld NEXT S.R.L.	DasWeltAuto	Sales	\N	100	181.65	2026-01-14 12:57:57.272289
101	517	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	1247.72	2026-01-14 13:25:11.678855
102	531	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	134.22	2026-01-15 10:21:25.753953
103	533	Autoworld INTERNATIONAL S.R.L.	Volkswagen (PKW)	Aftersales	Piese si Accesorii	100	4.36	2026-01-15 11:05:09.359704
104	534	Autoworld PREMIUM S.R.L.	Audi	Aftersales	Piese si Accesorii	100	17.29	2026-01-15 11:08:23.418126
105	545	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	124	2026-01-15 15:13:35.630952
106	546	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	124	2026-01-15 15:14:30.217727
107	553	Autoworld NEXT S.R.L.	Autoworld.ro	Sales	\N	100	1049.58	2026-01-16 14:28:12.458303
\.


--
-- Data for Name: responsables; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.responsables (id, name, email, phone, departments, notify_on_allocation, is_active, created_at, updated_at) FROM stdin;
6	Diana Deac	diana.deac@autoworld.ro	0727811525	Director Resurse Umane	t	t	2025-12-10 13:06:21.565508	2025-12-10 13:06:21.565508
4	Claudia Bruslea	claudia.bruslea@autoworld.ro	0732667161	Director Financiar	t	t	2025-12-10 13:04:06.840396	2025-12-10 13:06:36.350456
5	Sebastian Sabo	sebastian.sabo@autoworld.ro	0728889183	Director Marketing	t	t	2025-12-10 13:04:57.995143	2025-12-10 13:06:45.928481
3	Istvan Papp	istvan.papp@autoworld.ro	0723574040	Director Administrativ	t	t	2025-12-10 13:03:24.460502	2025-12-10 13:06:53.474252
7	Ioan Mezei	janos.mezei@autoworld.ro	\N	CEO	t	t	2025-12-10 13:07:33.377332	2025-12-10 13:07:33.377332
8	Lehel Mezei	lehel.mezei@autoworld.ro	\N	COO	t	t	2025-12-10 13:08:11.704604	2025-12-10 13:08:11.704604
9	Sebastian Enache	sebastian.enache@autoworld.ro	\N	CCO	t	t	2025-12-10 13:08:36.056185	2025-12-10 13:08:36.056185
10	Alex Szabo	alex.szabo@autoworld.ro	\N	CAO	t	t	2025-12-10 13:08:55.559255	2025-12-10 13:08:55.559255
11	Roger Patrasc	roger.patrasc@autoworld.ro	\N	Vanzari Audi	t	t	2025-12-10 13:09:34.458045	2025-12-10 13:09:34.458045
12	Ovidiu Ciobanca	ovidiu.ciobanca@autoworld.ro	\N	Vanzari VW	t	t	2025-12-10 13:10:09.621877	2025-12-10 13:10:09.621877
13	Roxana Biris	roxana.biris@autoworld.ro	\N	Vanzari MG	t	t	2025-12-10 13:10:33.090462	2025-12-10 13:10:33.090462
14	Madalina Morutan	madalina.morutan@autoworld.ro	\N	Vanzari Mazda / Volvo	t	t	2025-12-10 13:11:11.09675	2025-12-10 13:11:56.101504
16	Monica Niculae	monica.niculae@autoworld.ro	\N	Vanzari Toyota	t	t	2025-12-10 13:12:20.043597	2025-12-10 13:12:20.043597
17	Ovidiu Bucur	ovidiu.bucur@autoworld.ro	\N	Vanzari Rulate	t	t	2025-12-10 13:12:48.696148	2025-12-10 13:12:48.696148
18	George Pop	george.pop@autoworld.ro	\N	Marketing Audi	t	t	2025-12-10 13:13:13.089203	2025-12-10 13:13:13.089203
20	Raluca Asztalos	raluca.asztalos@autoworld.ro	\N	Marketing VW/LNF	t	t	2025-12-10 13:14:15.380464	2025-12-10 13:14:15.380464
21	Gabriel Suciu	gabriel.suciu@autoworld.ro	\N	Marketing Media	t	t	2025-12-10 13:14:53.433713	2025-12-10 13:14:53.433713
22	Alina Amironoaei	alina.amironoaei@autoworld.ro	\N	Marketing Aftersales	t	t	2025-12-10 13:16:00.315445	2025-12-10 13:16:00.315445
23	Calin Duca	calin.duca@autoworld.ro	\N	Aftersales Audi	t	t	2025-12-10 13:16:37.12013	2025-12-10 13:16:37.12013
24	Ioan Parocescu	ioan.parocescu@autoworld.ro	\N	Aftersales VW/LNF	t	t	2025-12-10 13:16:59.416278	2025-12-10 13:16:59.416278
25	Mihai Ploscar	mihai.ploscar@autoworld.ro	\N	aftersales Mazda/Volvo	t	t	2025-12-10 13:17:22.074092	2025-12-10 13:17:22.074092
26	Daniel Ivascu	daniel.ivascu@autoworld.ro	\N	Vanzari Autoworld.ro	t	t	2025-12-10 13:21:56.390371	2025-12-10 13:21:56.390371
28	Dep. Conta	contabilitate@autoworld.ro	\N	\N	t	t	2025-12-10 13:22:49.919086	2025-12-10 13:22:49.919086
29	Ovidiu Oprea	ovidiu.oprea@autoworld.ro	\N	Aftersales Toyota	t	t	2025-12-10 13:25:59.349943	2025-12-10 13:25:59.349943
19	Amanda Gavril	amanda.gavril@autoworld.ro	\N	Marketing Maza/Volvo/MG	t	t	2025-12-10 13:13:44.386267	2025-12-11 08:03:56.556879
27	Dep. Marketing	marketing@autoworld.ro	\N	Marketing	t	t	2025-12-10 13:22:30.853717	2025-12-17 11:13:13.289984
30	Augustin Popa	augustin.popa@autoworld.ro	\N	Aftersales Volvo	t	t	2026-01-13 09:27:43.18887	2026-01-13 09:28:22.880065
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.roles (id, name, description, can_add_invoices, can_delete_invoices, can_view_invoices, can_access_accounting, can_access_settings, can_access_connectors, can_access_templates, created_at, can_edit_invoices) FROM stdin;
1	Admin	Full access to all features	t	t	t	t	t	t	t	2025-12-10 11:53:08.841307	t
4	Viewer	Read-only access to invoices	f	f	t	t	f	f	f	2025-12-10 11:53:08.841307	f
3	User	Can add and view invoices	t	f	t	t	f	f	t	2025-12-10 11:53:08.841307	t
2	Manager	Can manage invoices and view reports	t	t	t	t	f	f	t	2025-12-10 11:53:08.841307	t
\.


--
-- Data for Name: user_events; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.user_events (id, user_id, user_email, event_type, event_description, entity_type, entity_id, ip_address, user_agent, details, created_at) FROM stdin;
1	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworl.ro	\N	\N	127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 13:42:44.97366
2	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworl.ro	\N	\N	127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 13:42:50.583114
3	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	127.0.0.1	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 13:43:19.261821
4	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	127.0.0.1	curl/8.7.1	{}	2025-12-10 14:13:10.588255
5	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 12:43:59.816939
6	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 12:44:03.353095
7	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 12:44:12.300162
8	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 12:44:16.420327
9	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 12:47:55.677928
10	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 12:48:57.753228
11	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 12:49:01.313759
12	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-10 12:52:12.561953
13	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-10 12:52:54.754041
14	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 12:53:11.192136
15	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-10 12:53:54.189421
16	4	amanda.gavril@autoworld.ro	login	User amanda.gavril@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	{}	2025-12-10 13:26:30.00784
17	5	gabriel.suciu@autoworld.ro	login	User gabriel.suciu@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-10 13:26:59.394902
18	7	alina.amironoaei@autoworld.ro	login	User alina.amironoaei@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	{}	2025-12-10 13:27:00.262903
19	\N	\N	login_failed	Failed login attempt for george.pop@autoworld.ro	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	{}	2025-12-10 13:32:32.452057
20	3	george.pop@autoworld.ro	login	User george.pop@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	{}	2025-12-10 13:32:45.541988
21	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 08:35:57.90421
22	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 08:36:00.64361
23	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 09:27:37.667148
24	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 09:27:44.441052
25	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 09:48:15.930036
26	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 09:51:23.600653
27	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 10:03:55.691486
28	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 10:04:01.025061
29	3	george.pop@autoworld.ro	login	User george.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	{}	2025-12-11 11:38:25.705803
30	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 12:09:38.314842
31	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 12:09:44.303185
32	\N	\N	login_failed	Failed login attempt for raluca.asztalos@autoworld.ro	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 12:22:42.756025
33	6	raluca.asztalos@autoworld.ro	login	User raluca.asztalos@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 12:22:52.405731
34	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 12:27:12.161858
35	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 12:27:16.287716
36	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice AMD 30733 from SENDSMS SOLUTIONS S.R.L.	invoice	32	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 12:28:12.25387
37	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice PK20252361 from Zalau Value Centre SRL	invoice	33	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 12:36:05.428883
38	\N	\N	login_failed	Failed login attempt for mia.pop@autoworld.ro	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 12:55:08.802452
39	\N	\N	login_failed	Failed login attempt for claudia.bruslea@autoworld.ro	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 12:55:26.237784
40	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 12:55:31.282399
41	\N	\N	login_failed	Failed login attempt for claudia.bruslea@autoworld.ro	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 12:56:17.289516
42	\N	\N	login_failed	Failed login attempt for claudia.bruslea@autoworld.ro	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 12:56:43.443987
43	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 12:59:35.567895
44	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 12:59:41.889575
45	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 2026/1200126972 from OLX Online Services SRL	invoice	34	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 13:08:51.327052
46	\N	\N	login_failed	Failed login attempt for alina.juhasz@autoworld.ro	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 13:20:55.277011
47	\N	\N	login_failed	Failed login attempt for alina.juhasz@autoworld.ro	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-11 13:21:10.134065
48	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 33	invoice	33	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 14:52:59.577956
49	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 33	invoice	33	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 14:52:59.741221
50	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 23	invoice	23	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 14:53:43.041011
51	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 23	invoice	23	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-11 14:53:49.921285
52	9	luminita.tolan@autoworld.ro	login	User luminita.tolan@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-12 13:25:34.306266
53	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 24	invoice	24	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 08:50:09.826187
54	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 24	invoice	24	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 08:50:09.892396
55	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 24	invoice	24	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 08:50:09.997132
56	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 24	invoice	24	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 08:50:10.006026
57	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 33	invoice	33	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 08:50:34.59595
58	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 33	invoice	33	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 08:50:43.41221
59	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 24	invoice	24	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:12:11.557011
60	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 24	invoice	24	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:12:11.787035
61	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 24	invoice	24	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:15:32.531443
62	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 24	invoice	24	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:15:32.645817
63	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 24	invoice	24	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:21:27.970615
64	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 24	invoice	24	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:21:28.0821
65	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 24	invoice	24	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:22:27.254284
66	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 24	invoice	24	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:22:27.320026
67	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:42:48.298709
68	9	luminita.tolan@autoworld.ro	login	User luminita.tolan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:42:55.444773
69	9	luminita.tolan@autoworld.ro	logout	User luminita.tolan@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:43:29.121757
70	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 09:43:43.292616
71	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-15 09:46:42.852029
72	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice 29699 from ASTINVEST COM SRL	invoice	35	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-15 09:55:17.956398
73	13	mia.pop@autoworld.ro	logout	User mia.pop@autoworld.ro logged out	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 10:35:26.349333
74	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-15 10:36:31.600858
75	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice VGSR 3449 from VGS ROMANIA SRL	invoice	36	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-15 12:53:53.313223
76	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice CRD-F2520703 from CRUSH DISTRIBUTION SRL	invoice	37	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-15 13:01:57.79368
77	4	amanda.gavril@autoworld.ro	login	User amanda.gavril@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-16 07:17:55.903704
78	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 09:12:21.907863
79	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 09:12:25.062418
80	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 09:32:53.801562
81	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 37	invoice	37	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 09:33:19.302118
82	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 37	invoice	37	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 09:33:19.403984
83	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	curl/8.7.1	{}	2025-12-16 09:40:39.064369
84	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	curl/8.7.1	{}	2025-12-16 10:07:58.142608
85	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.245	curl/8.7.1	{}	2025-12-16 10:15:39.972416
86	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #455531737 status changed from "new" to "processed"	invoice	28	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "processed", "old_status": "new"}	2025-12-16 10:56:09.62722
87	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 28	invoice	28	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 10:56:09.673981
88	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #KCSFWF6E-0001 status changed from "new" to "incomplete"	invoice	26	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2025-12-16 10:56:14.560667
89	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 26	invoice	26	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 10:56:14.566115
90	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #KCSFWF6E-0001 status changed from "incomplete" to "new"	invoice	26	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "new", "old_status": "incomplete"}	2025-12-16 10:57:11.982349
91	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 26	invoice	26	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 10:57:11.988448
120	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-569-105205350 from Meta Platforms Ireland Limited	invoice	40	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 11:38:55.418032
92	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #KCSFWF6E-0001 payment status changed from "not_paid" to "paid"	invoice	26	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-16 10:57:14.265387
93	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 26	invoice	26	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 10:57:14.270623
94	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #455531737 status changed from "processed" to "new"	invoice	28	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "new", "old_status": "processed"}	2025-12-16 10:57:22.741207
95	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 28	invoice	28	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 10:57:22.758689
96	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 10:58:20.156871
97	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 10:58:26.964209
98	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105122906 payment status changed from "not_paid" to "paid"	invoice	23	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-16 11:05:40.773704
99	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 23	invoice	23	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 11:05:40.779883
100	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #SBIE-10163068 payment status changed from "not_paid" to "paid"	invoice	25	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-16 11:05:47.233905
101	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 25	invoice	25	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 11:05:47.238608
102	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #455531737 payment status changed from "not_paid" to "paid"	invoice	28	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-16 11:05:52.713909
103	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 28	invoice	28	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 11:05:52.718735
104	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #5431698595 payment status changed from "not_paid" to "paid"	invoice	30	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-16 11:05:55.519117
105	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 30	invoice	30	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 11:05:55.523058
106	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #AMD 30733 payment status changed from "not_paid" to "paid"	invoice	32	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-16 11:06:08.98635
107	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 32	invoice	32	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 11:06:08.990935
108	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 11:23:45.906084
109	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 11:23:48.442622
110	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	curl/8.7.1	{}	2025-12-16 11:35:07.563579
111	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	curl/8.7.1	{}	2025-12-16 11:36:53.637774
112	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 11:51:27.918195
113	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-16 11:51:39.864901
114	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	curl/8.7.1	{}	2025-12-16 13:26:57.734497
115	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 202507140663 from Apify Technologies s.r.o.	invoice	38	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 10:41:36.324186
116	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #202507140663 payment status changed from "not_paid" to "paid"	invoice	38	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-17 10:41:54.338027
117	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 38	invoice	38	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 10:41:54.342596
118	3	george.pop@autoworld.ro	login	User george.pop@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 11:32:04.727991
119	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-569-105205349 from Meta Platforms Ireland Limited	invoice	39	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 11:36:33.69627
121	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-569-105210364 from Meta Platforms Ireland Limited	invoice	41	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 11:41:06.81637
122	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 36	invoice	36	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:41:51.989898
123	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 36	invoice	36	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:41:52.154304
124	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 33	invoice	33	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:42:28.855886
125	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 33	invoice	33	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:42:29.019821
126	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-569-105210365 from Meta Platforms Ireland Limited	invoice	42	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 11:45:16.207004
127	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 35	invoice	35	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:45:31.587427
128	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 35	invoice	35	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:45:31.760621
129	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 32	invoice	32	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:45:56.238828
130	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 32	invoice	32	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:45:56.442935
131	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 31	invoice	31	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:47:47.241624
132	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 31	invoice	31	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:47:47.404955
133	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-569-105210366 from Meta Platforms Ireland Limited	invoice	43	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 11:47:50.19699
134	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 27	invoice	27	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:48:08.97824
135	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 27	invoice	27	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 11:48:09.13539
136	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-569-105210367 from Meta Platforms Ireland Limited	invoice	44	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 11:50:50.964184
137	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-416-105183158 from Meta Platforms Ireland Limited	invoice	45	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 11:59:48.094324
138	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-416-105183170 from Meta Platforms Ireland Limited	invoice	46	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 12:02:11.924009
139	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-416-105183180 from Meta Platforms Ireland Limited	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 12:05:45.069829
140	3	george.pop@autoworld.ro	payment_status_changed	Invoice #FBADS-569-105210366 payment status changed from "not_paid" to "paid"	invoice	43	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-17 12:06:38.438824
141	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 43	invoice	43	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 12:06:38.447208
142	3	george.pop@autoworld.ro	payment_status_changed	Invoice #FBADS-569-105210365 payment status changed from "not_paid" to "paid"	invoice	42	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-17 12:06:39.654202
143	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 42	invoice	42	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 12:06:39.661418
144	3	george.pop@autoworld.ro	payment_status_changed	Invoice #FBADS-569-105210364 payment status changed from "not_paid" to "paid"	invoice	41	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-17 12:06:40.935843
145	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 41	invoice	41	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 12:06:40.94193
146	3	george.pop@autoworld.ro	payment_status_changed	Invoice #FBADS-569-105205350 payment status changed from "not_paid" to "paid"	invoice	40	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-17 12:06:43.480446
147	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 40	invoice	40	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 12:06:43.489253
148	3	george.pop@autoworld.ro	payment_status_changed	Invoice #FBADS-569-105205349 payment status changed from "not_paid" to "paid"	invoice	39	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-17 12:06:44.563396
149	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 39	invoice	39	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-17 12:06:44.569264
150	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-17 12:43:41.196415
151	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-17 12:44:49.163845
152	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-17 12:45:02.193312
153	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-17 13:04:21.124267
154	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #202507140663 status changed from "new" to "processed"	invoice	38	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2025-12-17 13:04:48.238322
155	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 38	invoice	38	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-17 13:04:48.253694
156	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-17 13:05:51.04993
157	13	mia.pop@autoworld.ro	status_changed	Invoice #VGSR 3449 status changed from "new" to "processed"	invoice	36	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2025-12-17 14:22:22.158174
158	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 36	invoice	36	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-17 14:22:22.17365
159	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105139379 from Meta Platforms Ireland Limited	invoice	48	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 15:44:03.756008
160	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 48	invoice	48	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 15:45:17.556465
161	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 48	invoice	48	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 15:45:17.724756
162	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105139379 payment status changed from "not_paid" to "paid"	invoice	48	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-17 15:46:05.291069
163	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 48	invoice	48	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 15:46:05.295582
164	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 48	invoice	48	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-17 15:46:05.391126
165	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 48	invoice	48	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 07:34:02.71305
166	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 48	invoice	48	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 07:34:02.951419
167	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105139379 from Meta Platforms Ireland Limited	invoice	49	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 08:13:27.042047
168	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105141782 from Meta Platforms Ireland Limited	invoice	50	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 08:16:20.106599
169	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 08:17:43.016495
170	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105187620 from Meta Platforms Ireland Limited	invoice	51	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 08:20:02.683352
171	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105149904 from Meta Platforms Ireland Limited	invoice	52	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 08:20:09.262058
172	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105158618 from Meta Platforms Ireland Limited	invoice	53	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 08:21:51.233033
173	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105169444 from Meta Platforms Ireland Limited	invoice	54	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 08:24:57.315078
174	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105169441 from Meta Platforms Ireland Limited	invoice	55	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 08:28:42.345908
175	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105169443 from Meta Platforms Ireland Limited	invoice	56	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 08:48:48.528015
178	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105169441 payment status changed from "not_paid" to "paid"	invoice	55	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-18 09:09:54.127296
179	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 55	invoice	55	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:09:54.140341
193	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 52	invoice	52	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:15:34.919482
176	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 56	invoice	56	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:08:13.411466
177	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 56	invoice	56	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:08:13.581893
180	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 55	invoice	55	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:09:54.290552
181	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105169443 payment status changed from "not_paid" to "paid"	invoice	56	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-18 09:10:01.186545
182	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 56	invoice	56	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:10:01.191292
183	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105169444 payment status changed from "not_paid" to "paid"	invoice	54	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-18 09:11:20.037006
184	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 54	invoice	54	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:11:20.041872
185	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 54	invoice	54	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:11:29.803476
186	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 54	invoice	54	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:11:29.884691
187	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105158618 payment status changed from "not_paid" to "paid"	invoice	53	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-18 09:12:55.416931
188	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 53	invoice	53	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:12:55.433232
189	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 53	invoice	53	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:13:07.966061
190	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 53	invoice	53	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:13:08.044885
191	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105149904 payment status changed from "not_paid" to "paid"	invoice	52	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-18 09:15:34.798326
192	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 52	invoice	52	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:15:34.802876
194	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105141782 payment status changed from "not_paid" to "paid"	invoice	50	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-18 09:18:26.712548
195	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 50	invoice	50	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:18:26.736762
196	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 50	invoice	50	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:18:26.882382
197	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105139379 payment status changed from "not_paid" to "paid"	invoice	49	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-18 09:19:55.107271
198	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 49	invoice	49	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:19:55.111397
199	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 49	invoice	49	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 09:19:55.2526
200	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 20251511 from Globo Software Solution., JSC	invoice	59	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 10:20:34.787508
201	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice CPY15597 from MERAKI SOLUTIONS SRL	invoice	60	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 10:26:32.107296
202	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 60	invoice	60	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 10:27:46.98684
203	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 60	invoice	60	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 10:27:47.121069
204	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice L8ASBX7X-0002 from OpenAI Ireland Limited	invoice	61	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 11:27:55.799181
205	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 12:06:58.781361
206	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 12:07:03.579398
207	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 12:21:35.174962
208	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 12:27:31.688744
209	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 12:34:55.463599
210	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 12:34:59.255894
211	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 12:45:44.801374
212	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 12:46:06.372115
213	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 12:48:16.905334
214	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice RLOPHA9P 0005 from Anthropic, PBC	invoice	62	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 13:42:21.959424
215	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice RLOPHA9P 0006 from Anthropic, PBC	invoice	63	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 13:42:41.719822
216	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #RLOPHA9P 0006 payment status changed from "not_paid" to "paid"	invoice	63	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-18 13:43:19.067592
217	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 63	invoice	63	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 13:43:19.072877
218	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #RLOPHA9P 0005 payment status changed from "not_paid" to "paid"	invoice	62	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2025-12-18 13:43:20.756456
219	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 62	invoice	62	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 13:43:20.761272
220	5	gabriel.suciu@autoworld.ro	login	User gabriel.suciu@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 13:49:41.624225
221	5	gabriel.suciu@autoworld.ro	invoice_created	Created invoice 2026/1200213871 from OLX Online Services SRL	invoice	64	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 13:52:49.223649
222	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-18 13:59:06.14725
223	13	mia.pop@autoworld.ro	status_changed	Invoice #2026/1200213871 status changed from "new" to "processed"	invoice	64	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2025-12-18 14:01:43.024772
224	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 64	invoice	64	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-18 14:01:43.038915
225	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105205349 status changed from "new" to "processed"	invoice	39	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2025-12-18 14:18:09.889168
226	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 39	invoice	39	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-18 14:18:09.932556
227	13	mia.pop@autoworld.ro	logout	User mia.pop@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-18 14:29:34.886869
228	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-18 14:29:50.229253
229	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:34:10.492743
230	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:34:24.676873
231	13	mia.pop@autoworld.ro	logout	User mia.pop@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:34:40.223053
232	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:34:45.947511
233	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:35:05.541727
234	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:35:15.941295
235	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 40	invoice	40	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:37:28.239582
236	13	mia.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 40	invoice	40	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:37:28.413346
237	13	mia.pop@autoworld.ro	logout	User mia.pop@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:39:40.504289
238	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:39:44.552316
239	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 44	invoice	44	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:40:11.880156
240	13	mia.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 44	invoice	44	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:40:12.010929
241	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 43	invoice	43	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:40:32.826917
242	13	mia.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 43	invoice	43	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:40:32.95757
243	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105210367 status changed from "new" to "incomplete"	invoice	44	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2025-12-18 14:41:40.226871
244	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 44	invoice	44	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:41:40.234349
245	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105210366 status changed from "new" to "incomplete"	invoice	43	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2025-12-18 14:41:41.722762
246	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 43	invoice	43	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:41:41.727342
247	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105205350 status changed from "new" to "incomplete"	invoice	40	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2025-12-18 14:41:43.739273
248	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 40	invoice	40	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:41:43.743906
249	13	mia.pop@autoworld.ro	logout	User mia.pop@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:42:29.237103
250	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:43:57.523528
251	\N	\N	login_failed	Failed login attempt for george.pop@autoworld.ro	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 14:45:00.575563
252	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 14:45:11.3913
253	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 14:47:22.792049
254	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 14:47:40.076368
255	3	george.pop@autoworld.ro	login	User george.pop@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-18 14:47:53.680933
256	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:59:08.623253
257	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-18 14:59:14.897633
258	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-19 06:34:33.2976
259	13	mia.pop@autoworld.ro	logout	User mia.pop@autoworld.ro logged out	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 07:23:27.968097
260	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 07:23:36.136655
261	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:04:00.571322
262	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:04:04.02737
263	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 37	invoice	37	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:10:49.635128
264	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 37	invoice	37	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:10:49.737713
265	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #CRD-F2520703 status changed from "new" to "incomplete"	invoice	37	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2025-12-19 08:11:21.654912
266	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 37	invoice	37	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:11:21.685395
267	4	amanda.gavril@autoworld.ro	login	User amanda.gavril@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-19 08:29:11.579904
268	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 64	invoice	64	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:49:15.203898
269	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 64	invoice	64	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:49:15.302062
270	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 62	invoice	62	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:52:24.982558
271	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 62	invoice	62	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:52:25.085233
272	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 63	invoice	63	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:52:37.192957
273	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 63	invoice	63	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-19 08:52:37.305519
274	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-19 08:59:42.421254
275	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 40	invoice	40	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:35:18.011234
276	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 40	invoice	40	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:35:18.185356
277	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 40	invoice	40	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:37:49.039475
278	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 40	invoice	40	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:37:49.172968
279	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105205350 status changed from "incomplete" to "new"	invoice	40	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "new", "old_status": "incomplete"}	2025-12-19 09:38:12.911375
280	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 40	invoice	40	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:38:12.916039
281	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 43	invoice	43	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:39:36.801387
282	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 43	invoice	43	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:39:36.977667
283	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105210366 status changed from "incomplete" to "processed"	invoice	43	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "processed", "old_status": "incomplete"}	2025-12-19 09:39:59.635598
284	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 43	invoice	43	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:39:59.639691
285	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105210367 status changed from "incomplete" to "processed"	invoice	44	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "processed", "old_status": "incomplete"}	2025-12-19 09:40:05.696138
286	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 44	invoice	44	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:40:05.700842
287	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 44	invoice	44	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:41:14.587636
288	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 44	invoice	44	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 09:41:14.748429
289	3	george.pop@autoworld.ro	invoice_created	Created invoice 041 from SKYTA ECO CLEAN SRL	invoice	65	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2025-12-19 11:10:37.871439
290	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice 560 from SERV COMPANY SRL	invoice	66	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-19 12:18:05.040151
291	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice FBADS-528-105219425 from Meta Platforms Ireland Limited	invoice	67	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-19 12:42:16.962152
292	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice MC22270407 from Mailchimp c/o The Rocket Science Group, LLC	invoice	68	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-19 12:54:20.366753
293	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-23 08:18:15.569763
294	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-23 08:18:48.67409
295	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-23 08:23:42.893005
296	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 2943F109-0009 from OpenAI, LLC	invoice	69	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2025-12-23 08:25:50.844873
297	13	mia.pop@autoworld.ro	status_changed	Invoice #CPY15597 status changed from "new" to "processed"	invoice	60	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2025-12-23 11:56:03.995564
298	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 60	invoice	60	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-23 11:56:04.028749
299	13	mia.pop@autoworld.ro	status_changed	Invoice #041 status changed from "new" to "processed"	invoice	65	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2025-12-23 11:56:20.765542
300	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 65	invoice	65	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-23 11:56:20.769482
301	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-29 09:08:47.579921
302	\N	\N	login_failed	Failed login attempt for amanda.gavril@autoworld.ro	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-30 12:13:19.391878
305	6	raluca.asztalos@autoworld.ro	login	User raluca.asztalos@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-08 07:22:59.9682
303	4	amanda.gavril@autoworld.ro	login	User amanda.gavril@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-30 12:13:27.097393
304	9	luminita.tolan@autoworld.ro	login	User luminita.tolan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2025-12-30 12:15:04.234685
306	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-08 07:24:24.867087
307	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice RNEP nr: 2025002880 from NEPI Investment Management SRL	invoice	70	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-08 07:33:11.947559
308	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice RNEP nr: 2025003243 from NEPI Investment Management SRL	invoice	71	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-08 07:34:18.804334
309	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice PK20260012 from PK TOPAZ S.R.L.	invoice	72	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-08 08:14:39.688445
310	\N	\N	login_failed	Failed login attempt for amanda.gavril@autoworld.ro	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-08 08:27:50.308395
311	\N	\N	login_failed	Failed login attempt for amanda.gavril@autoworld.ro	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-08 08:27:58.80759
312	\N	\N	login_failed	Failed login attempt for amanda.gavril@autoworld.ro	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-08 08:28:13.69125
313	4	amanda.gavril@autoworld.ro	login	User amanda.gavril@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-08 08:28:47.124607
314	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (iPhone; CPU iPhone OS 26_3_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/143.0.7499.151 Mobile/15E148 Safari/604.1	{}	2026-01-09 13:35:47.905351
315	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice SI10391 from SOFTIMPERA SRL	invoice	73	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-09 13:38:27.521767
316	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice 3 from LUCI DETAILING AND COSMETIC AUTO SRL	invoice	74	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-09 14:02:28.884657
317	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice FCL 2731 from SC FIRSTCLEAN SRL	invoice	75	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-09 14:05:17.186527
318	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice 5456946208 from Google Ireland Limited	invoice	76	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-09 14:33:56.975928
319	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FF-348515 from Awesome Projects SRL	invoice	77	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 08:06:24.178393
320	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FF-348515 payment status changed from "not_paid" to "paid"	invoice	77	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-12 08:07:47.703447
321	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 77	invoice	77	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 08:07:47.70954
322	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 77	invoice	77	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 08:07:47.844039
323	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 469842557 from Shopify International Limited	invoice	78	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 08:12:48.371345
324	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 08:19:57.959576
325	1	sebastian.sabo@autoworld.ro	logout	User sebastian.sabo@autoworld.ro logged out	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 08:23:33.368738
326	8	alina.juhas@autoworld.ro	login	User alina.juhas@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 08:23:46.580282
327	8	alina.juhas@autoworld.ro	logout	User alina.juhas@autoworld.ro logged out	\N	\N	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 08:23:53.700094
328	\N	\N	login_failed	Failed login attempt for alina.juhasz@autoworld.ro	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 08:24:34.480944
329	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 08:24:55.024016
330	8	alina.juhasz@autoworld.ro	login	User alina.juhasz@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 08:26:05.364012
331	\N	\N	login_failed	Failed login attempt for francisc.farkas@autoworld.ro	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 08:52:08.019826
332	\N	\N	login_failed	Failed login attempt for francisc.farkas@autoworld.ro	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 08:52:43.054447
333	12	francisc.farkas@autoworld.ro	login	User francisc.farkas@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 09:10:53.695101
334	5	gabriel.suciu@autoworld.ro	invoice_created	Created invoice 2026/1200219759 from OLX Online Services SRL	invoice	79	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 09:19:52.301767
335	5	gabriel.suciu@autoworld.ro	invoice_created	Created invoice 2026/1200225655 from OLX Online Services SRL	invoice	80	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 09:22:16.391296
336	5	gabriel.suciu@autoworld.ro	invoice_created	Created invoice 2026/1200225660 from OLX Online Services SRL	invoice	81	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 09:33:46.390098
337	5	gabriel.suciu@autoworld.ro	invoice_created	Created invoice 2026/1200226916 from OLX Online Services SRL	invoice	82	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 09:38:49.622674
338	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #469842557 payment status changed from "not_paid" to "paid"	invoice	78	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-12 09:49:48.707405
339	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 78	invoice	78	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 09:49:48.722305
340	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #5456946208 payment status changed from "not_paid" to "paid"	invoice	76	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-12 09:50:02.43069
341	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 76	invoice	76	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 09:50:02.436677
342	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice CRD-F2519988 from CRUSH DISTRIBUTION SRL	invoice	83	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 09:55:06.272925
343	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 09:56:50.022251
344	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice 2026120025486 from OLX Online Services SRL	invoice	84	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 10:05:13.921913
345	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 10:17:20.199352
346	8	alina.juhasz@autoworld.ro	login	User alina.juhasz@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 10:19:31.316166
347	\N	\N	login_failed	Failed login attempt for alina.juhasz@autoworld.ro	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 10:21:14.232359
348	3	george.pop@autoworld.ro	invoice_created	Created invoice VGSR 3459 from VGS ROMANIA SRL	invoice	85	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 10:24:41.442916
349	13	mia.pop@autoworld.ro	status_changed	Invoice #VGSR 3459 status changed from "new" to "processed"	invoice	85	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-12 10:39:03.743324
350	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 85	invoice	85	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 10:39:03.766924
351	9	luminita.tolan@autoworld.ro	login	User luminita.tolan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 10:46:42.814822
352	3	george.pop@autoworld.ro	invoice_created	Created invoice 5457877229 from Google Ireland Limited	invoice	86	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 11:33:39.099386
353	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice PK20260057 from Zalau Value Centre SRL	invoice	87	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:01:12.124872
354	13	mia.pop@autoworld.ro	status_changed	Invoice #Rt-01-22 nr. 0177 status changed from "new" to "processed"	invoice	31	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-12 12:16:33.766384
355	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 31	invoice	31	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:16:33.780305
356	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 84	invoice	84	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:20:41.206205
357	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 84	invoice	84	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:20:41.372839
358	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 83	invoice	83	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:21:01.999159
359	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 83	invoice	83	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:21:02.159478
360	5	gabriel.suciu@autoworld.ro	invoice_updated	Updated invoice ID 81	invoice	81	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:23:10.003449
361	5	gabriel.suciu@autoworld.ro	allocations_updated	Updated allocations for invoice ID 81	invoice	81	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:23:10.131049
362	5	gabriel.suciu@autoworld.ro	invoice_updated	Updated invoice ID 80	invoice	80	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:23:26.651669
363	5	gabriel.suciu@autoworld.ro	allocations_updated	Updated allocations for invoice ID 80	invoice	80	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:23:26.780072
364	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105205350 status changed from "new" to "processed"	invoice	40	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-12 12:24:51.239231
365	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 40	invoice	40	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:24:51.243985
366	5	gabriel.suciu@autoworld.ro	invoice_updated	Updated invoice ID 82	invoice	82	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:25:24.977969
367	5	gabriel.suciu@autoworld.ro	allocations_updated	Updated allocations for invoice ID 82	invoice	82	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:25:25.08519
371	5	gabriel.suciu@autoworld.ro	allocations_updated	Updated allocations for invoice ID 84	invoice	84	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:26:07.946623
372	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105210364 status changed from "new" to "processed"	invoice	41	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-12 12:26:58.557297
373	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 41	invoice	41	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:26:58.56236
376	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 72	invoice	72	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:28:43.785236
377	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 72	invoice	72	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:28:44.034172
381	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 70	invoice	70	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:29:25.789346
384	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 37	invoice	37	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:30:50.89297
385	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 37	invoice	37	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:30:51.06016
387	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105210365 status changed from "new" to "processed"	invoice	42	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-12 12:33:04.435662
388	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 42	invoice	42	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:33:04.441026
389	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-569-105264677 from Meta Platforms Ireland Limited	invoice	89	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:33:43.119096
390	13	mia.pop@autoworld.ro	status_changed	Invoice #2026/1200225655 status changed from "new" to "processed"	invoice	80	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-12 12:33:44.909095
391	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 80	invoice	80	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:33:44.913281
392	13	mia.pop@autoworld.ro	status_changed	Invoice #2026/1200225655 status changed from "processed" to "new"	invoice	80	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "new", "old_status": "processed"}	2026-01-12 12:34:11.65309
393	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 80	invoice	80	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:34:11.659026
368	5	gabriel.suciu@autoworld.ro	invoice_updated	Updated invoice ID 79	invoice	79	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:25:35.146883
374	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 83	invoice	83	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:27:13.288175
375	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 83	invoice	83	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:27:13.38928
369	5	gabriel.suciu@autoworld.ro	allocations_updated	Updated allocations for invoice ID 79	invoice	79	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:25:35.24773
370	5	gabriel.suciu@autoworld.ro	invoice_updated	Updated invoice ID 84	invoice	84	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:26:07.848888
378	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 71	invoice	71	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:29:13.741316
379	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 71	invoice	71	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:29:13.971889
380	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 70	invoice	70	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:29:25.616171
382	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 66	invoice	66	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:29:56.966729
383	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 66	invoice	66	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 12:29:57.119894
386	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105174343 from Meta Platforms Ireland Limited	invoice	88	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 12:31:36.694049
394	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-569-105264679 from Meta Platforms Ireland Limited	invoice	90	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:35:47.963866
395	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105187620 from Meta Platforms Ireland Limited	invoice	91	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 12:38:08.091593
396	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105195236 from Meta Platforms Ireland Limited	invoice	92	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 12:39:51.823983
397	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-416-105269415 from Meta Platforms Ireland Limited	invoice	93	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 12:41:24.472275
398	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-569-105267260 from Meta Platforms Ireland Limited	invoice	94	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:45:57.092704
399	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-416-105191330 from Meta Platforms Ireland Limited	invoice	95	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:51:38.531423
400	3	george.pop@autoworld.ro	invoice_created	Created invoice FBADS-416-105234039 from Meta Platforms Ireland Limited	invoice	96	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:53:44.275094
401	5	gabriel.suciu@autoworld.ro	invoice_updated	Updated invoice ID 80	invoice	80	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:56:00.961294
402	5	gabriel.suciu@autoworld.ro	allocations_updated	Updated allocations for invoice ID 80	invoice	80	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:56:01.091647
403	3	george.pop@autoworld.ro	payment_status_changed	Invoice #FBADS-569-105267260 payment status changed from "not_paid" to "paid"	invoice	94	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-12 12:58:12.700133
404	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 94	invoice	94	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:58:12.726682
405	5	gabriel.suciu@autoworld.ro	invoice_updated	Updated invoice ID 79	invoice	79	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:58:45.238743
406	5	gabriel.suciu@autoworld.ro	allocations_updated	Updated allocations for invoice ID 79	invoice	79	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 12:58:45.34461
407	5	gabriel.suciu@autoworld.ro	invoice_updated	Updated invoice ID 81	invoice	81	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:00:33.100614
408	5	gabriel.suciu@autoworld.ro	allocations_updated	Updated allocations for invoice ID 81	invoice	81	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:00:33.1941
409	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 89	invoice	89	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:02:21.489035
410	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 89	invoice	89	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:02:21.694328
411	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 90	invoice	90	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:02:42.021276
412	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 90	invoice	90	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:02:42.16447
413	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 96	invoice	96	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:03:11.001002
414	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 96	invoice	96	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:03:11.212026
415	5	gabriel.suciu@autoworld.ro	invoice_updated	Updated invoice ID 82	invoice	82	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:04:11.930287
416	5	gabriel.suciu@autoworld.ro	allocations_updated	Updated allocations for invoice ID 82	invoice	82	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:04:12.007007
417	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 95	invoice	95	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:06:54.689202
423	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 91	invoice	91	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:10:36.236147
418	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 95	invoice	95	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:06:54.809055
424	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 91	invoice	91	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:10:36.355231
425	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 92	invoice	92	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:13:19.468983
419	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 94	invoice	94	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:07:05.966698
420	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 94	invoice	94	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:07:06.08784
421	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 88	invoice	88	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:08:59.184858
422	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 88	invoice	88	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:08:59.292903
426	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 93	invoice	93	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:18:30.730181
427	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 93	invoice	93	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:18:30.870747
428	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105187620 payment status changed from "not_paid" to "paid"	invoice	91	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-12 13:19:07.848479
429	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 91	invoice	91	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:19:07.854447
430	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105195236 payment status changed from "not_paid" to "paid"	invoice	92	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-12 13:19:09.167195
431	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 92	invoice	92	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:19:09.17223
432	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105269415 payment status changed from "not_paid" to "paid"	invoice	93	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-12 13:19:10.407145
433	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 93	invoice	93	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:19:10.412886
434	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-416-105174343 payment status changed from "not_paid" to "paid"	invoice	88	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-12 13:19:12.853203
435	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 88	invoice	88	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 13:19:12.85894
436	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice FBADS-528-105315964 from Meta Platforms Ireland Limited	invoice	97	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 13:40:22.111097
437	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 84	invoice	84	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 13:42:23.727623
438	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 84	invoice	84	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-12 13:42:23.914977
439	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 95	invoice	95	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:45:28.238538
440	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 95	invoice	95	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:45:28.335913
441	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 96	invoice	96	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:48:01.388879
442	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 96	invoice	96	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:48:01.53364
443	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 86	invoice	86	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:53:41.730576
444	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 86	invoice	86	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:53:41.891955
445	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 89	invoice	89	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:57:34.268119
446	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 89	invoice	89	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:57:34.378297
447	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 90	invoice	90	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:58:27.281623
448	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 90	invoice	90	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 13:58:27.412847
449	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 94	invoice	94	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 14:00:00.687056
450	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 94	invoice	94	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-12 14:00:00.88883
451	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 5459181905 from Google Ireland Limited	invoice	98	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-12 14:22:59.544096
452	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 07:02:05.204886
453	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 75	invoice	75	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 07:12:50.776187
454	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 75	invoice	75	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 07:12:50.891561
455	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #FBADS-416-105234039 status changed from "new" to "incomplete"	invoice	96	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2026-01-13 07:13:00.331349
456	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 96	invoice	96	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 07:13:00.336779
457	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #FBADS-416-105191330 status changed from "new" to "incomplete"	invoice	95	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2026-01-13 07:13:01.70465
458	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 95	invoice	95	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 07:13:01.711681
459	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #FBADS-569-105267260 status changed from "new" to "incomplete"	invoice	94	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2026-01-13 07:13:03.607332
460	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 94	invoice	94	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 07:13:03.611993
461	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #FBADS-569-105264679 status changed from "new" to "incomplete"	invoice	90	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2026-01-13 07:13:07.146408
462	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 90	invoice	90	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 07:13:07.151466
463	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #FBADS-569-105264677 status changed from "new" to "incomplete"	invoice	89	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2026-01-13 07:13:08.82971
464	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 89	invoice	89	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 07:13:08.834121
465	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #FCL 2731 status changed from "new" to "incomplete"	invoice	75	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2026-01-13 07:13:13.9116
466	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 75	invoice	75	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 07:13:13.916523
467	4	amanda.gavril@autoworld.ro	login	User amanda.gavril@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 07:24:19.351442
468	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice LUNA nr. 2822 from LUNA CLEANING MAGIC S.R.L.	invoice	99	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 07:28:45.791201
469	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice VGSR 3458 from VGS ROMANIA SRL	invoice	100	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 07:38:56.429074
470	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice VGSR 3442 from VGS ROMANIA SRL	invoice	101	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 07:51:11.008359
471	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 94	invoice	94	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 07:55:03.2892
472	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 94	invoice	94	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 07:55:03.412892
473	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105267260 status changed from "incomplete" to "new"	invoice	94	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "new", "old_status": "incomplete"}	2026-01-13 07:55:09.818952
474	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 94	invoice	94	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 07:55:09.823945
475	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice VGSR 3457 from VGS ROMANIA SRL	invoice	102	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:04:15.532963
476	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice VGSR 3443 from VGS ROMANIA SRL	invoice	103	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:05:38.898806
477	9	luminita.tolan@autoworld.ro	login	User luminita.tolan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:15:04.14775
478	13	mia.pop@autoworld.ro	status_changed	Invoice #VGSR 3442 status changed from "new" to "processed"	invoice	101	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 08:29:46.866358
479	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 101	invoice	101	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:29:47.625703
480	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 89	invoice	89	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:30:15.42307
481	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 89	invoice	89	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:30:15.533603
482	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105264677 status changed from "incomplete" to "new"	invoice	89	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "new", "old_status": "incomplete"}	2026-01-13 08:30:30.504284
483	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 89	invoice	89	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:30:30.519139
484	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 90	invoice	90	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:31:23.101621
485	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 90	invoice	90	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:31:23.239011
486	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 103	invoice	103	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:31:47.651896
487	4	amanda.gavril@autoworld.ro	allocations_updated	Updated allocations for invoice ID 103	invoice	103	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:31:47.807246
488	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 94	invoice	94	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:32:08.862821
489	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 94	invoice	94	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:32:08.973861
490	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 90	invoice	90	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:33:03.408112
491	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 90	invoice	90	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:33:03.483042
492	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105264679 status changed from "incomplete" to "new"	invoice	90	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "new", "old_status": "incomplete"}	2026-01-13 08:33:09.901393
493	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 90	invoice	90	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:33:09.905843
494	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 102	invoice	102	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:33:58.754366
495	4	amanda.gavril@autoworld.ro	allocations_updated	Updated allocations for invoice ID 102	invoice	102	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:33:58.91553
496	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 101	invoice	101	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:35:08.258661
497	4	amanda.gavril@autoworld.ro	allocations_updated	Updated allocations for invoice ID 101	invoice	101	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:35:08.417132
498	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 100	invoice	100	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:35:55.334465
499	4	amanda.gavril@autoworld.ro	allocations_updated	Updated allocations for invoice ID 100	invoice	100	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:35:55.5746
500	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 96	invoice	96	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:36:02.764446
501	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 96	invoice	96	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:36:02.864317
502	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 96	invoice	96	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:36:18.75653
503	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 96	invoice	96	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:36:18.819296
504	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105234039 status changed from "incomplete" to "new"	invoice	96	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "new", "old_status": "incomplete"}	2026-01-13 08:40:45.713515
505	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 96	invoice	96	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:40:45.718818
506	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 95	invoice	95	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:41:05.681803
507	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 95	invoice	95	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:41:05.783329
508	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #VGSR 3443 status changed from "new" to "incomplete"	invoice	103	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "incomplete", "old_status": "new"}	2026-01-13 08:42:06.645636
509	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 103	invoice	103	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 08:42:06.651301
510	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 96	invoice	96	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:42:25.678598
511	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 96	invoice	96	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:42:25.754732
515	4	amanda.gavril@autoworld.ro	allocations_updated	Updated allocations for invoice ID 99	invoice	99	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:45:10.224746
522	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 89	invoice	89	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:47:56.547168
512	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105191330 status changed from "incomplete" to "new"	invoice	95	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "new", "old_status": "incomplete"}	2026-01-13 08:42:31.769021
513	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 95	invoice	95	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:42:31.77431
516	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 94	invoice	94	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:46:08.574579
523	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 89	invoice	89	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:47:56.644569
514	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 99	invoice	99	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:45:10.074117
519	4	amanda.gavril@autoworld.ro	allocations_updated	Updated allocations for invoice ID 103	invoice	103	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:46:48.282089
524	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 86	invoice	86	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:49:23.655412
525	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 86	invoice	86	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:49:23.751082
526	13	mia.pop@autoworld.ro	status_changed	Invoice #VGSR 3458 status changed from "new" to "processed"	invoice	100	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 08:51:57.760584
527	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 100	invoice	100	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:51:57.765993
517	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 94	invoice	94	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:46:08.651274
518	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 103	invoice	103	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:46:48.125658
520	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 90	invoice	90	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:47:01.051987
521	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 90	invoice	90	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-13 08:47:01.150678
528	13	mia.pop@autoworld.ro	status_changed	Invoice #LUNA nr. 2822 status changed from "new" to "processed"	invoice	99	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 08:51:59.187694
529	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 99	invoice	99	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 08:51:59.193208
530	4	amanda.gavril@autoworld.ro	status_changed	Invoice #VGSR 3443 status changed from "incomplete" to "new"	invoice	103	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "new", "old_status": "incomplete"}	2026-01-13 09:21:24.275452
531	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 103	invoice	103	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 09:21:24.304327
532	13	mia.pop@autoworld.ro	status_changed	Invoice #VGSR 3443 status changed from "new" to "eronata"	invoice	103	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "eronata", "old_status": "new"}	2026-01-13 09:28:58.177128
533	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 103	invoice	103	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 09:28:58.18315
534	13	mia.pop@autoworld.ro	status_changed	Invoice #VGSR 3443 status changed from "eronata" to "new"	invoice	103	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "new", "old_status": "eronata"}	2026-01-13 09:29:08.258051
535	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 103	invoice	103	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 09:29:08.26336
536	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #FCL 2731 status changed from "incomplete" to "eronata"	invoice	75	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "eronata", "old_status": "incomplete"}	2026-01-13 09:49:30.660886
537	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 75	invoice	75	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 09:49:30.694128
538	1	sebastian.sabo@autoworld.ro	default_columns_set	Set default column config for accounting tab	\N	\N	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 11:40:24.041615
539	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105149915 from Meta Platforms Ireland Limited	invoice	104	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:44:06.96404
540	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105149896 from Meta Platforms Ireland Limited	invoice	105	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:44:44.021537
541	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105149887 from Meta Platforms Ireland Limited	invoice	106	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:45:03.631913
542	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105144542 from Meta Platforms Ireland Limited	invoice	107	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:45:31.242324
543	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105144541 from Meta Platforms Ireland Limited	invoice	108	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:53:02.537127
544	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105144540 from Meta Platforms Ireland Limited	invoice	109	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:53:40.279264
545	13	mia.pop@autoworld.ro	status_changed	Invoice #KCSFWF6E-0001 status changed from "new" to "processed"	invoice	26	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 11:57:51.736217
546	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 26	invoice	26	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:57:51.76127
547	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:58:00.239921
548	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:58:23.416727
549	13	mia.pop@autoworld.ro	status_changed	Invoice #5431698595 status changed from "new" to "processed"	invoice	30	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 11:58:31.222181
550	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 30	invoice	30	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:58:31.227751
551	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:59:04.751674
552	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 11:59:56.375439
553	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105142071 from Meta Platforms Ireland Limited	invoice	110	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:00:04.23106
554	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105142070 from Meta Platforms Ireland Limited	invoice	111	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:01:30.925673
558	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105237812 from Meta Platforms Ireland Limited	invoice	115	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:10:12.779431
559	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105237788 from Meta Platforms Ireland Limited	invoice	116	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:10:34.01334
562	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105237812 payment status changed from "not_paid" to "paid"	invoice	115	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:41.738471
563	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 115	invoice	115	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:41.744532
564	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105237838 payment status changed from "not_paid" to "paid"	invoice	114	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:42.787628
565	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 114	invoice	114	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:42.79291
566	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105237862 payment status changed from "not_paid" to "paid"	invoice	113	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:45.382904
567	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 113	invoice	113	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:45.388096
568	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105142069 payment status changed from "not_paid" to "paid"	invoice	112	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:46.385913
569	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 112	invoice	112	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:46.39187
570	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105142070 payment status changed from "not_paid" to "paid"	invoice	111	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:47.437515
571	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 111	invoice	111	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:47.443929
572	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105142071 payment status changed from "not_paid" to "paid"	invoice	110	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:49.035647
573	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 110	invoice	110	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:49.042181
578	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105144541 payment status changed from "not_paid" to "paid"	invoice	108	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:51.467451
579	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 108	invoice	108	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:51.478581
584	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105149896 payment status changed from "not_paid" to "paid"	invoice	105	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:56.208461
585	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 105	invoice	105	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:56.214541
586	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105149915 payment status changed from "not_paid" to "paid"	invoice	104	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:57.360029
587	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 104	invoice	104	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:57.366085
588	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #VGSR 3443 payment status changed from "not_paid" to "paid"	invoice	103	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:58.459639
589	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 103	invoice	103	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:58.465333
590	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #VGSR 3457 payment status changed from "not_paid" to "paid"	invoice	102	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:59.68407
555	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105142069 from Meta Platforms Ireland Limited	invoice	112	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:02:12.370131
556	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105237862 from Meta Platforms Ireland Limited	invoice	113	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:07:23.4097
557	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105237838 from Meta Platforms Ireland Limited	invoice	114	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:09:47.907874
560	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105237788 payment status changed from "not_paid" to "paid"	invoice	116	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:40.650644
561	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 116	invoice	116	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:40.656562
574	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105144540 payment status changed from "not_paid" to "paid"	invoice	109	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:50.1682
575	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 109	invoice	109	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:50.172931
576	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105139379 status changed from "new" to "processed"	invoice	49	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 12:11:50.708923
577	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 49	invoice	49	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:50.714493
580	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105144542 payment status changed from "not_paid" to "paid"	invoice	107	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:53.134695
581	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 107	invoice	107	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:53.140377
582	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105149887 payment status changed from "not_paid" to "paid"	invoice	106	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:11:54.307934
583	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 106	invoice	106	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:54.313697
594	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #VGSR 3443 payment status changed from "paid" to "not_paid"	invoice	103	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "not_paid", "old_payment_status": "paid"}	2026-01-13 12:12:07.524262
595	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 103	invoice	103	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:12:07.530924
591	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 102	invoice	102	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:11:59.688787
592	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #VGSR 3457 payment status changed from "paid" to "not_paid"	invoice	102	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "not_paid", "old_payment_status": "paid"}	2026-01-13 12:12:01.875607
593	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 102	invoice	102	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:12:01.894967
596	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105141782 status changed from "new" to "processed"	invoice	50	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 12:14:53.493732
597	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 50	invoice	50	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:14:53.500893
598	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-733-105205142 from Meta Platforms Ireland Limited	invoice	117	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:17:43.797277
599	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105149904 status changed from "new" to "processed"	invoice	52	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 12:17:50.653035
600	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 52	invoice	52	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:17:50.660155
601	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105158618 status changed from "new" to "processed"	invoice	53	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 12:19:02.391907
602	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 53	invoice	53	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:19:02.398073
603	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105169444 status changed from "new" to "processed"	invoice	54	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 12:20:23.946457
604	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 54	invoice	54	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:20:23.972169
605	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice 5456072388 from Google Ireland Limited	invoice	118	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:20:50.005485
606	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice 5457901727 from Google Ireland Limited	invoice	119	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:24:44.407729
607	6	raluca.asztalos@autoworld.ro	status_changed	Invoice #FCL 2731 status changed from "eronata" to ""	invoice	75	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "", "old_status": "eronata"}	2026-01-13 12:24:59.599776
608	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 75	invoice	75	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:24:59.604215
609	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 75	invoice	75	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:24:59.772065
610	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice 5457633052 from Google Ireland Limited	invoice	120	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:25:55.324477
611	6	raluca.asztalos@autoworld.ro	status_changed	Invoice #FCL 2731 status changed from "" to "new"	invoice	75	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "new", "old_status": ""}	2026-01-13 12:26:05.668596
612	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 75	invoice	75	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:26:05.673586
613	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 75	invoice	75	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:26:05.786272
614	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105169441 status changed from "new" to "processed"	invoice	55	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 12:27:10.081703
615	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 55	invoice	55	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:27:10.089986
616	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105169443 status changed from "new" to "processed"	invoice	56	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 12:28:27.308322
617	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 56	invoice	56	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:28:27.315363
618	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-215-105141145 from Meta Platforms Ireland Limited	invoice	121	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:28:44.976067
619	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-215-105249506 from Meta Platforms Ireland Limited	invoice	122	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:29:04.762375
622	13	mia.pop@autoworld.ro	status_changed	Invoice #SI10391 status changed from "new" to "processed"	invoice	73	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 12:33:07.709105
623	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 73	invoice	73	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:33:07.71536
624	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice VGSR 3453 from VGS ROMANIA SRL	invoice	123	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:34:36.901605
620	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105174343 status changed from "new" to "processed"	invoice	88	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 12:29:39.132316
621	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 88	invoice	88	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:29:39.13719
625	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:41:42.715459
628	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-215-105141145 payment status changed from "not_paid" to "paid"	invoice	121	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:49:31.28567
629	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 121	invoice	121	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:49:31.292012
632	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #5457901727 payment status changed from "not_paid" to "paid"	invoice	119	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:49:33.521027
633	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 119	invoice	119	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:49:33.531137
634	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #5456072388 payment status changed from "not_paid" to "paid"	invoice	118	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:49:34.687678
635	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 118	invoice	118	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:49:34.693042
638	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:59:40.050546
626	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-215-105249506 payment status changed from "not_paid" to "paid"	invoice	122	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:49:30.402744
627	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 122	invoice	122	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:49:30.454235
630	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #5457633052 payment status changed from "not_paid" to "paid"	invoice	120	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:49:32.408852
631	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 120	invoice	120	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:49:32.414459
636	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-733-105205142 payment status changed from "not_paid" to "paid"	invoice	117	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 12:49:36.19535
637	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 117	invoice	117	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 12:49:36.202015
639	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #VGSR 3453 status changed from "new" to "processed"	invoice	123	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 13:01:02.505051
640	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 123	invoice	123	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 13:01:02.513926
641	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 13:05:12.208619
642	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 13:09:05.481277
643	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 13:09:51.668531
644	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #2026120025486 status changed from "new" to "processed"	invoice	84	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 13:10:27.340351
645	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 84	invoice	84	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 13:10:27.344742
646	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 14:04:49.273508
647	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 14:05:09.674595
648	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105187620 status changed from "new" to "processed"	invoice	91	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 14:28:34.841015
649	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 91	invoice	91	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 14:28:34.884339
650	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105195236 status changed from "new" to "processed"	invoice	92	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 14:34:35.074726
651	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 92	invoice	92	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 14:34:35.164958
652	13	mia.pop@autoworld.ro	status_changed	Invoice #5459181905 status changed from "new" to "processed"	invoice	98	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 14:39:48.072222
653	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 98	invoice	98	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 14:39:48.097692
654	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 37	invoice	37	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 14:46:51.312724
655	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 37	invoice	37	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 14:46:51.498242
656	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 37	invoice	37	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 14:47:42.794957
657	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 37	invoice	37	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 14:47:42.87465
658	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #CRD-F2520703 status changed from "incomplete" to "new"	invoice	37	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "new", "old_status": "incomplete"}	2026-01-13 14:47:50.836565
659	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 37	invoice	37	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 14:47:50.842107
660	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 464031740 from Shopify International Limited	invoice	124	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 14:58:29.307608
661	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK20253636260 from TikTok Information Technologies UK Limited	invoice	125	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:07:50.694881
673	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105267260 status changed from "new" to "processed"	invoice	94	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:12:01.464995
674	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 94	invoice	94	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:12:01.473975
675	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK20253382429 from TikTok Information Technologies UK Limited	invoice	133	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:12:10.792107
662	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105264677 status changed from "new" to "processed"	invoice	89	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:08:20.352994
663	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 89	invoice	89	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:08:20.359583
664	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK20253475989 from TikTok Information Technologies UK Limited	invoice	126	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:08:30.035951
665	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK2025463735 from TikTok Information Technologies UK Limited	invoice	127	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:08:57.772639
666	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK2025344182 from TikTok Information Technologies UK Limited	invoice	128	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:09:31.864243
667	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK20253412070 from TikTok Information Technologies UK Limited	invoice	129	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:10:05.522256
668	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-569-105264679 status changed from "new" to "processed"	invoice	90	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:10:19.248532
669	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 90	invoice	90	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:10:19.253444
670	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK2025342607 from TikTok Information Technologies UK Limited	invoice	130	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:10:33.007935
671	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK2025394960 from TikTok Information Technologies UK Limited	invoice	131	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:11:01.086266
672	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK20253372566 from TikTok Information Technologies UK Limited	invoice	132	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:11:31.500634
676	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice BDUK20253368656 from TikTok Information Technologies UK Limited	invoice	134	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:12:50.77357
677	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #BDUK20253368656 payment status changed from "not_paid" to "paid"	invoice	134	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 15:13:15.522776
678	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 134	invoice	134	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:13:15.54994
679	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #BDUK20253382429 payment status changed from "not_paid" to "paid"	invoice	133	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 15:13:16.564145
680	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 133	invoice	133	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:13:16.569543
681	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #BDUK20253372566 payment status changed from "not_paid" to "paid"	invoice	132	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 15:13:18.045467
682	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 132	invoice	132	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:13:18.051823
689	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #BDUK2025344182 payment status changed from "not_paid" to "paid"	invoice	128	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 15:13:24.408723
690	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 128	invoice	128	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:13:24.413347
691	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #BDUK2025463735 payment status changed from "not_paid" to "paid"	invoice	127	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 15:13:25.640421
692	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 127	invoice	127	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:13:25.645321
693	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #BDUK20253475989 payment status changed from "not_paid" to "paid"	invoice	126	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 15:13:27.154339
694	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 126	invoice	126	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:13:27.159512
695	13	mia.pop@autoworld.ro	status_changed	Invoice #464031740 status changed from "new" to "processed"	invoice	124	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:31:14.102411
683	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #BDUK2025394960 payment status changed from "not_paid" to "paid"	invoice	131	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 15:13:19.352507
684	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 131	invoice	131	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:13:19.359389
685	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #BDUK2025342607 payment status changed from "not_paid" to "paid"	invoice	130	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 15:13:21.512748
686	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 130	invoice	130	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:13:21.518385
687	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #BDUK20253412070 payment status changed from "not_paid" to "paid"	invoice	129	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-13 15:13:22.943592
688	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 129	invoice	129	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-13 15:13:22.949941
699	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK2025344182 status changed from "new" to "processed"	invoice	128	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:32:23.177614
700	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 128	invoice	128	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:32:23.183481
701	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK2025463735 status changed from "new" to "processed"	invoice	127	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:32:35.61434
702	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 127	invoice	127	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:32:35.618838
696	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 124	invoice	124	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:31:14.114602
697	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK20253636260 status changed from "new" to "processed"	invoice	125	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:31:58.316123
698	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 125	invoice	125	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:31:58.348682
703	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK20253475989 status changed from "new" to "processed"	invoice	126	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:35:11.300814
704	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 126	invoice	126	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:35:11.348812
705	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK20253412070 status changed from "new" to "processed"	invoice	129	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:36:56.80141
706	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 129	invoice	129	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:36:56.808811
707	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK2025342607 status changed from "new" to "processed"	invoice	130	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:37:51.762292
708	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 130	invoice	130	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:37:51.767405
709	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK2025394960 status changed from "new" to "processed"	invoice	131	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:38:50.101942
710	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 131	invoice	131	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:38:50.119818
711	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK20253372566 status changed from "new" to "processed"	invoice	132	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:39:51.958372
712	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 132	invoice	132	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:39:51.965005
713	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK20253382429 status changed from "new" to "processed"	invoice	133	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:40:38.753542
714	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 133	invoice	133	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:40:38.773629
715	13	mia.pop@autoworld.ro	status_changed	Invoice #BDUK20253368656 status changed from "new" to "processed"	invoice	134	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-13 15:41:21.677165
716	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 134	invoice	134	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-13 15:41:21.685403
717	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice CRD-F2521773 from CRUSH DISTRIBUTION SRL	invoice	135	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 06:38:21.942977
718	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-215-105141145 status changed from "new" to "processed"	invoice	121	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 06:58:50.704763
719	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 121	invoice	121	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 06:58:50.719206
720	9	luminita.tolan@autoworld.ro	status_changed	Invoice #5457633052 status changed from "new" to "processed"	invoice	120	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:03:04.514939
721	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 120	invoice	120	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:03:04.537426
722	9	luminita.tolan@autoworld.ro	status_changed	Invoice #VGSR 3443 status changed from "new" to "processed"	invoice	103	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:13:28.815475
723	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 103	invoice	103	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:13:28.84624
724	9	luminita.tolan@autoworld.ro	status_changed	Invoice #VGSR 3457 status changed from "new" to "processed"	invoice	102	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:15:15.003992
725	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 102	invoice	102	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:15:15.008932
726	9	luminita.tolan@autoworld.ro	status_changed	Invoice #2026/1200219759 status changed from "new" to "processed"	invoice	79	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:15:36.628775
727	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 79	invoice	79	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:15:36.63888
728	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-215-105249506 status changed from "new" to "processed"	invoice	122	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:17:50.409982
729	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 122	invoice	122	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:17:50.414386
730	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105234039 status changed from "new" to "processed"	invoice	96	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:18:22.912647
731	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 96	invoice	96	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:18:22.921815
732	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105191330 status changed from "new" to "processed"	invoice	95	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:18:24.695774
733	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 95	invoice	95	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:18:24.700859
734	9	luminita.tolan@autoworld.ro	status_changed	Invoice #5457877229 status changed from "new" to "processed"	invoice	86	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:18:26.899162
735	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 86	invoice	86	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:18:26.903605
736	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105183180 status changed from "new" to "processed"	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:18:35.429973
737	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 47	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:18:35.43397
740	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105183158 status changed from "new" to "processed"	invoice	45	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:18:41.716052
741	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 45	invoice	45	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:18:41.720534
748	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105183180 status changed from "processed" to "new"	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "new", "old_status": "processed"}	2026-01-14 07:22:02.583626
749	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 47	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:22:02.587989
752	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105183170 status changed from "new" to "eronata"	invoice	46	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "eronata", "old_status": "new"}	2026-01-14 07:23:26.992236
753	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 46	invoice	46	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:23:26.997599
763	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 47	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-14 08:22:10.794596
772	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105183170 status changed from "" to "new"	invoice	46	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "new", "old_status": ""}	2026-01-14 08:26:36.820711
773	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 46	invoice	46	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-14 08:26:36.827229
775	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105149896 status changed from "new" to "processed"	invoice	105	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:32:57.586692
776	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 105	invoice	105	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:32:57.60604
779	12	francisc.farkas@autoworld.ro	status_changed	Invoice #RLOPHA9P 0005 status changed from "new" to "processed"	invoice	62	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:35:34.083361
780	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 62	invoice	62	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:35:34.089461
783	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 107	invoice	107	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:37:32.651717
738	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105183170 status changed from "new" to "processed"	invoice	46	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:18:39.416528
739	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 46	invoice	46	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:18:39.424191
742	9	luminita.tolan@autoworld.ro	status_changed	Invoice #455531737 status changed from "new" to "processed"	invoice	28	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:18:43.97043
743	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 28	invoice	28	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:18:43.974158
744	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105122906 status changed from "new" to "processed"	invoice	23	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:18:48.882218
745	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 23	invoice	23	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:18:48.886471
746	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105183170 status changed from "processed" to "new"	invoice	46	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "new", "old_status": "processed"}	2026-01-14 07:19:47.061932
747	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 46	invoice	46	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:19:47.065811
750	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105183180 status changed from "new" to "eronata"	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "eronata", "old_status": "new"}	2026-01-14 07:22:10.208879
751	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 47	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:22:10.214483
754	9	luminita.tolan@autoworld.ro	status_changed	Invoice #469842557 status changed from "new" to "processed"	invoice	78	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 07:26:25.019521
755	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 78	invoice	78	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 07:26:25.026029
756	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:04:06.119654
757	12	francisc.farkas@autoworld.ro	status_changed	Invoice #CRD-F2520703 status changed from "new" to "processed"	invoice	37	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:07:00.559572
758	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 37	invoice	37	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:07:00.712686
759	12	francisc.farkas@autoworld.ro	status_changed	Invoice #AMD 30733 status changed from "new" to "processed"	invoice	32	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:07:04.370939
760	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 32	invoice	32	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:07:04.375815
761	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105183180 status changed from "eronata" to ""	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "", "old_status": "eronata"}	2026-01-14 08:22:10.61641
762	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 47	invoice	47	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-14 08:22:10.647141
764	3	george.pop@autoworld.ro	status_changed	Invoice #FBADS-416-105183170 status changed from "eronata" to ""	invoice	46	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{"new_status": "", "old_status": "eronata"}	2026-01-14 08:23:55.511758
765	3	george.pop@autoworld.ro	invoice_updated	Updated invoice ID 46	invoice	46	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-14 08:23:55.519687
769	1	sebastian.sabo@autoworld.ro	status_changed	Invoice #FBADS-416-105183180 status changed from "" to "new"	invoice	47	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_status": "new", "old_status": ""}	2026-01-14 08:24:41.570052
770	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 47	invoice	47	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-14 08:24:41.578598
774	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 46	invoice	46	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-14 08:26:36.913085
777	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105149887 status changed from "new" to "processed"	invoice	106	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:35:28.660486
778	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 106	invoice	106	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:35:28.667276
766	3	george.pop@autoworld.ro	allocations_updated	Updated allocations for invoice ID 46	invoice	46	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-14 08:23:55.655431
767	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105149915 status changed from "new" to "processed"	invoice	104	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:24:05.026403
768	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 104	invoice	104	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:24:05.031403
771	1	sebastian.sabo@autoworld.ro	allocations_updated	Updated allocations for invoice ID 47	invoice	47	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-14 08:24:41.669588
784	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105144541 status changed from "new" to "processed"	invoice	108	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:53:29.018483
785	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 108	invoice	108	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:53:29.023741
786	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105144540 status changed from "new" to "processed"	invoice	109	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:55:09.974116
787	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 109	invoice	109	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:55:09.99253
788	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105142071 status changed from "new" to "processed"	invoice	110	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:56:48.683836
789	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 110	invoice	110	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:56:48.690512
790	12	francisc.farkas@autoworld.ro	status_changed	Invoice #454249619 status changed from "new" to "processed"	invoice	24	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:11:36.248314
791	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 24	invoice	24	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:11:36.260375
792	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105142070 status changed from "new" to "processed"	invoice	111	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:19:21.944001
793	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 111	invoice	111	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:19:21.95769
808	4	amanda.gavril@autoworld.ro	login	User amanda.gavril@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:38:36.672458
810	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-271-105149910 payment status changed from "not_paid" to "paid"	invoice	136	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-14 09:40:39.827332
811	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 136	invoice	136	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:40:39.832599
812	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 136	invoice	136	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:40:51.673111
781	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105144542 status changed from "new" to "processed"	invoice	107	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 08:37:24.9984
782	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 107	invoice	107	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 08:37:25.004404
800	13	mia.pop@autoworld.ro	status_changed	Invoice #5456072388 status changed from "new" to "processed"	invoice	118	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:25:06.749534
801	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 118	invoice	118	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:25:06.756103
804	12	francisc.farkas@autoworld.ro	status_changed	Invoice #2943F109-0009 status changed from "new" to "processed"	invoice	69	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:34:12.665909
805	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 69	invoice	69	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:34:12.69368
806	13	mia.pop@autoworld.ro	status_changed	Invoice #5457901727 status changed from "new" to "processed"	invoice	119	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:35:23.522188
807	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 119	invoice	119	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:35:23.549206
794	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105142069 status changed from "new" to "processed"	invoice	112	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:21:15.01322
795	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 112	invoice	112	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:21:15.048549
796	12	francisc.farkas@autoworld.ro	status_changed	Invoice #RLOPHA9P 0006 status changed from "new" to "processed"	invoice	63	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:21:47.8402
797	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 63	invoice	63	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:21:47.844831
798	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-733-105205142 status changed from "new" to "processed"	invoice	117	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:23:31.613931
799	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 117	invoice	117	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:23:31.619198
802	12	francisc.farkas@autoworld.ro	status_changed	Invoice #L8ASBX7X-0002 status changed from "new" to "processed"	invoice	61	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:26:57.261956
803	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 61	invoice	61	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:26:57.266839
809	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-271-105149910 from Meta Platforms Ireland Limited	invoice	136	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:40:13.780652
813	4	amanda.gavril@autoworld.ro	allocations_updated	Updated allocations for invoice ID 136	invoice	136	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:40:51.845067
814	13	mia.pop@autoworld.ro	status_changed	Invoice #FBADS-271-105149910 status changed from "new" to "processed"	invoice	136	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 09:44:55.248201
815	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 136	invoice	136	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:44:55.264623
816	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice CRD-F2600193 from CRUSH DISTRIBUTION SRL	invoice	138	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:56:17.383118
817	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice CPY nr. 15683 from MERAKI SOLUTIONS SRL	invoice	139	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 09:58:20.360075
818	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 10:00:09.999273
819	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #CRD-F2521773 status changed from "new" to "processed"	invoice	135	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 10:13:58.083071
820	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 135	invoice	135	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 10:13:58.153457
824	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:13:54.046274
821	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #CRD-F2519988 status changed from "new" to "processed"	invoice	83	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 10:14:35.154045
822	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 83	invoice	83	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 10:14:35.175415
823	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice R045-4115012258 from Polus Transilvania Companie de Investitii S.A.	invoice	140	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 10:47:37.033589
825	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:15:05.585296
826	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:15:54.059731
827	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #FBADS-528-105315964 status changed from "new" to "processed"	invoice	97	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 12:17:06.687261
828	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 97	invoice	97	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:17:06.713837
829	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #5456946208 status changed from "new" to "processed"	invoice	76	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 12:17:29.079943
830	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 76	invoice	76	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:17:29.084201
831	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #MC22270407 status changed from "new" to "processed"	invoice	68	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 12:17:50.885964
832	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 68	invoice	68	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:17:50.890824
833	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:26:48.751006
834	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #FBADS-528-105219425 status changed from "new" to "processed"	invoice	67	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 12:27:15.805101
835	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 67	invoice	67	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:27:15.813886
836	13	mia.pop@autoworld.ro	status_changed	Invoice #5456946208 status changed from "processed" to "eronata"	invoice	76	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "eronata", "old_status": "processed"}	2026-01-14 12:45:16.957866
837	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 76	invoice	76	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:45:16.970869
838	13	mia.pop@autoworld.ro	status_changed	Invoice #MC22270407 status changed from "processed" to "eronata"	invoice	68	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "eronata", "old_status": "processed"}	2026-01-14 12:45:19.989364
839	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 68	invoice	68	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:45:19.994583
840	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 088000662705 from Hetzner Online GmbH	invoice	141	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-14 12:48:05.986163
841	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 68	invoice	68	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 12:50:40.233106
842	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #088000662705 payment status changed from "not_paid" to "paid"	invoice	141	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-14 12:54:20.622701
843	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 141	invoice	141	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-14 12:54:20.643722
844	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #5459181905 payment status changed from "not_paid" to "paid"	invoice	98	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-14 12:54:49.847767
845	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 98	invoice	98	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-14 12:54:49.853863
846	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 086000539734 from Hetzner Online GmbH	invoice	142	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-14 12:57:57.296044
847	6	raluca.asztalos@autoworld.ro	status_changed	Invoice #5456946208 status changed from "eronata" to ""	invoice	76	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "", "old_status": "eronata"}	2026-01-14 13:04:21.709366
848	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 76	invoice	76	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 13:04:21.723607
849	6	raluca.asztalos@autoworld.ro	allocations_updated	Updated allocations for invoice ID 76	invoice	76	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 13:04:21.832557
850	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 5461397540 from Google Cloud EMEA Limited	invoice	143	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-14 13:04:35.258232
851	13	mia.pop@autoworld.ro	status_changed	Invoice #MC22270407 status changed from "eronata" to "processed"	invoice	68	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "eronata"}	2026-01-14 13:07:29.916405
852	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 68	invoice	68	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 13:07:29.951518
853	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 13:07:54.144335
854	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #5456946208 status changed from "" to "processed"	invoice	76	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": ""}	2026-01-14 13:08:59.943788
855	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 76	invoice	76	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 13:08:59.948431
856	\N	\N	login_failed	Failed login attempt for sebastian.sabo@autoworld.ro	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-14 13:23:23.690563
857	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-167-104809153 from Meta Platforms Ireland Limited	invoice	144	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-14 13:25:13.222228
858	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #5461397540 payment status changed from "not_paid" to "paid"	invoice	143	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-14 13:30:37.759079
859	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 143	invoice	143	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-14 13:30:37.764436
860	7	alina.amironoaei@autoworld.ro	login	User alina.amironoaei@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 13:31:18.595453
861	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice FBADS-528-105202071 from Meta Platforms Ireland Limited	invoice	145	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:25:03.526835
862	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice FBADS-528-105202072 from Meta Platforms Ireland Limited	invoice	146	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:25:29.906357
863	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice FBADS-528-105205218 from Meta Platforms Ireland Limited	invoice	147	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:25:57.165579
864	12	francisc.farkas@autoworld.ro	status_changed	Invoice #088000662705 status changed from "new" to "processed"	invoice	141	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 14:26:00.728889
865	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 141	invoice	141	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:26:00.736367
866	12	francisc.farkas@autoworld.ro	status_changed	Invoice #086000539734 status changed from "new" to "processed"	invoice	142	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 14:26:02.975542
867	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 142	invoice	142	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:26:02.980855
868	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice FBADS-528-105206037 from Meta Platforms Ireland Limited	invoice	148	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:27:23.255052
869	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice RACE0001 from RACEPOINT CAFE S.R.L.	invoice	149	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:27:58.00997
870	6	raluca.asztalos@autoworld.ro	payment_status_changed	Invoice #FBADS-528-105206037 payment status changed from "not_paid" to "paid"	invoice	148	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-14 14:28:30.053965
871	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 148	invoice	148	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:28:30.061892
872	6	raluca.asztalos@autoworld.ro	payment_status_changed	Invoice #FBADS-528-105205218 payment status changed from "not_paid" to "paid"	invoice	147	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-14 14:28:31.356112
873	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 147	invoice	147	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:28:31.36278
874	6	raluca.asztalos@autoworld.ro	payment_status_changed	Invoice #FBADS-528-105202072 payment status changed from "not_paid" to "paid"	invoice	146	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-14 14:28:32.541165
875	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 146	invoice	146	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:28:32.564703
876	6	raluca.asztalos@autoworld.ro	payment_status_changed	Invoice #FBADS-528-105202071 payment status changed from "not_paid" to "paid"	invoice	145	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-14 14:28:35.070668
877	6	raluca.asztalos@autoworld.ro	invoice_updated	Updated invoice ID 145	invoice	145	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:28:35.081073
878	12	francisc.farkas@autoworld.ro	status_changed	Invoice #5461397540 status changed from "new" to "processed"	invoice	143	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 14:31:49.076885
879	12	francisc.farkas@autoworld.ro	invoice_updated	Updated invoice ID 143	invoice	143	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:31:49.085175
880	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice 5459006386 from Google Ireland Limited	invoice	150	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 14:35:27.767869
881	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 15:03:50.454927
882	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #FBADS-528-105206037 status changed from "new" to "processed"	invoice	148	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 15:17:52.765343
883	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 148	invoice	148	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 15:17:52.787132
884	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #FBADS-528-105205218 status changed from "new" to "processed"	invoice	147	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 15:19:45.760378
885	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 147	invoice	147	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 15:19:45.765935
886	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 15:20:01.944976
887	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #FBADS-528-105202072 status changed from "new" to "processed"	invoice	146	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 15:22:50.917919
888	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 146	invoice	146	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 15:22:50.928917
889	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #FBADS-528-105202071 status changed from "new" to "processed"	invoice	145	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-14 15:23:08.880604
890	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 145	invoice	145	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 15:23:08.88856
891	13	mia.pop@autoworld.ro	status_changed	Invoice #2026/1200225655 status changed from "new" to "eronata"	invoice	80	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "eronata", "old_status": "new"}	2026-01-14 15:24:59.483634
892	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 80	invoice	80	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 15:24:59.492107
893	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-14 15:29:35.204268
894	9	luminita.tolan@autoworld.ro	login	User luminita.tolan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 06:15:55.683358
895	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 06:18:46.564966
896	9	luminita.tolan@autoworld.ro	status_changed	Invoice #FBADS-416-105183180 status changed from "new" to "eronata"	invoice	47	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "eronata", "old_status": "new"}	2026-01-15 06:19:06.804073
897	9	luminita.tolan@autoworld.ro	invoice_updated	Updated invoice ID 47	invoice	47	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 06:19:06.811981
898	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice 5433853933 from Google Ireland Limited	invoice	151	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 07:10:07.114031
899	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 07:12:39.333897
900	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #5433853933 status changed from "new" to "processed"	invoice	151	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-15 07:13:18.013937
901	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 151	invoice	151	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 07:13:18.019907
902	5	gabriel.suciu@autoworld.ro	invoice_created	Created invoice 2026/1200233589 from OLX Online Services SRL	invoice	152	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-15 07:54:09.082723
903	4	amanda.gavril@autoworld.ro	invoice_created	Created invoice FBADS-215-105273987 from Meta Platforms Ireland Limited	invoice	153	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 08:34:31.188803
904	4	amanda.gavril@autoworld.ro	payment_status_changed	Invoice #FBADS-215-105273987 payment status changed from "not_paid" to "paid"	invoice	153	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 08:34:40.771773
905	4	amanda.gavril@autoworld.ro	invoice_updated	Updated invoice ID 153	invoice	153	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 08:34:40.786621
906	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 08:50:24.9452
907	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 08:55:49.569613
908	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FI80176620325 from Fiverr International Ltd.	invoice	154	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 10:21:27.823188
909	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 5326102266 from Google Cloud EMEA Limited	invoice	155	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 10:34:57.352662
910	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #5326102266 payment status changed from "not_paid" to "paid"	invoice	155	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 10:45:44.602459
911	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 155	invoice	155	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 10:45:44.642392
912	7	alina.amironoaei@autoworld.ro	invoice_created	Created invoice 474248795 from Shopify International Limited	invoice	156	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:05:09.404359
913	7	alina.amironoaei@autoworld.ro	invoice_created	Created invoice 468557001 from Shopify International Limited	invoice	157	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:08:23.441962
914	7	alina.amironoaei@autoworld.ro	invoice_created	Created invoice FBADS-125-105296286 from Meta Platforms Ireland Limited	invoice	158	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:18:05.078866
915	7	alina.amironoaei@autoworld.ro	invoice_created	Created invoice FBADS-125-105315570 from Meta Platforms Ireland Limited	invoice	159	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:18:29.382009
916	7	alina.amironoaei@autoworld.ro	invoice_created	Created invoice FBADS-125-105277202 from Meta Platforms Ireland Limited	invoice	160	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:18:44.710666
917	7	alina.amironoaei@autoworld.ro	invoice_created	Created invoice FBADS-125-105271839 from Meta Platforms Ireland Limited	invoice	161	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:19:00.718
918	7	alina.amironoaei@autoworld.ro	payment_status_changed	Invoice #FBADS-125-105271839 payment status changed from "not_paid" to "paid"	invoice	161	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 11:19:43.973125
919	7	alina.amironoaei@autoworld.ro	invoice_updated	Updated invoice ID 161	invoice	161	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:19:43.97785
920	7	alina.amironoaei@autoworld.ro	payment_status_changed	Invoice #FBADS-125-105277202 payment status changed from "not_paid" to "paid"	invoice	160	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 11:19:45.123518
921	7	alina.amironoaei@autoworld.ro	invoice_updated	Updated invoice ID 160	invoice	160	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:19:45.132535
922	7	alina.amironoaei@autoworld.ro	payment_status_changed	Invoice #FBADS-125-105315570 payment status changed from "not_paid" to "paid"	invoice	159	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 11:19:46.008986
923	7	alina.amironoaei@autoworld.ro	invoice_updated	Updated invoice ID 159	invoice	159	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:19:46.01416
924	7	alina.amironoaei@autoworld.ro	payment_status_changed	Invoice #FBADS-125-105296286 payment status changed from "not_paid" to "paid"	invoice	158	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 11:19:46.996132
925	7	alina.amironoaei@autoworld.ro	invoice_updated	Updated invoice ID 158	invoice	158	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:19:47.002837
926	7	alina.amironoaei@autoworld.ro	status_changed	Invoice #FBADS-125-105271839 status changed from "new" to "incomplete"	invoice	161	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "incomplete", "old_status": "new"}	2026-01-15 11:19:48.8303
927	7	alina.amironoaei@autoworld.ro	invoice_updated	Updated invoice ID 161	invoice	161	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:19:48.835809
928	7	alina.amironoaei@autoworld.ro	status_changed	Invoice #FBADS-125-105277202 status changed from "new" to "incomplete"	invoice	160	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "incomplete", "old_status": "new"}	2026-01-15 11:19:49.999929
929	7	alina.amironoaei@autoworld.ro	invoice_updated	Updated invoice ID 160	invoice	160	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:19:50.012907
930	7	alina.amironoaei@autoworld.ro	status_changed	Invoice #FBADS-125-105315570 status changed from "new" to "incomplete"	invoice	159	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "incomplete", "old_status": "new"}	2026-01-15 11:19:51.014257
931	7	alina.amironoaei@autoworld.ro	invoice_updated	Updated invoice ID 159	invoice	159	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:19:51.020267
932	7	alina.amironoaei@autoworld.ro	status_changed	Invoice #FBADS-125-105296286 status changed from "new" to "incomplete"	invoice	158	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "incomplete", "old_status": "new"}	2026-01-15 11:19:52.122295
933	7	alina.amironoaei@autoworld.ro	invoice_updated	Updated invoice ID 158	invoice	158	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 11:19:52.130852
934	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice L8ASBX7X-0003 from OpenAI Ireland Limited	invoice	162	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 11:35:58.169287
935	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice RIICX51Z-0003 from OpenAI Ireland Limited	invoice	163	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 11:53:26.774108
936	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice RIICX51Z-0004 from OpenAI Ireland Limited	invoice	164	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 11:55:02.093584
937	13	mia.pop@autoworld.ro	status_changed	Invoice #2026/1200226916 status changed from "new" to "processed"	invoice	82	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-15 12:04:03.858272
938	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 82	invoice	82	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 12:04:03.903414
939	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 5355399164 from Google Cloud EMEA Limited	invoice	165	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 12:24:40.067191
940	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice KXNTXJYM-0002 from Cursor	invoice	166	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 12:28:55.708267
941	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #KXNTXJYM-0002 payment status changed from "not_paid" to "paid"	invoice	166	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 12:47:03.284248
942	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 166	invoice	166	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 12:47:03.307936
943	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #5355399164 payment status changed from "not_paid" to "paid"	invoice	165	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 12:47:05.377991
944	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 165	invoice	165	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 12:47:05.387627
945	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #RIICX51Z-0004 payment status changed from "not_paid" to "paid"	invoice	164	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 12:47:06.928496
946	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 164	invoice	164	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 12:47:06.933752
947	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #RIICX51Z-0003 payment status changed from "not_paid" to "paid"	invoice	163	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 12:47:08.840866
948	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 163	invoice	163	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 12:47:08.845774
949	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #L8ASBX7X-0003 payment status changed from "not_paid" to "paid"	invoice	162	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 12:47:10.87849
950	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 162	invoice	162	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 12:47:10.883307
951	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #468557001 payment status changed from "not_paid" to "paid"	invoice	157	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-15 12:47:15.771315
952	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 157	invoice	157	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 12:47:15.777694
953	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 74340440-148373552 from Alaio Inc.	invoice	167	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 15:13:35.65883
954	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice #74340440-145890370 from Alaio Inc.	invoice	168	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 15:14:30.253808
955	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 15:16:26.607817
956	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-15 15:16:47.226631
957	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice RLQPHA9P-0005 from Anthropic, PBC	invoice	169	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 15:28:31.996555
958	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice RLOPHA9P-0006 from Anthropic, PBC	invoice	170	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 15:28:59.089849
959	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice RLOPHA9P-0007 from Anthropic, PBC	invoice	171	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 15:29:29.040121
960	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice RLOPHA9P-0003 from Anthropic, PBC	invoice	172	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 15:31:27.968101
961	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 371-536-126-069 from X AI LLC	invoice	173	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-15 15:36:03.263437
962	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 06:15:53.996996
963	13	mia.pop@autoworld.ro	login	User mia.pop@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 06:22:05.089517
964	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 06:26:30.49949
965	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #20251511 status changed from "new" to "processed"	invoice	59	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 06:41:09.805307
966	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 59	invoice	59	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 06:41:09.812656
967	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #SBIE-10163068 status changed from "new" to "processed"	invoice	25	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 06:43:05.697874
968	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 25	invoice	25	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 06:43:05.723884
969	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #29699 status changed from "new" to "processed"	invoice	35	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:00:00.935614
970	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 35	invoice	35	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:00:01.017982
971	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #560 status changed from "new" to "processed"	invoice	66	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:03:26.144613
972	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 66	invoice	66	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:03:26.168094
973	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #RNEP nr: 2025002880 status changed from "new" to "processed"	invoice	70	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:04:30.090914
974	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 70	invoice	70	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:04:30.131878
975	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #RNEP nr: 2025003243 status changed from "new" to "processed"	invoice	71	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:04:36.176649
976	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 71	invoice	71	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:04:36.181281
977	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #R045-4115012258 status changed from "new" to "processed"	invoice	140	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:06:39.985984
978	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 140	invoice	140	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:06:40.002617
979	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #FI80176620325 status changed from "new" to "processed"	invoice	154	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:07:30.28706
980	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 154	invoice	154	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:07:30.294085
981	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #5326102266 status changed from "new" to "processed"	invoice	155	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:08:18.793819
982	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 155	invoice	155	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:08:18.807821
983	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #RIICX51Z-0004 status changed from "new" to "processed"	invoice	164	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:09:51.33032
984	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 164	invoice	164	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:09:51.345431
985	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #RIICX51Z-0003 status changed from "new" to "processed"	invoice	163	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:09:52.90985
986	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 163	invoice	163	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:09:52.917243
987	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #KXNTXJYM-0002 status changed from "new" to "processed"	invoice	166	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:44:39.809036
988	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 166	invoice	166	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:44:39.829111
993	4	amanda.gavril@autoworld.ro	login	User amanda.gavril@autoworld.ro logged in	\N	\N	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 08:11:24.2344
989	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #5355399164 status changed from "new" to "processed"	invoice	165	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:44:52.565706
990	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 165	invoice	165	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:44:52.571222
991	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #371-536-126-069 status changed from "new" to "processed"	invoice	173	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 07:50:37.70176
992	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 173	invoice	173	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 07:50:37.719761
994	3	george.pop@autoworld.ro	invoice_created	Created invoice 452751407 from Shopify International Limited	invoice	174	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	{}	2026-01-16 08:15:27.06535
995	13	mia.pop@autoworld.ro	status_changed	Invoice #452751407 status changed from "new" to "processed"	invoice	174	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 08:40:18.835966
996	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 174	invoice	174	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 08:40:18.890193
997	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #FBADS-167-104809153 status changed from "new" to "processed"	invoice	144	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 10:33:03.209169
998	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 144	invoice	144	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 10:33:03.26498
999	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #74340440-148373552 status changed from "new" to "processed"	invoice	167	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 10:33:20.380279
1000	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 167	invoice	167	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 10:33:20.385524
1001	14	gabriela.muresan@autoworld.ro	status_changed	Invoice ##74340440-145890370 status changed from "new" to "processed"	invoice	168	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 10:33:21.783417
1002	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 168	invoice	168	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 10:33:21.793359
1003	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #RLQPHA9P-0005 status changed from "new" to "processed"	invoice	169	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 10:33:32.326661
1004	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 169	invoice	169	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 10:33:32.332043
1005	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #RLOPHA9P-0006 status changed from "new" to "processed"	invoice	170	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 10:33:34.071925
1006	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 170	invoice	170	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 10:33:34.077644
1007	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #RLOPHA9P-0003 status changed from "new" to "processed"	invoice	172	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 10:33:40.445774
1008	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 172	invoice	172	10.244.25.120	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 10:33:40.450833
1009	13	mia.pop@autoworld.ro	status_changed	Invoice #EFE-P202512166 status changed from "new" to "eronata"	invoice	27	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "eronata", "old_status": "new"}	2026-01-16 10:36:19.119828
1010	13	mia.pop@autoworld.ro	invoice_updated	Updated invoice ID 27	invoice	27	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 10:36:19.126468
1011	1	sebastian.sabo@autoworld.ro	login	User sebastian.sabo@autoworld.ro logged in	\N	\N	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-16 14:07:46.196887
1012	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice FBADS-167-104773906 from Meta Platforms Ireland Limited	invoice	175	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-16 14:28:13.921693
1013	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #FBADS-167-104773906 payment status changed from "not_paid" to "paid"	invoice	175	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-16 14:35:54.259997
1014	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 175	invoice	175	10.244.23.224	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-16 14:35:54.308595
1015	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #RLOPHA9P-0003 payment status changed from "not_paid" to "paid"	invoice	172	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-16 14:35:57.651495
1016	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 172	invoice	172	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-16 14:35:57.655605
1017	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #RLOPHA9P-0007 payment status changed from "not_paid" to "paid"	invoice	171	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-16 14:36:00.267731
1018	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 171	invoice	171	10.244.31.82	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-16 14:36:00.275678
1021	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #RLQPHA9P-0005 payment status changed from "not_paid" to "paid"	invoice	169	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-16 14:36:03.066881
1022	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 169	invoice	169	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-16 14:36:03.072617
1030	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.31.82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 15:05:55.712838
1019	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #RLOPHA9P-0006 payment status changed from "not_paid" to "paid"	invoice	170	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-16 14:36:01.385935
1020	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 170	invoice	170	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-16 14:36:01.392001
1023	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice ##74340440-145890370 payment status changed from "not_paid" to "paid"	invoice	168	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-16 14:36:08.578961
1024	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 168	invoice	168	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-16 14:36:08.585133
1025	1	sebastian.sabo@autoworld.ro	payment_status_changed	Invoice #74340440-148373552 payment status changed from "not_paid" to "paid"	invoice	167	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{"new_payment_status": "paid", "old_payment_status": "not_paid"}	2026-01-16 14:36:10.228526
1026	1	sebastian.sabo@autoworld.ro	invoice_updated	Updated invoice ID 167	invoice	167	10.244.25.120	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-16 14:36:10.233744
1027	14	gabriela.muresan@autoworld.ro	login	User gabriela.muresan@autoworld.ro logged in	\N	\N	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 14:57:47.635673
1028	14	gabriela.muresan@autoworld.ro	status_changed	Invoice #FBADS-167-104773906 status changed from "new" to "processed"	invoice	175	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{"new_status": "processed", "old_status": "new"}	2026-01-16 14:59:34.505867
1029	14	gabriela.muresan@autoworld.ro	invoice_updated	Updated invoice ID 175	invoice	175	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	{}	2026-01-16 14:59:34.537156
1031	1	sebastian.sabo@autoworld.ro	invoice_created	Created invoice 76205845-151955781 from Alaio Cloud Limited	invoice	176	10.244.25.245	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15	{}	2026-01-19 12:46:38.088402
1032	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice 30067 from ASTINVEST COM SRL	invoice	177	10.244.25.245	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0	{}	2026-01-19 13:28:16.34143
1033	6	raluca.asztalos@autoworld.ro	invoice_created	Created invoice 30068 from ASTINVEST COM SRL	invoice	178	10.244.23.224	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0	{}	2026-01-19 13:29:13.299635
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.users (id, name, email, phone, is_active, can_add_invoices, can_delete_invoices, can_view_invoices, can_access_accounting, can_access_settings, can_access_connectors, created_at, updated_at, role_id, password_hash, last_login, last_seen) FROM stdin;
8	Alina Juhas	alina.juhasz@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:36:48.496094	2026-01-12 08:25:56.346986	2	scrypt:32768:8:1$EhEH4RRL1bnTSMnl$c95977e45194d798190822cf7d7a88eeb6a331cdd420b8cfc082072ee87e7331a6fd9af9882aeea5fc8217bf532c894bda56c34b563fc042d718366a94cc609e	2026-01-12 10:19:31.31135	\N
1	Sebastian Sabo	sebastian.sabo@autoworld.ro	+40721123456	t	t	f	t	t	t	f	2025-12-10 11:51:24.075108	2025-12-10 12:52:43.313401	1	scrypt:32768:8:1$Ld9huP7oAQUzxCvf$0eb1f695ab15b06c2e8f75c98d985f99341e4610f01085f21dd57edf898e53c246edeb5e54b6bac6eb71c21411f58cdd05a44b543edf7e4b3af281a9faa8e2d8	2026-01-16 14:07:46.191504	2026-01-19 12:43:43.954879
16	Catalin Tusenan	catalin.tusinean@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:44:54.24536	2025-12-18 14:58:25.255619	2	scrypt:32768:8:1$lDdrEpTGB2ldJ5yF$6b431b82b6b3ee4cd5672eca9fc6e11935961858516d6841a91f8877e6e157fed0ce6de0e43bac7b4b5a31460cb6cc8a47af143d188ccb32b1a450d6cead6e98	\N	\N
4	Amanda Gavril	amanda.gavril@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-10 14:02:36.698234	2025-12-18 14:58:21.192485	2	scrypt:32768:8:1$YJy8p3R25PHCHW03$e346499ac8a88d78ab751ac3cd5ca918111911858ba12486d0e3e3aab615e2078bf9502663f7f83a79f6fae495ef4243934b33b5d78c925c5bb06d10808bc318	2026-01-16 08:11:24.218849	2026-01-16 08:12:41.674444
9	Luminita Tolan	luminita.tolan@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:37:47.211832	2025-12-18 14:50:53.880612	2	scrypt:32768:8:1$as8C2u6uvPTAc9Gh$ebcdd1149a126264d6d25f66b4f94682a4629af8b325a470b2b96c328bec1247b248839969ebbb49aeeaca43597bb850e9d722e5ba5056a068e823172bb8fe4b	2026-01-15 06:15:55.641275	\N
5	Gabriel Suciu	gabriel.suciu@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-10 14:03:56.770006	2025-12-18 14:58:42.177306	2	scrypt:32768:8:1$Hokoi4l8WC4FJUab$2ccd9b948273fe5ba47b99296808782cc1ff16a70ef9b87290ac024009667d8c24b6afca536885b51d78254c9769200e2056a497d1985a3bdccc5dcc2d43ee24	2025-12-18 13:49:41.61815	2026-01-16 11:30:31.819621
13	Mia Pop	mia.pop@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:41:13.85031	2025-12-18 14:35:01.015712	2	scrypt:32768:8:1$s3KJbwRMWF4Vvo5l$1ea5e545162d0872f9f0ee8af50cc6585aa5157fb297559a21c9ef233687b3821b408603b7e089fdaf04073e4bec2da00f76843b0538982dca6b99cb6e46b21e	2026-01-16 06:22:05.084903	2026-01-16 14:05:11.51693
3	Gerorge Pop	george.pop@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-10 14:00:50.812338	2025-12-18 14:51:03.48626	2	scrypt:32768:8:1$rnrX5JUHJJuL1cIR$218c17c10800b68ac4edac6fc7c463f8b730d7893ab5333edb2ac95404025902d54bd9909bb62e6a6e656351eb6df5ebc9a1f9f506534f944a379ce811a4c40b	2025-12-18 14:47:53.6766	2026-01-16 08:13:12.551745
7	Alina Amironoaei	alina.amironoaei@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-10 14:06:31.230337	2025-12-18 14:58:37.341724	2	scrypt:32768:8:1$tKZ3UnqbslSJFk3a$cb338f2e29e698a9bbd7904266f7bead3e9d1868071b26c8b47017cea40e437f608d9f6512e45666a8320a81b82e006c07f404cd4e88206476a76c368e7cab50	2026-01-14 13:31:18.586247	2026-01-15 13:18:40.747063
17	Ilona Foszto	ilona.foszto@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:47:57.593391	2025-12-18 14:58:47.046611	2	scrypt:32768:8:1$Htwe85vosm9y0hYW$c0b9566b19aed4d1fd5ceed5199f508ceb134f6c803753c0df1f77f688c6fcb38cde244bbadcf66c1616cd5e5fdca6e650a3c9c1b7529ed387aa92472aaa7578	\N	\N
2	Seba	sebastian.sabo@gmail.com	0728889183	t	t	f	t	t	f	f	2025-12-10 12:05:27.337126	2025-12-15 10:47:51.858552	4	scrypt:32768:8:1$an13ek9nLGapFgYZ$b3c85dfc68edd2ec979da64b04e983a0e3541b3924f6712aa54c571c9ce8ccd26a451adce0509b410ee5a6d79d9fcd0bd907148f8e222186d0c7a3bc059aefad	\N	\N
6	Raluca Asztalos	raluca.asztalos@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-10 14:04:37.857385	2025-12-18 14:53:58.718989	2	scrypt:32768:8:1$92EuszJUIomyp2PU$5551941d71adc50db23262edab86d709eb31b9d068e7f837a56992bf3cfe8d2c1ba2b59b63f67a3ac9a4dd3aafec954178fdb99ed9e44e6b1ef874db43cffa16	2026-01-08 07:22:59.907573	2026-01-19 13:27:06.588443
11	Claudia Bruslea	claudia.bruslea@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:39:07.86644	2025-12-18 14:52:25.574655	2	scrypt:32768:8:1$y6ZWtTZ9kvAf2Qf3$c37b45455af638693f1147a7010ccabe9e19adc3c525ac88ece7c3b096f931055a18a76a77f464256861f881455903130872a1e39686fd8a7e8eb5c07f46c85f	\N	\N
15	Gabriela Oltean	gabriela.oltean@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:43:58.309921	2025-12-18 14:52:43.041456	2	scrypt:32768:8:1$s1I3kx3arjWEOL6g$1280b02cf295c8bb68e144a6607f0ad41e1a0a6a0a7ba4e32426108838da374a213d0bdd689f8365154145107f1150b5fdd3633bb58de39aa36f99bc54ca532f	\N	\N
14	Gabriela Muresan	gabriela.muresan@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:43:32.493104	2025-12-18 14:52:36.230982	2	scrypt:32768:8:1$vnoZz7IxNPZ0OcBD$d93536e9b428958dbbb1a624c498d15153e36ce01cba4b12b3ebc25375c3e8299725183596110cf748bba4a642ab9e8505baae7340cea1a81604bea5998a3c09	2026-01-16 15:05:55.706823	2026-01-16 15:09:57.980964
12	Francisc Farkas	francisc.farkas@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:39:33.865149	2026-01-12 09:02:01.046644	2	scrypt:32768:8:1$Fon1MGAkEI5gf2rl$ebe6e7aae25d5de3303dc283dca1a14cd44af9bfc632680f075f916f3b18835f496aa01506c17e8cdddeaf710f0f81c4d5de9a0cbbcfa95bc57e0c17a824a1e5	2026-01-12 09:10:53.677608	2026-01-19 14:16:18.125825
10	Liana Voivod	liana.voivod@autoworld.ro	\N	t	t	f	t	t	f	f	2025-12-11 12:38:13.617481	2025-12-18 14:58:51.509428	2	scrypt:32768:8:1$yHcIsphrQs7LPs2U$0eaceef5b3b69f1a98b54e2a40761f0f6b950249a40c1a46a12d7dad8060020f48d9ca3a855c3af51a9f75506a5438685d3e5be7b3e3d6c30378543ef1ff9def	\N	\N
\.


--
-- Data for Name: vat_rates; Type: TABLE DATA; Schema: public; Owner: doadmin
--

COPY public.vat_rates (id, name, rate, is_default, is_active, created_at) FROM stdin;
1	21%	21	t	t	2025-12-16 09:05:12.80191
2	11%	11	f	t	2025-12-16 09:05:12.80191
\.


--
-- Name: allocations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.allocations_id_seq', 556, true);


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.companies_id_seq', 16, true);


--
-- Name: connector_sync_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.connector_sync_log_id_seq', 1, false);


--
-- Name: connectors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.connectors_id_seq', 1, false);


--
-- Name: department_structure_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.department_structure_id_seq', 60, true);


--
-- Name: invoice_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.invoice_templates_id_seq', 14, true);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.invoices_id_seq', 178, true);


--
-- Name: notification_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.notification_log_id_seq', 146, true);


--
-- Name: notification_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.notification_settings_id_seq', 86, true);


--
-- Name: reinvoice_destinations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.reinvoice_destinations_id_seq', 107, true);


--
-- Name: responsables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.responsables_id_seq', 30, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.roles_id_seq', 1176, true);


--
-- Name: user_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.user_events_id_seq', 1033, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.users_id_seq', 17, true);


--
-- Name: vat_rates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: doadmin
--

SELECT pg_catalog.setval('public.vat_rates_id_seq', 4, true);


--
-- Name: allocations allocations_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.allocations
    ADD CONSTRAINT allocations_pkey PRIMARY KEY (id);


--
-- Name: companies companies_company_key; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_company_key UNIQUE (company);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: connector_sync_log connector_sync_log_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.connector_sync_log
    ADD CONSTRAINT connector_sync_log_pkey PRIMARY KEY (id);


--
-- Name: connectors connectors_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.connectors
    ADD CONSTRAINT connectors_pkey PRIMARY KEY (id);


--
-- Name: department_structure department_structure_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.department_structure
    ADD CONSTRAINT department_structure_pkey PRIMARY KEY (id);


--
-- Name: invoice_templates invoice_templates_name_key; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.invoice_templates
    ADD CONSTRAINT invoice_templates_name_key UNIQUE (name);


--
-- Name: invoice_templates invoice_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.invoice_templates
    ADD CONSTRAINT invoice_templates_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: notification_log notification_log_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_pkey PRIMARY KEY (id);


--
-- Name: notification_settings notification_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_pkey PRIMARY KEY (id);


--
-- Name: notification_settings notification_settings_setting_key_key; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_setting_key_key UNIQUE (setting_key);


--
-- Name: reinvoice_destinations reinvoice_destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.reinvoice_destinations
    ADD CONSTRAINT reinvoice_destinations_pkey PRIMARY KEY (id);


--
-- Name: responsables responsables_email_key; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.responsables
    ADD CONSTRAINT responsables_email_key UNIQUE (email);


--
-- Name: responsables responsables_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.responsables
    ADD CONSTRAINT responsables_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: user_events user_events_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vat_rates vat_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.vat_rates
    ADD CONSTRAINT vat_rates_pkey PRIMARY KEY (id);


--
-- Name: idx_allocations_brand; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_allocations_brand ON public.allocations USING btree (brand);


--
-- Name: idx_allocations_company; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_allocations_company ON public.allocations USING btree (company);


--
-- Name: idx_allocations_department; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_allocations_department ON public.allocations USING btree (department);


--
-- Name: idx_allocations_invoice_id; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_allocations_invoice_id ON public.allocations USING btree (invoice_id);


--
-- Name: idx_dept_structure_company; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_dept_structure_company ON public.department_structure USING btree (company);


--
-- Name: idx_dept_structure_dept; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_dept_structure_dept ON public.department_structure USING btree (department);


--
-- Name: idx_invoices_created_at; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_invoices_created_at ON public.invoices USING btree (created_at DESC);


--
-- Name: idx_invoices_date; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_invoices_date ON public.invoices USING btree (invoice_date);


--
-- Name: idx_invoices_date_desc; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_invoices_date_desc ON public.invoices USING btree (invoice_date DESC);


--
-- Name: idx_invoices_deleted_at; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_invoices_deleted_at ON public.invoices USING btree (deleted_at);


--
-- Name: idx_invoices_deleted_date; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_invoices_deleted_date ON public.invoices USING btree (deleted_at, invoice_date DESC);


--
-- Name: idx_invoices_status; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_invoices_status ON public.invoices USING btree (status);


--
-- Name: idx_invoices_supplier; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_invoices_supplier ON public.invoices USING btree (supplier);


--
-- Name: idx_reinvoice_dest_allocation; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_reinvoice_dest_allocation ON public.reinvoice_destinations USING btree (allocation_id);


--
-- Name: idx_user_events_created_at; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_user_events_created_at ON public.user_events USING btree (created_at DESC);


--
-- Name: idx_user_events_event_type; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_user_events_event_type ON public.user_events USING btree (event_type);


--
-- Name: idx_user_events_user_id; Type: INDEX; Schema: public; Owner: doadmin
--

CREATE INDEX idx_user_events_user_id ON public.user_events USING btree (user_id);


--
-- Name: allocations allocations_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.allocations
    ADD CONSTRAINT allocations_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: connector_sync_log connector_sync_log_connector_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.connector_sync_log
    ADD CONSTRAINT connector_sync_log_connector_id_fkey FOREIGN KEY (connector_id) REFERENCES public.connectors(id) ON DELETE CASCADE;


--
-- Name: department_structure department_structure_responsable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.department_structure
    ADD CONSTRAINT department_structure_responsable_id_fkey FOREIGN KEY (responsable_id) REFERENCES public.responsables(id) ON DELETE SET NULL;


--
-- Name: notification_log notification_log_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: notification_log notification_log_responsable_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_responsable_id_fkey FOREIGN KEY (responsable_id) REFERENCES public.responsables(id);


--
-- Name: reinvoice_destinations reinvoice_destinations_allocation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.reinvoice_destinations
    ADD CONSTRAINT reinvoice_destinations_allocation_id_fkey FOREIGN KEY (allocation_id) REFERENCES public.allocations(id) ON DELETE CASCADE;


--
-- Name: user_events user_events_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.user_events
    ADD CONSTRAINT user_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: doadmin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- PostgreSQL database dump complete
--

\unrestrict W64pUbfcXEi6DA1sf8fIVHbVZYIlZyx5tHdxKi7oowUi9geOqkn4uUvTLDsisKX


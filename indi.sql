--
-- PostgreSQL database dump
--

-- Dumped from database version 10.22
-- Dumped by pg_dump version 10.22

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: check_finance(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_finance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Проверить, что стоимость акции неотрицательна
        IF NEW.price < 0 THEN
            RAISE EXCEPTION 'share price cannot be negative';
        END IF;

        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.check_finance() OWNER TO postgres;

--
-- Name: max_order(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.max_order() RETURNS real
    LANGUAGE plpgsql
    AS $$
DECLARE
max_order real;
BEGIN
SELECT max(sum) into max_order from orders;
RETURN max_order;
END;
$$;


ALTER FUNCTION public.max_order() OWNER TO postgres;

--
-- Name: personnel_stamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.personnel_stamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Проверить, что указаны имя сотрудника и зарплата
        IF NEW.name IS NULL THEN
            RAISE EXCEPTION 'name cannot be null';
        END IF;
        IF NEW.wage_day IS NULL THEN
            RAISE EXCEPTION '% cannot have null salary', NEW.name;
        END IF;

        -- Кто будет работать, если за это надо будет платить?
        IF NEW.wage_day < 0 THEN
            RAISE EXCEPTION '% cannot have a negative salary', NEW.name;
        END IF;

        -- Запомнить, кто и когда изменил запись
        NEW.last_date := current_timestamp;
        NEW.last_user := current_user;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION public.personnel_stamp() OWNER TO postgres;

--
-- Name: total_records(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.total_records() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
total integer;
BEGIN
SELECT count(*) into total from material_provider;
RETURN total;
END;
$$;


ALTER FUNCTION public.total_records() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: brends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.brends (
    id_brend integer NOT NULL,
    brend_name character varying(40) NOT NULL,
    country text NOT NULL,
    shop_num integer NOT NULL,
    work_num integer NOT NULL,
    turnover real,
    CONSTRAINT quantity CHECK (((shop_num > 0) AND (work_num > 0)))
);


ALTER TABLE public.brends OWNER TO postgres;

--
-- Name: brends_id_brend_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.brends_id_brend_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.brends_id_brend_seq OWNER TO postgres;

--
-- Name: brends_id_brend_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.brends_id_brend_seq OWNED BY public.brends.id_brend;


--
-- Name: brends_shop_num_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.brends_shop_num_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.brends_shop_num_seq OWNER TO postgres;

--
-- Name: brends_shop_num_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.brends_shop_num_seq OWNED BY public.brends.shop_num;


--
-- Name: brends_work_num_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.brends_work_num_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.brends_work_num_seq OWNER TO postgres;

--
-- Name: brends_work_num_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.brends_work_num_seq OWNED BY public.brends.work_num;


--
-- Name: costs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.costs (
    id_cost integer NOT NULL,
    id_brend integer NOT NULL,
    type text NOT NULL,
    name text NOT NULL,
    value real,
    date date,
    CONSTRAINT value CHECK ((value >= (0)::double precision))
);


ALTER TABLE public.costs OWNER TO postgres;

--
-- Name: costs_id_brend_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.costs_id_brend_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.costs_id_brend_seq OWNER TO postgres;

--
-- Name: costs_id_brend_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.costs_id_brend_seq OWNED BY public.costs.id_brend;


--
-- Name: costs_id_cost_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.costs_id_cost_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.costs_id_cost_seq OWNER TO postgres;

--
-- Name: costs_id_cost_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.costs_id_cost_seq OWNED BY public.costs.id_cost;


--
-- Name: finance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.finance (
    date_share date NOT NULL,
    id_brend integer NOT NULL,
    price real NOT NULL,
    CONSTRAINT price_share CHECK ((price >= (0)::double precision))
);


ALTER TABLE public.finance OWNER TO postgres;

--
-- Name: finance_id_brend_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.finance_id_brend_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.finance_id_brend_seq OWNER TO postgres;

--
-- Name: finance_id_brend_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.finance_id_brend_seq OWNED BY public.finance.id_brend;


--
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id_item integer NOT NULL,
    id_brend integer NOT NULL,
    composition text NOT NULL,
    colors text NOT NULL,
    in_stock boolean,
    item_quantity real,
    id_shop integer NOT NULL,
    CONSTRAINT out_of_stock CHECK ((((in_stock = false) AND (item_quantity = (0)::double precision)) OR ((in_stock = true) AND (item_quantity > (0)::double precision))))
);


ALTER TABLE public.items OWNER TO postgres;

--
-- Name: items_id_brend_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.items_id_brend_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.items_id_brend_seq OWNER TO postgres;

--
-- Name: items_id_brend_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_brend_seq OWNED BY public.items.id_brend;


--
-- Name: items_id_item_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.items_id_item_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.items_id_item_seq OWNER TO postgres;

--
-- Name: items_id_item_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_item_seq OWNED BY public.items.id_item;


--
-- Name: items_id_shop_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.items_id_shop_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.items_id_shop_seq OWNER TO postgres;

--
-- Name: items_id_shop_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_shop_seq OWNED BY public.items.id_shop;


--
-- Name: material_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.material_provider (
    id_provider integer NOT NULL,
    id_items text,
    material text NOT NULL,
    in_stock boolean,
    quantity real,
    CONSTRAINT out_of_stock CHECK ((((in_stock = false) AND (quantity = (0)::double precision)) OR ((in_stock = true) AND (quantity > (0)::double precision))))
);


ALTER TABLE public.material_provider OWNER TO postgres;

--
-- Name: material_provider_id_provider_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.material_provider_id_provider_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.material_provider_id_provider_seq OWNER TO postgres;

--
-- Name: material_provider_id_provider_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.material_provider_id_provider_seq OWNED BY public.material_provider.id_provider;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id_order integer NOT NULL,
    id_brend integer NOT NULL,
    id_shop integer NOT NULL,
    date date,
    online boolean,
    content jsonb NOT NULL,
    sum real,
    CONSTRAINT sum CHECK ((sum >= (0)::double precision))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_brend_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_brend_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_brend_seq OWNER TO postgres;

--
-- Name: orders_id_brend_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_brend_seq OWNED BY public.orders.id_brend;


--
-- Name: orders_id_order_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_order_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_order_seq OWNER TO postgres;

--
-- Name: orders_id_order_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_order_seq OWNED BY public.orders.id_order;


--
-- Name: orders_id_shop_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_shop_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_shop_seq OWNER TO postgres;

--
-- Name: orders_id_shop_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_shop_seq OWNED BY public.orders.id_shop;


--
-- Name: personnel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personnel (
    id_worker integer NOT NULL,
    id_brend integer NOT NULL,
    name text NOT NULL,
    job text NOT NULL,
    work_days text NOT NULL,
    wage_day real,
    wage_month real,
    CONSTRAINT wages CHECK (((wage_day > (0)::double precision) AND (wage_month > (0)::double precision)))
);


ALTER TABLE public.personnel OWNER TO postgres;

--
-- Name: personnel_id_brend_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personnel_id_brend_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personnel_id_brend_seq OWNER TO postgres;

--
-- Name: personnel_id_brend_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personnel_id_brend_seq OWNED BY public.personnel.id_brend;


--
-- Name: personnel_id_worker_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personnel_id_worker_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.personnel_id_worker_seq OWNER TO postgres;

--
-- Name: personnel_id_worker_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personnel_id_worker_seq OWNED BY public.personnel.id_worker;


--
-- Name: shops; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shops (
    id_shop integer NOT NULL,
    id_brend integer NOT NULL,
    city text NOT NULL,
    address text NOT NULL
);


ALTER TABLE public.shops OWNER TO postgres;

--
-- Name: shops_id_brend_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shops_id_brend_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shops_id_brend_seq OWNER TO postgres;

--
-- Name: shops_id_brend_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shops_id_brend_seq OWNED BY public.shops.id_brend;


--
-- Name: shops_id_shop_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shops_id_shop_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shops_id_shop_seq OWNER TO postgres;

--
-- Name: shops_id_shop_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shops_id_shop_seq OWNED BY public.shops.id_shop;


--
-- Name: brends id_brend; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brends ALTER COLUMN id_brend SET DEFAULT nextval('public.brends_id_brend_seq'::regclass);


--
-- Name: brends shop_num; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brends ALTER COLUMN shop_num SET DEFAULT nextval('public.brends_shop_num_seq'::regclass);


--
-- Name: brends work_num; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brends ALTER COLUMN work_num SET DEFAULT nextval('public.brends_work_num_seq'::regclass);


--
-- Name: costs id_cost; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.costs ALTER COLUMN id_cost SET DEFAULT nextval('public.costs_id_cost_seq'::regclass);


--
-- Name: costs id_brend; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.costs ALTER COLUMN id_brend SET DEFAULT nextval('public.costs_id_brend_seq'::regclass);


--
-- Name: finance id_brend; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance ALTER COLUMN id_brend SET DEFAULT nextval('public.finance_id_brend_seq'::regclass);


--
-- Name: items id_item; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id_item SET DEFAULT nextval('public.items_id_item_seq'::regclass);


--
-- Name: items id_brend; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id_brend SET DEFAULT nextval('public.items_id_brend_seq'::regclass);


--
-- Name: items id_shop; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id_shop SET DEFAULT nextval('public.items_id_shop_seq'::regclass);


--
-- Name: material_provider id_provider; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.material_provider ALTER COLUMN id_provider SET DEFAULT nextval('public.material_provider_id_provider_seq'::regclass);


--
-- Name: orders id_order; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id_order SET DEFAULT nextval('public.orders_id_order_seq'::regclass);


--
-- Name: orders id_brend; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id_brend SET DEFAULT nextval('public.orders_id_brend_seq'::regclass);


--
-- Name: orders id_shop; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id_shop SET DEFAULT nextval('public.orders_id_shop_seq'::regclass);


--
-- Name: personnel id_worker; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personnel ALTER COLUMN id_worker SET DEFAULT nextval('public.personnel_id_worker_seq'::regclass);


--
-- Name: personnel id_brend; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personnel ALTER COLUMN id_brend SET DEFAULT nextval('public.personnel_id_brend_seq'::regclass);


--
-- Name: shops id_shop; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shops ALTER COLUMN id_shop SET DEFAULT nextval('public.shops_id_shop_seq'::regclass);


--
-- Name: shops id_brend; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shops ALTER COLUMN id_brend SET DEFAULT nextval('public.shops_id_brend_seq'::regclass);


--
-- Data for Name: brends; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.brends (id_brend, brend_name, country, shop_num, work_num, turnover) FROM stdin;
0	Zara	Spain	2131	25100	1.7999999e+10
1	Massimo Dutti	Spain	766	16540	1.8e+09
2	Bershka	Spain	1107	18450	2.24e+09
3	Oysho	Spain	678	12000	570000000
4	Pull & Bear	Spain	974	20050	1.86e+09
5	Stradivarius	Spain	1011	19810	1.53e+09
6	Zara Home	Spain	603	9080	435000000
\.


--
-- Data for Name: costs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.costs (id_cost, id_brend, type, name, value, date) FROM stdin;
0	0	electricity	store operation	100000	2022-01-31
1	1	rent	store rent	450000	2022-01-01
2	5	electricity	warehouse operation	250000	2022-05-31
3	2	wage	directors wage	300000	2022-06-20
4	3	electricity	store operation	150000	2022-11-30
5	2	materials	id2	200000	2022-03-14
6	4	rent	warehouse rent	500000	2022-10-01
\.


--
-- Data for Name: finance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.finance (date_share, id_brend, price) FROM stdin;
2020-07-20	0	65
2022-12-12	1	40
2022-11-01	0	70
\.


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id_item, id_brend, composition, colors, in_stock, item_quantity, id_shop) FROM stdin;
0	4	100% cotton	white, black	t	1534	3
1	0	50% cotton, 50% polyester	red, blue, yellow	t	10004	2
2	0	100% cotton	white	f	0	4
3	5	100% acril	pink, purple	t	450	2
4	3	33% cotton, 33% acril, 33% modal	green, white	t	18450	4
5	2	100% wool	grey	t	12000	5
6	2	76% cotton, 24% elastane	red, black	f	0	1
7	1	100% polyester	black	t	19810	0
8	4	80% viscose, 20% polyester	brown	f	0	3
\.


--
-- Data for Name: material_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.material_provider (id_provider, id_items, material, in_stock, quantity) FROM stdin;
0	0, 2, 33	cotton	t	100000
1	1, 7, 8, 54	polyester	f	0
2	3, 16, 77	acril	t	250000
3	5, 27, 31	wool	t	300000
4	4	modal	t	150000
5	6, 10, 14, 56	elastane	f	0
6	8, 50	viscose	t	500000
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id_order, id_brend, id_shop, date, online, content, sum) FROM stdin;
0	0	2	2022-12-11	f	{"t-shirt": [3005, 1]}	3005
1	0	2	2022-12-11	t	{"jeans": [4500, 2], "socks": [500, 1]}	9500
2	0	1	2022-12-11	f	{"coat": [15000, 1], "jeans": [4500, 1], "pajamas": [5000, 1]}	24500
3	0	1	2022-12-11	f	{"coat": [15000, 1]}	15000
4	0	0	2022-12-11	t	{"blouse": [3000, 1]}	3000
5	2	5	2022-12-11	f	{"jeans": [4500, 1], "shorts": [2500, 1]}	7000
6	4	6	2022-12-11	f	{"t-shirt": [1500, 1]}	1500
\.


--
-- Data for Name: personnel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personnel (id_worker, id_brend, name, job, work_days, wage_day, wage_month) FROM stdin;
0	4	Vasiliev Alexey Olegovich	director	Monday, Tuesday, Wednesday, Thursday, Friday	15000	300000
1	0	Tavretskaya Evgenia Sergeevna	manager	Monday, Tuesday, Wednesday, Thursday, Friday	5000	100000
2	0	Gorshkova Tatiana Dmitrievna	shop assistant	Monday, Wednesday, Thursday, Friday, Sunday	1500	30000
3	5	Kostin Artur Nikitich	director	Monday, Tuesday, Wednesday, Thursday, Friday	25000	500000
4	4	Streletskiy Petr Fedorovich	security guard	Monday, Tuesday, Wednesday, Thursday, Friday	2500	50000
5	2	Bulatova Polina Antonovna	shop assistant	Monday, Tuesday, Wednesday	1000	20000
6	2	Matveeva Anastasia Dmitrievna	shop assistant	Monday, Tuesday, Thursday, Friday, Saturday	1750	35000
7	4	Ivanov Artem Victorovich	manager	Monday, Tuesday, Wednesday, Thursday, Friday	4500	90000
8	4	Meshkov Boris Konstantinovich	shop assistant	Monday, Wednesday, Friday	1250	30000
\.


--
-- Data for Name: shops; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shops (id_shop, id_brend, city, address) FROM stdin;
0	0	Moscow	Leningradskoe sh. 16A
1	0	Moscow	Manezhnaya pl. 1
2	0	Saint-Petersburg	Ligovskiy pr. 30A
3	2	Moscow	Krokus Siti Moll
4	2	Vladivostok	Kalina Moll
5	2	Moscow	Sh. Entuziastov 12-2
6	4	Moscow	Varshavskoe sh. 140
\.


--
-- Name: brends_id_brend_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.brends_id_brend_seq', 1, false);


--
-- Name: brends_shop_num_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.brends_shop_num_seq', 1, false);


--
-- Name: brends_work_num_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.brends_work_num_seq', 1, false);


--
-- Name: costs_id_brend_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.costs_id_brend_seq', 1, false);


--
-- Name: costs_id_cost_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.costs_id_cost_seq', 1, false);


--
-- Name: finance_id_brend_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.finance_id_brend_seq', 1, false);


--
-- Name: items_id_brend_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_brend_seq', 1, false);


--
-- Name: items_id_item_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_item_seq', 1, false);


--
-- Name: items_id_shop_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_shop_seq', 1, false);


--
-- Name: material_provider_id_provider_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.material_provider_id_provider_seq', 1, false);


--
-- Name: orders_id_brend_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_brend_seq', 1, false);


--
-- Name: orders_id_order_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_order_seq', 1, false);


--
-- Name: orders_id_shop_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_shop_seq', 1, false);


--
-- Name: personnel_id_brend_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personnel_id_brend_seq', 1, false);


--
-- Name: personnel_id_worker_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personnel_id_worker_seq', 1, false);


--
-- Name: shops_id_brend_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shops_id_brend_seq', 1, false);


--
-- Name: shops_id_shop_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shops_id_shop_seq', 1, false);


--
-- Name: brends brends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.brends
    ADD CONSTRAINT brends_pkey PRIMARY KEY (id_brend);


--
-- Name: costs costs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.costs
    ADD CONSTRAINT costs_pkey PRIMARY KEY (id_cost);


--
-- Name: finance finance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance
    ADD CONSTRAINT finance_pkey PRIMARY KEY (date_share);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id_item);


--
-- Name: material_provider material_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.material_provider
    ADD CONSTRAINT material_provider_pkey PRIMARY KEY (id_provider);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id_order);


--
-- Name: personnel personnel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personnel
    ADD CONSTRAINT personnel_pkey PRIMARY KEY (id_worker);


--
-- Name: shops shops_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_pkey PRIMARY KEY (id_shop);


--
-- Name: finance check_finance; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER check_finance AFTER INSERT OR DELETE OR UPDATE ON public.finance FOR EACH ROW EXECUTE PROCEDURE public.check_finance();


--
-- Name: personnel personnel_stamp; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER personnel_stamp BEFORE INSERT OR UPDATE ON public.personnel FOR EACH ROW EXECUTE PROCEDURE public.personnel_stamp();


--
-- Name: costs costs_id_brend_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.costs
    ADD CONSTRAINT costs_id_brend_fkey FOREIGN KEY (id_brend) REFERENCES public.brends(id_brend);


--
-- Name: finance finance_id_brend_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.finance
    ADD CONSTRAINT finance_id_brend_fkey FOREIGN KEY (id_brend) REFERENCES public.brends(id_brend);


--
-- Name: items items_id_brend_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_id_brend_fkey FOREIGN KEY (id_brend) REFERENCES public.brends(id_brend);


--
-- Name: items items_id_shop_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_id_shop_fkey FOREIGN KEY (id_shop) REFERENCES public.shops(id_shop);


--
-- Name: orders orders_id_brend_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_id_brend_fkey FOREIGN KEY (id_brend) REFERENCES public.brends(id_brend);


--
-- Name: orders orders_id_shop_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_id_shop_fkey FOREIGN KEY (id_shop) REFERENCES public.shops(id_shop);


--
-- Name: personnel personnel_id_brend_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personnel
    ADD CONSTRAINT personnel_id_brend_fkey FOREIGN KEY (id_brend) REFERENCES public.brends(id_brend);


--
-- Name: shops shops_id_brend_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_id_brend_fkey FOREIGN KEY (id_brend) REFERENCES public.brends(id_brend);


--
-- PostgreSQL database dump complete
--


--
-- PostgreSQL database dump
--

\restrict CH2vwYiPNFqWyKZJgFkw59zXdahi3rbfwb8VdUA3seV1cK1qUvu5e4i51C5AZBr

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

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

--
-- Name: analytics; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA analytics;


--
-- Name: raw; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA raw;


--
-- Name: staging; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA staging;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: category_translation; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.category_translation (
    product_category_name text,
    product_category_name_english text
);


--
-- Name: customers; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.customers (
    customer_id text,
    customer_unique_id text,
    customer_zip_code_prefix text,
    customer_city text,
    customer_state text
);


--
-- Name: geolocation; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.geolocation (
    geolocation_zip_code_prefix text,
    geolocation_lat text,
    geolocation_lng text,
    geolocation_city text,
    geolocation_state text
);


--
-- Name: order_items; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.order_items (
    order_id text,
    order_item_id text,
    product_id text,
    seller_id text,
    shipping_limit_date text,
    price text,
    freight_value text
);


--
-- Name: order_payments; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.order_payments (
    order_id text,
    payment_sequential text,
    payment_type text,
    payment_installments text,
    payment_value text
);


--
-- Name: order_reviews; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.order_reviews (
    review_id text,
    order_id text,
    review_score text,
    review_comment_title text,
    review_comment_message text,
    review_creation_date text,
    review_answer_timestamp text
);


--
-- Name: orders; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.orders (
    order_id text,
    customer_id text,
    order_status text,
    order_purchase_timestamp text,
    order_approved_at text,
    order_delivered_carrier_date text,
    order_delivered_customer_date text,
    order_estimated_delivery_date text
);


--
-- Name: products; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.products (
    product_id text,
    product_category_name text,
    product_name_lenght text,
    product_description_lenght text,
    product_photos_qty text,
    product_weight_g text,
    product_length_cm text,
    product_height_cm text,
    product_width_cm text
);


--
-- Name: sellers; Type: TABLE; Schema: raw; Owner: -
--

CREATE TABLE raw.sellers (
    seller_id text,
    seller_zip_code_prefix text,
    seller_city text,
    seller_state text
);


--
-- PostgreSQL database dump complete
--

\unrestrict CH2vwYiPNFqWyKZJgFkw59zXdahi3rbfwb8VdUA3seV1cK1qUvu5e4i51C5AZBr


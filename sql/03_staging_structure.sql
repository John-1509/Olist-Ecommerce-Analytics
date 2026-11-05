--
-- PostgreSQL database dump
--

\restrict MAYAJ6KDU9IwddGM4SaA3kE8mzARMJo3gTS93tDobG3bcNAZVHcw5WE445Dpxgw

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: category_translation; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.category_translation (
    product_category_name text,
    product_category_name_english text
);


--
-- Name: customers; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.customers (
    customer_id text NOT NULL,
    customer_unique_id text,
    customer_zip_code_prefix text,
    customer_state text,
    customer_city text
);


--
-- Name: geolocation; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.geolocation (
    geolocation_zip_code_prefix text,
    geolocation_lat numeric,
    geolocation_lng numeric,
    geolocation_city text,
    geolocation_state text
);


--
-- Name: order_items; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.order_items (
    order_id text NOT NULL,
    order_item_id integer NOT NULL,
    product_id text,
    seller_id text,
    shipping_limit_date timestamp without time zone,
    price numeric,
    freight_value numeric
);


--
-- Name: order_payments; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.order_payments (
    order_id text NOT NULL,
    payment_sequential integer NOT NULL,
    payment_type text,
    payment_installments integer,
    payment_value numeric
);


--
-- Name: order_reviews; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.order_reviews (
    review_id text,
    order_id text,
    review_score integer,
    review_comment_title text,
    review_comment_message text,
    review_creation_date timestamp without time zone,
    review_answer_timestamp timestamp without time zone
);


--
-- Name: orders; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.orders (
    order_id text NOT NULL,
    customer_id text,
    order_status text,
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone
);


--
-- Name: products; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.products (
    product_id text NOT NULL,
    product_category_name text,
    product_name_lenght integer,
    product_description_lenght integer,
    product_photos_qty integer,
    product_weight_g integer,
    product_length_cm numeric,
    product_height_cm numeric,
    product_width_cm numeric
);


--
-- Name: sellers; Type: TABLE; Schema: staging; Owner: -
--

CREATE TABLE staging.sellers (
    seller_id text NOT NULL,
    seller_zip_code_prefix text,
    seller_city text,
    seller_state text
);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_id, order_item_id);


--
-- Name: order_payments order_payments_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.order_payments
    ADD CONSTRAINT order_payments_pkey PRIMARY KEY (order_id, payment_sequential);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: sellers sellers_pkey; Type: CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.sellers
    ADD CONSTRAINT sellers_pkey PRIMARY KEY (seller_id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES staging.orders(order_id);


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES staging.products(product_id);


--
-- Name: order_items order_items_seller_id_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.order_items
    ADD CONSTRAINT order_items_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES staging.sellers(seller_id);


--
-- Name: order_payments order_payments_order_id_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.order_payments
    ADD CONSTRAINT order_payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES staging.orders(order_id);


--
-- Name: order_reviews order_reviews_order_id_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.order_reviews
    ADD CONSTRAINT order_reviews_order_id_fkey FOREIGN KEY (order_id) REFERENCES staging.orders(order_id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: staging; Owner: -
--

ALTER TABLE ONLY staging.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES staging.customers(customer_id);


--
-- PostgreSQL database dump complete
--

\unrestrict MAYAJ6KDU9IwddGM4SaA3kE8mzARMJo3gTS93tDobG3bcNAZVHcw5WE445Dpxgw


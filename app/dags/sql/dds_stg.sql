CREATE SCHEMA dds_stg;

CREATE TABLE dds_stg.invoices(
    type varchar(5) NOT NULL,
    num smallint NOT NULL,
    deal_date date NOT NULL,
    counterparty_name varchar(70) NOT NULL,
    product_name varchar(25),
    amt smallint,
    unit_price float
    );


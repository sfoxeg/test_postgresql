CREATE SCHEMA dds;


CREATE TABLE dds.products(
            product_id serial PRIMARY KEY,
            product_name varchar(25) NOT NULL
);


CREATE TABLE dds.counterparties(
            counterparty_id serial PRIMARY KEY,
            counterparty_name varchar(70) NOT NULL
);


CREATE TABLE dds.stock(
            unit_in_stock_id serial PRIMARY KEY,
            product_id integer NOT NULL,
            unit_in_stock integer NOT NULL,
            FOREIGN KEY (product_id) REFERENCES dds.products (product_id)
);


CREATE TABLE dds.invoices(
            invoice_id serial PRIMARY KEY,
            type boolean NOT NULL,
            number integer NOT NULL,
            deal_date date NOT NULL,
            counterparty_id integer NOT NULL,
            FOREIGN KEY (counterparty_id) REFERENCES dds.counterparties (counterparty_id)
);


CREATE TABLE dds.invoice(
            invoice_id integer NOT NULL,
            product_id integer NOT NULL,
            amt integer DEFAULT 0,
            price float DEFAULT 0,
            FOREIGN KEY (invoice_id) REFERENCES dds.invoices (invoice_id),
            FOREIGN KEY (product_id) REFERENCES dds.products (product_id)
);


INSERT INTO dds.counterparties (counterparty_name)
            SELECT DISTINCT counterparty_name FROM dds_stg.invoices ORDER BY counterparty_name;


INSERT INTO dds.products (product_name)
            SELECT DISTINCT product_name FROM dds_stg.invoices ORDER BY product_name;


INSERT INTO dds.invoices (number, deal_date, counterparty_id, type)
            SELECT num, deal_date, counterparty_id,
            CASE WHEN type = 'buy' THEN False
            	 WHEN type = 'sale' THEN True
            END AS type
            FROM dds_stg.invoices
            JOIN dds.counterparties USING(counterparty_name)
            GROUP BY num, deal_date, type, counterparty_id
            ORDER BY num;


INSERT INTO dds.invoice (invoice_id, product_id, amt, price)
            SELECT invoice_id, product_id, amt, unit_price FROM dds_stg.invoices
            JOIN dds.products USING (product_name)
            JOIN dds.invoices ON dds.invoices.number=dds_stg.invoices.num
            WHERE num = ANY (
            	SELECT num FROM dds.invoices
            );


WITH stock_balance AS (
	SELECT product_id,
	CASE WHEN type = True THEN amt * -1
 		ELSE amt
	END AS amt
	FROM dds.invoice
	JOIN dds.invoices using (invoice_id)
	WHERE product_id = ANY (
		SELECT product_id FROM dds.products
	)
	ORDER BY product_id
)

INSERT INTO dds.stock (product_id, unit_in_stock)
	SELECT product_id, SUM(amt) AS unit_in_stock
	FROM stock_balance
	GROUP BY product_id;

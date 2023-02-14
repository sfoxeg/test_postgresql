CREATE SCHEMA ddm;


CREATE VIEW ddm.sall_stat AS
	WITH sall AS (
		SELECT deal_date, counterparty_name, SUM(amt) AS amt, SUM(price) AS price
		FROM dds.invoices
		JOIN dds.counterparties USING (counterparty_id)
		JOIN dds.invoice USING (invoice_id)
		WHERE type = True
		GROUP BY counterparty_name, deal_date
	), sall_year AS (
		SELECT counterparty_name, SUM(amt) AS year_amt, SUM(price) AS year_sum
		FROM sall
		WHERE deal_date >= current_date - interval '1 year'
		GROUP BY counterparty_name
	), sall_quarterly AS (
		SELECT counterparty_name, SUM(amt) AS quarterly_amt, SUM(price) AS quarterly_sum
		FROM sall
		WHERE deal_date >= current_date - interval '3 month'
		GROUP BY counterparty_name
	), sall_month AS (
		SELECT counterparty_name, SUM(amt) AS month_amt, SUM(price) AS month_sum
		FROM sall
		WHERE deal_date >= current_date - interval '1 month'
		GROUP BY counterparty_name
	)

SELECT *
FROM sall_year
LEFT JOIN sall_quarterly USING (counterparty_name)
LEFT JOIN sall_month USING (counterparty_name)
ORDER BY counterparty_name;


CREATE VIEW ddm.buy_stat AS
	WITH buy AS (
		select product_name, deal_date, amt, price
		from dds.invoice
		join dds.invoices USING (invoice_id)
		JOIN dds.products USING (product_id)
		WHERE type = False
	), buy_year AS (
		SELECT product_name, SUM(amt) AS year_amt, SUM(price) AS year_price
		FROM buy
		WHERE deal_date >= current_date - interval '1 year'
		GROUP BY product_name
	), buy_quarterly AS (
		SELECT product_name, SUM(amt) AS quarterly_amt, SUM(price) AS quarterly_price
		FROM buy
		WHERE deal_date >= current_date - interval '3 month'
		GROUP BY product_name
	), buy_month AS (
		SELECT product_name, SUM(amt) AS month_amt, SUM(price) AS month_price
		FROM buy
		WHERE deal_date >= current_date - interval '1 month'
		GROUP BY product_name
	)

SELECT *
FROM buy_year
LEFT JOIN buy_quarterly USING (product_name)
LEFT JOIN buy_month USING (product_name)
ORDER BY product_name;


CREATE VIEW ddm.proceeds_stat AS
	SELECT ('year_proceeds') AS period, SUM(price) AS proceeds FROM dds.invoice
	JOIN dds.invoices USING (invoice_id)
	WHERE type = True AND deal_date >= current_date - interval '1 year'
	UNION ALL
	SELECT ('quarterly_proceeds'), SUM(price) FROM dds.invoice
	JOIN dds.invoices USING (invoice_id)
	WHERE type = True AND deal_date >= current_date - interval '3 month'
	UNION ALL
	SELECT ('month_proceeds'), SUM(price) FROM dds.invoice
	JOIN dds.invoices USING (invoice_id)
	WHERE type = True AND deal_date >= current_date - interval '1 month'

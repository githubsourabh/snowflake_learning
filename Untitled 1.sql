SELECT COUNT(*) FROM retail_lab.raw.online_retail_raw;
SELECT * FROM retail_lab.raw.online_retail_raw LIMIT 20;
SELECT COUNT_IF(invoiceno IS NULL) AS null_invoice,
       COUNT_IF(invoicedate IS NULL) AS null_date,
       COUNT_IF(quantity IS NULL) AS null_qty,
       COUNT_IF(unitprice IS NULL) AS null_price
FROM retail_lab.raw.online_retail_raw;
SELECT country, COUNT(*) AS row_count
FROM retail_lab.raw.online_retail_raw
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20;
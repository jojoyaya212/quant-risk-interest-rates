CREATE DATABASE finance;
CREATE TABLE stocks (
	Trading_date DATE,
	BAC_adj FLOAT, C_adj FLOAT, JPM_adj FLOAT, WFC_adj FLOAT,
    BAC_close FLOAT, C_close FLOAT, JPM_close FLOAT, WFC_close FLOAT,
    BAC_high FLOAT, C_high FLOAT, JPM_high FLOAT, WFC_high FLOAT,
    BAC_low FLOAT, C_low FLOAT, JPM_low FLOAT, WFC_low FLOAT,
    BAC_open FLOAT, C_open FLOAT, JPM_open FLOAT, WFC_open FLOAT,
    BAC_vol BIGINT, C_vol BIGINT, JPM_vol BIGINT, WFC_vol BIGINT
);
SELECT TOP 10 * FROM stocks;
SELECT TOP 10 * FROM DGS10;

SELECT
	s.date,
	s.BAC_adj_close,
	s.C_adj_close,
	s.JPM_adj_close,
	s.WFC_adj_close,
	r.dgs10_rate AS DGS10_rate
FROM stocks AS s
INNER JOIN dgs10 AS r
	ON s.date = r.DATE
WHERE s.date > = '2015-01-01'
	AND s.date < = '2024-12-31'
ORDER BY s.date;


SELECT
	s.date,
	s.BAC_adj_close,
	s.C_adj_close,
	s.JPM_adj_close,
	s.WFC_adj_close,
	r.dgs10_rate AS DGS10_rate
FROM stocks AS s
INNER JOIN dgs10 AS r
	ON s.date = r.DATE
WHERE s.date > = '2015-01-01'
	AND s.date < = '2024-12-31'
	AND(
	s.BAC_adj_close IS NULL
		OR s.C_adj_close   IS NULL
		OR s.JPM_adj_close IS NULL
		OR s.WFC_adj_close IS NULL
		OR r.DGS10_rate IS NULL
  )
ORDER BY s.date;


SELECT
	s.date,
	s.BAC_adj_close,
	s.C_adj_close,
	s.JPM_adj_close,
	s.WFC_adj_close,
	r.dgs10_rate AS DGS10_rate
FROM stocks AS s
INNER JOIN dgs10 AS r
	ON s.date = r.DATE
WHERE s.date > = '2015-01-01'
	AND s.date < = '2024-12-31'
	AND(
	s.BAC_adj_close IS NOT NULL
		AND s.C_adj_close   IS NOT NULL
		AND s.JPM_adj_close IS NOT NULL
		AND s.WFC_adj_close IS NOT NULL
		AND r.DGS10_rate IS NOT NULL
  )
ORDER BY s.date;


SELECT
	s.date,
	s.BAC_adj_close,
	s.C_adj_close,
	s.JPM_adj_close,
	s.WFC_adj_close,
	r.dgs10_rate AS DGS10_rate
FROM stocks AS s
INNER JOIN dgs10 AS r
	ON s.date = r.DATE
WHERE s.date > = '2015-01-01'
	AND s.date < = '2024-12-31'
	AND NOT(
	s.BAC_adj_close IS NULL
		OR s.C_adj_close   IS NULL
		OR s.JPM_adj_close IS NULL
		OR s.WFC_adj_close IS NULL
		OR r.DGS10_rate IS NULL
  )
ORDER BY s.date;
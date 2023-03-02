/**Comparing BTC and S&P 500 Daily Returns**/
/*******************************************************************************************************
They're two different asset classes. The S&P 500's table name is GSPC. GSPC is the S&P 500's formal ticker symbol.
Despite the desire of Crypto enthusiast to create an alternative and decentralized financial system,
BTC and the Crypto market has shown to be affected by traditional macroeconomic and market forces.
There has been a closer correlation between Bitcoin and the Nasdaq since the crypto 2020 Bull Market. 
/*******************************************************************************************************
BTC trades 24 hours each day.
The S&P trades during regular market hours.
The INNER JOIN joins those dates that both assets trade on the same day.
I'm only interested in the Closing Price of both assets and not the Open, High, Low, or Volume.
*******************************************************************************************************/

/**S&P 500**/

CREATE VIEW [dbo].[vw_GSPC]

AS

SELECT DATEPART(QUARTER,[Date]) AS Qtr,
	   [Date],
       ROUND([Close],2) AS GSPC_Close,
	   ROUND(([Close]-LAG([Close],1) OVER (ORDER BY [DATE])) / LAG([Close],1) OVER (ORDER BY [Date]),4) * 100 AS GSPC_Pct_Chg,
CASE
	   WHEN (Round(([Close]-LAG([Close],1) OVER(ORDER BY [Date] ASC)) / LAG([Close],1) OVER(ORDER BY [Date] ASC),4) * 100) > 0 THEN 'Up'
	   WHEN (Round(([Close]-LAG([Close],1) OVER(ORDER BY [Date] ASC)) / LAG([Close],1) OVER(ORDER BY [Date] ASC),4) * 100) < 0 THEN 'Down'
	   WHEN (Round(([Close]-LAG([Close],1) OVER(ORDER BY [Date] ASC)) / LAG([Close],1) OVER(ORDER BY [Date] ASC),4) * 100) = 0 THEN 'Flat'
	END AS GSPC_Daily_Chg
FROM GSPC;

/**Bitcoin**/

CREATE VIEW [dbo].[vw_BTC]

AS

SELECT DATEPART(QUARTER,[Date]) AS Qtr,
	   [Date],
       ROUND([Close],2) AS BTC_Close,
	   ROUND(([Close]-LAG([Close],1) OVER (ORDER BY [DATE])) / LAG([Close],1) OVER (ORDER BY [Date]),4) * 100 AS BTC_Pct_Chg,
CASE
	   WHEN (Round(([Close]-LAG([Close],1) OVER(ORDER BY [Date] ASC)) / LAG([Close],1) OVER(ORDER BY [Date] ASC),4) * 100) > 0 THEN 'Up'
	   WHEN (Round(([Close]-LAG([Close],1) OVER(ORDER BY [Date] ASC)) / LAG([Close],1) OVER(ORDER BY [Date] ASC),4) * 100) < 0 THEN 'Down'
	   WHEN (Round(([Close]-LAG([Close],1) OVER(ORDER BY [Date] ASC)) / LAG([Close],1) OVER(ORDER BY [Date] ASC),4) * 100) = 0 THEN 'Flat'
	END AS BTC_Daily_Chg
FROM BTC;

/**Inner Joining Both Views**/

SELECT b.Qtr,
	   b.Date,
	   s.GSPC_Close,
	   s.GSPC_Pct_Chg,
	   b.BTC_Close,
	   b.BTC_Pct_Chg,
	   s.GSPC_Daily_Chg,
	   s.GSPC_Pct_Chg,
	   b.BTC_Daily_Chg
FROM vw_BTC b INNER JOIN vw_GSPC s
ON b.Date = s.Date;

/**Count of Up, Down, and Flat (no movement) days for the S&P and BTC, from the date both datasets start together (July 19, 2010)**/

/**S&P 500 Daily Change**/
SELECT GSPC_Daily_Chg, COUNT(GSPC_Daily_Chg) AS Count_Days
FROM vw_GSPC
WHERE [Date] >= '20100719'
GROUP BY GSPC_Daily_Chg;

/**BTC Daily Change**/
SELECT BTC_Daily_Chg, COUNT(BTC_Daily_Chg) AS Count_Days
FROM vw_BTC
WHERE [Date] >= '20100719'
GROUP BY BTC_Daily_Chg;

/**Stored Procedures to pass values to the date parameters**/

/**Stored Procedure for the S&P 500 (GSPC_Count_Days)**/
CREATE PROCEDURE GSPC_Count_Days
@Date1 date, @date2 date

AS

SELECT GSPC_Daily_Chg, COUNT(GSPC_Daily_Chg) AS Count_Days
FROM vw_GSPC
WHERE [Date] BETWEEN @Date1 AND @date2
GROUP BY GSPC_Daily_Chg;

/**Execute GSPC_Count_Days Procedure for the start of 2023 to the end of Febraury 2023. **/
EXEC GSPC_Count_Days @Date1 = '20230101', @Date2 = '20230228';

/**Stored Procedure for the BTC (BTC_Count_Days)**/
CREATE PROCEDURE BTC_Count_Days
@Date1 date, @date2 date

AS

SELECT BTC_Daily_Chg, COUNT(BTC_Daily_Chg) AS Count_Days
FROM vw_BTC
WHERE [Date] BETWEEN @Date1 AND @date2
GROUP BY BTC_Daily_Chg;

/**Execute BTC_Count_Days Procedure for the start of 2023 to the end of Febraury 2023. **/
EXEC BTC_Count_Days @Date1 = '20230101', @Date2 = '20230228';

/**Largest Down day, from the date both datasets start together (July 19, 2010).
It's no surprise that they're both in March 2020, days apart from each other.
This was the time the pandemic shocked the global economy.**/

SELECT [Date], GSPC_Pct_Chg
FROM vw_GSPC b
WHERE GSPC_Pct_Chg = (SELECT MIN(GSPC_Pct_Chg) FROM vw_GSPC);

SELECT [Date], BTC_Pct_Chg
FROM vw_BTC
WHERE BTC_Pct_Chg = (SELECT MIN(BTC_Pct_Chg) FROM vw_BTC)


/**Largest Up Day, from the date both datasets start together (July 19, 2010).**/
SELECT [Date], GSPC_Pct_Chg
FROM vw_GSPC b
WHERE GSPC_Pct_Chg = (SELECT MAX(GSPC_Pct_Chg) FROM vw_GSPC);

SELECT [Date], BTC_Pct_Chg
FROM vw_BTC
WHERE BTC_Pct_Chg = (SELECT MAX(BTC_Pct_Chg) FROM vw_BTC)


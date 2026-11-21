USE BUDT703_Project_0506_11
/* 
Business Transaction 1: Which Service Classifications consume the highest share of Peak Vehicles (Supply) 
relative to the Population they serve (Potential Demand)?
*/

SELECT 
    c.classificationClass AS 'Service Type',
    c.classificationTier AS Tier,
    -- Sum of Demand (Potential Customers)
    SUM(o.operationalPopulation) AS 'Total Population Served',
    -- Calculate Supply/Demand Ratio (Vehicles per 1,000 people)
    ROUND((CAST(SUM(o.operationalPeakVehicles) AS FLOAT) / NULLIF(SUM(o.operationalPopulation), 0)) * 1000,2) 
    AS 'Vehicles Per 1000 People'
FROM [Metro.Classification] c
JOIN [Metro.Line] l ON c.classificationId = l.classificationId
JOIN [Metro.Operational] o ON l.lineId = o.lineId
JOIN [Metro.Time] t ON o.timeId = t.timeId
WHERE t.timeFiscalYear = '2024' 
GROUP BY 
    c.classificationClass, 
    c.classificationTier
ORDER BY 
    "Vehicles Per 1000 People" DESC;


/* 
Business Transaction 2: Which lines consistently exhibit high crowding (demand) but low cost recovery 
(financial return) over time?
*/
SELECT 
    l.lineName AS 'Line Name',
    t.timeFiscalYear AS 'Fiscal Year',
    ROUND(lp.linePerformanceCrowding, 4) AS 'Crowding Score',
    ROUND(lp.linePerformanceCostRecovery, 4) AS 'Cost Recovery',
    ROUND(
        (lp.linePerformanceCrowding) / NULLIF(lp.linePerformanceCostRecovery, 0), 
        2
    ) AS "Mismatch Ratio"
FROM 
    [Metro.Line] l
JOIN 
    [Metro.LinePerformance] lp ON l.lineId = lp.lineId
JOIN 
    [Metro.Time] t ON lp.timeId = t.timeId
WHERE 
    t.timeDayType = 'Weekday' 
    AND lp.linePerformanceCrowding > 0
ORDER BY 
    -- Calculate the average for sorting, but don't show it in the result
    AVG((lp.linePerformanceCrowding) / NULLIF(lp.linePerformanceCostRecovery, 0)) OVER (PARTITION BY l.lineName) DESC,
    l.lineName ASC,
    t.timeFiscalYear ASC;

/* 
Business Transaction 3: How does the Operating Cost per Passenger increase on Weekends 
compared to Weekdays YoY for Framework lines?
*/

SELECT 
    l.lineName AS 'Line Name',
    t.timeFiscalYear AS 'Fiscal Year',
    -- 1. Calculate Weekday Cost
    CAST(AVG(CASE WHEN t.timeDayType = 'Weekday' THEN lp.linePerformanceOpsCostperPAX END) 
        AS DECIMAL(10,2)) AS 'Weekday Cost',
    -- 2. Calculate Weekend Cost (Grouping Saturday and Sunday)
    CAST(AVG(CASE WHEN t.timeDayType IN ('Saturday', 'Sunday') THEN lp.linePerformanceOpsCostperPAX END) 
        AS DECIMAL(10,2)) AS 'Weekend Cost',
    -- 3. Calculate the "Weekend Surcharge" (The Gap)
    CAST((AVG(CASE WHEN t.timeDayType IN ('Saturday', 'Sunday') THEN lp.linePerformanceOpsCostperPAX END) - 
         AVG(CASE WHEN t.timeDayType = 'Weekday' THEN lp.linePerformanceOpsCostperPAX END)) 
        AS DECIMAL(10,2)) AS 'Weekend Surcharge'
FROM [Metro.Line] l
    JOIN [Metro.Classification] c ON l.classificationId = c.classificationId
    JOIN [Metro.LinePerformance] lp ON l.lineId = lp.lineId
    JOIN [Metro.Time] t ON lp.timeId = t.timeId
WHERE c.classificationClass = 'Framework' -- Focus strictly on Framework lines [1]
GROUP BY  l.lineName, t.timeFiscalYear
HAVING 
    AVG(CASE WHEN t.timeDayType = 'Weekday' THEN lp.linePerformanceOpsCostperPAX END) IS NOT NULL
    AND AVG(CASE WHEN t.timeDayType IN ('Saturday', 'Sunday') THEN lp.linePerformanceOpsCostperPAX END) IS NOT NULL
ORDER BY 
    -- Window Function: Calculate the average surcharge for the line across all years
    -- This keeps the "Worst" lines (highest avg surcharge) at the top of the list
    AVG(
        AVG(CASE WHEN t.timeDayType IN ('Saturday', 'Sunday') THEN lp.linePerformanceOpsCostperPAX END) - 
        AVG(CASE WHEN t.timeDayType = 'Weekday' THEN lp.linePerformanceOpsCostperPAX END)
    ) OVER (PARTITION BY l.lineName) DESC,
    l.lineName ASC,
    t.timeFiscalYear ASC;


/*Business Transaction 4: What percentage of total system Ridership is contributed by each jurisdiction, 
and does it align with their Vehicle usage? 
*/

WITH CTE_Vehicles AS (
    -- Calculate total vehicle supply per jurisdiction
    SELECT 
        l.lineJurisdiction,
        SUM(o.operationalPeakVehicles) AS Total_Vehicles
    FROM [Metro.Line] l
    JOIN [Metro.Operational] o ON l.lineId = o.lineId
    JOIN [Metro.Time] t ON o.timeId = t.timeId
    WHERE t.timeFiscalYear = '2024'
    GROUP BY l.lineJurisdiction
),
CTE_Ridership AS (
    -- Calculate total ridership demand per jurisdiction
    SELECT 
        l.lineJurisdiction,
        SUM(rp.routePerformanceAvgDailyRidership) AS Total_Ridership
    FROM [Metro.Line] l
    JOIN [Metro.Route] r ON l.lineId = r.lineId
    JOIN [Metro.RoutePerformance] rp ON r.routeId = rp.routeId
    JOIN [Metro.Time] t ON rp.timeId = t.timeId
    WHERE 
        t.timeFiscalYear = '2024' 
        AND t.timeDayType = 'Weekday'
    GROUP BY l.lineJurisdiction) 

SELECT 
    v.lineJurisdiction AS 'Line Jurisdiction',
    CAST((v.Total_Vehicles * 100.0 / SUM(v.Total_Vehicles) OVER ()) - 
        (r.Total_Ridership * 100.0 / SUM(r.Total_Ridership) OVER ())AS DECIMAL(10,2)) AS 'Allocation Gap (%)'
FROM 
    CTE_Vehicles v
JOIN 
    CTE_Ridership r ON v.lineJurisdiction = r.lineJurisdiction
ORDER BY 
    'Allocation Gap (%)' DESC;


/* 
Business Transaction 5: Which Jurisdictions and Service Types maximize ridership 
crowding while minimizing operating costs?"
*/

SELECT 
    l.lineJurisdiction AS "Jurisdiction",
    c.classificationClass AS "Service Type",
    COUNT(DISTINCT l.lineId) AS "Line Count",
    -- Average Crowding %
    CAST(ROUND(AVG(lp.linePerformanceCrowding) * 100, 2) AS DECIMAL(10,2)) AS 'Avg Crowding (%)',
    -- Max Crowding % (worst outlier in this group)
    CAST(ROUND(MAX(lp.linePerformanceCrowding) * 100, 2) AS DECIMAL(10,2)) AS 'Max Crowding (%)',
    -- Average Cost (efficiency trade-off)
    CAST(ROUND(AVG(lp.linePerformanceOpsCostperPAX), 2) AS DECIMAL(10,2)) AS 'Avg Cost Per Pax ($)'
FROM [Metro.Line] l
JOIN [Metro.Classification] c ON l.classificationId = c.classificationId
JOIN [Metro.LinePerformance] lp ON l.lineId = lp.lineId
JOIN [Metro.Time] t ON lp.timeId = t.timeId
WHERE 
    t.timeDayType = 'Weekday' 
    AND t.timeFiscalYear = '2024'
GROUP BY  l.lineJurisdiction, c.classificationClass
ORDER BY 
    'Jurisdiction', 
    'Avg Crowding (%)' DESC;


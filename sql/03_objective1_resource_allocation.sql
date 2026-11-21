USE BUDT703_Project_0506_11
GO

-- Objective 1: Optimize Resource Allocation and Investment 
-- Q1: What is the social value for each line classification class and tier?
SELECT c.classificationClass AS "Classification Class", c.classificationTier AS "Classification Tier", 
    CAST(ROUND(SUM(o.operationalPopLowInc) / SUM(o.operationalAnnualCost) * 100, 2) AS DECIMAL(10, 2)) AS "Social Value %"
FROM [Metro.Operational] o
JOIN [Metro.Line] l ON o.lineId = l.lineId
JOIN [Metro.Classification] c ON l.classificationId = c.classificationId
GROUP BY c.classificationClass, c.classificationTier
ORDER BY c.classificationClass, c.classificationTier, "Social Value %" DESC;

-- Q2: How did cost recovery change from FY2022 to FY2024 for Commuter lines?
WITH base AS (
    SELECT 
        lp.lineId,
        t.timeFiscalYear,
        lp.linePerformanceCostRecovery
    FROM [Metro.Classification] c
    JOIN [Metro.Line] l
        ON c.classificationId = l.classificationId
    JOIN [Metro.LinePerformance] lp
        ON l.lineId = lp.lineId
    JOIN [Metro.Time] t
        ON lp.timeId = t.timeId
    WHERE c.ClassificationClass = 'Commuter'
      AND lp.linePerformanceCostRecovery IS NOT NULL),

perf AS (
    SELECT 
        lineId,
        timeFiscalYear,
        AVG(linePerformanceCostRecovery) AS avgCostRecovery
    FROM base
    GROUP BY lineId, timeFiscalYear),
fy22 AS (
    SELECT lineId, avgCostRecovery AS cost22
    FROM perf
    WHERE timeFiscalYear = '2022'),
fy23 AS (
    SELECT lineId, avgCostRecovery AS cost23
    FROM perf
    WHERE timeFiscalYear = '2023'),
fy24 AS (
    SELECT lineId, avgCostRecovery AS cost24
    FROM perf
    WHERE timeFiscalYear = '2024')
SELECT
    l.lineName AS "Line Name",
    CAST(ROUND(fy22.cost22, 2) AS DECIMAL(10,2)) AS "Cost Recovery 2022",
    CAST(ROUND(fy23.cost23, 2) AS DECIMAL(10,2)) AS "Cost Recovery 2023",
    CAST(ROUND(fy24.cost24, 2) AS DECIMAL(10,2)) AS "Cost Recovery 2024"
FROM [Metro.Line] l
JOIN fy22 ON l.lineId = fy22.lineId
JOIN fy23 ON l.lineId = fy23.lineId
JOIN fy24 ON l.lineId = fy24.lineId
ORDER BY l.lineName;




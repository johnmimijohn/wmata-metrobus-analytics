USE BUDT703_Project_0506_11
GO

-- Q1: How has on-time performance (OTP) changed by fiscal year and day type?
SELECT 
    t.timeFiscalYear AS [Fiscal Year],
    t.timeDayType AS [Day Type],
    CAST(ROUND(AVG(lp.linePerformanceOTP), 2) AS DECIMAL(10,2)) AS [Average OTP]
FROM [Metro.LinePerformance] lp
JOIN [Metro.Time] t ON lp.timeId = t.timeId
GROUP BY t.timeFiscalYear, t.timeDayType
ORDER BY t.timeFiscalYear, t.timeDayType

-- Q2: Are productivity metrics (Passengers per Revenue Mile) improving across classifications?
SELECT 
    t.timeFiscalYear AS [Fiscal Year],
    c.classificationClass AS [Classification],
    CAST(ROUND(AVG(lp.linePerformancePPRM), 2) AS DECIMAL(10,2)) AS [Average PPRM]
FROM [Metro.LinePerformance] lp
JOIN [Metro.Line] l ON lp.lineId = l.lineId
JOIN [Metro.Classification] c ON l.classificationId = c.classificationId
JOIN [Metro.Time] t ON lp.timeId = t.timeId
GROUP BY t.timeFiscalYear, c.classificationClass
ORDER BY t.timeFiscalYear, c.classificationClass



-- Q3: Are crowding factors trending up or down system-wide?
SELECT 
    t.timeFiscalYear AS [Fiscal Year],
    CAST(ROUND(AVG(lp.linePerformanceCrowding), 2) AS DECIMAL(10,2)) AS [Average Crowding Score]
FROM [Metro.LinePerformance] lp
JOIN [Metro.Time] t ON lp.timeId = t.timeId
GROUP BY t.timeFiscalYear
ORDER BY t.timeFiscalYear
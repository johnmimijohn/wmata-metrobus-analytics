--Is the on-time performance (OTP) metric target met by Framework lines in the fiscal year 2024, during weekdays?
SELECT e.lineName,CAST(ROUND( AVG(l.linePerformanceOTP),2)AS FLOAT) AS 'Average OTP Line Performance',CAST(ROUND( AVG(m.metricTargetOTP),2) AS FLOAT) AS 'Average OTP Line Performance metric target'
FROM [Metro.Classification] c, [Metro.LinePerformance] l, [Metro.Time] t,[Metro.Line] e, [Metro.MetricTarget] m
WHERE t.timeDayType IN ('Weekday')
   AND c.classificationClass = 'Framework'         
   AND c.classificationId = e.classificationId
   AND e.lineId = l.lineId
   AND t.timeId = l.timeId
   AND t.timeFiscalYear IN (2024)
GROUP BY e.lineId,e.lineName, t.timeFiscalYear, t.timeDayType
ORDER BY [Average OTP Line Performance] DESC


--What is the level of service fragility�measured by the percentage of operational time consumed by non-revenue Deadhead Hours�for Commuter, Framework and Coverage lines?
SELECT c.classificationClass AS 'Classification Class', t.timeFiscalYear, CAST( ROUND(100.0 * SUM(o.operationalDeadheadMiles) / (SUM(o.operationalDeadheadMiles) + SUM(o.operationalRevenueMiles)),  2 )  AS FLOAT) AS 'Percentage DeadheadMiles'
FROM [Metro.Classification] c, [Metro.Line] l, [Metro.Operational] o, [Metro.Time] t
WHERE c.classificationId = l.classificationId
  AND l.lineId = o.lineId AND o.timeId=t.timeId
  AND c.classificationClass IN ('Commuter', 'Framework','Coverage')
GROUP BY c.classificationClass, t.timeFiscalYear



--Do Framework lines meet the average target of line performance cost recovery within fiscal years 2022-2024?
SELECT t.timeFiscalYear,c.classificationClass AS 'Classification Class',CAST(ROUND (AVG(p.linePerformanceCostRecovery),2) AS FLOAT) AS 'Average Line Performance Cost Recovery',CAST(ROUND(AVG(m.metricTargetCostRecovery),2) AS FLOAT)  AS' Average Line Performance Cost Recovery Metric Target'
FROM [Metro.LinePerformance] p,[Metro.Line] l,[Metro.Classification] c,[Metro.Time] t,[Metro.MetricTarget] m
WHERE p.lineId = l.lineId
    AND l.classificationId = c.classificationId
    AND p.timeId = t.timeId
    AND m.classificationId = c.classificationId
    AND m.timeId = t.timeId
    AND t.timeFiscalYear IN (2022, 2023, 2024)
    AND c.classificationClass= 'Framework'
GROUP BY t.timeFiscalYear, c.classificationClass
ORDER BY t.timeFiscalYear, c.classificationClass






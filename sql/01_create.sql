USE BUDT703_Project_0506_11

CREATE TABLE [Metro.Classification] (
    classificationId CHAR(6) NOT NULL,
    classificationClass VARCHAR(10),
    classificationTier CHAR(1),
    CONSTRAINT pk_Classification_classificationId PRIMARY KEY (classificationId));

CREATE TABLE [Metro.Time] (
    timeId CHAR(7) NOT NULL,
    timeFiscalYear CHAR(4),
    timeDayType VARCHAR(8),
    CONSTRAINT pk_Time_timeId PRIMARY KEY (timeId));

CREATE TABLE [Metro.Line] (
    lineId CHAR(3) NOT NULL,
    lineName VARCHAR(50),
    lineJurisdiction CHAR(2),
    classificationId CHAR(6) NOT NULL,
    CONSTRAINT pk_Line_lineId PRIMARY KEY (lineId),
    CONSTRAINT fk_Line_classificationId FOREIGN KEY (classificationId)
        REFERENCES [Metro.Classification] (classificationId)
        ON DELETE NO ACTION ON UPDATE CASCADE);

CREATE TABLE [Metro.Route] (
    routeId CHAR(3) NOT NULL,
    routeName VARCHAR(3),
    lineId CHAR(3) NOT NULL,
    CONSTRAINT pk_Route_routeId PRIMARY KEY (routeId),
    CONSTRAINT fk_Route_lineId FOREIGN KEY (lineId)
        REFERENCES [Metro.Line] (lineId)
        ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE [Metro.MetricTarget] (
    timeId CHAR(7) NOT NULL,
    classificationId CHAR(6) NOT NULL,
    metricTargetSetId CHAR(5) NOT NULL,
    metricTargetPPRM DECIMAL(2,1),
    metricTargetOTP DECIMAL(3,2),
    metricTargetOpsCostperPAX DECIMAL(4,2),
    metricTargetCostRecovery DECIMAL(3,2),
    metricTargetStopsPerMileMin INT,
    metricTargetStopsPerMileMax INT,
    metricTargetCircuity DECIMAL(3,2),
    CONSTRAINT pk_MetricTarget_metricTargetSetId PRIMARY KEY (metricTargetSetId),
    CONSTRAINT fk_MetricTarget_classificationId FOREIGN KEY (classificationId)
        REFERENCES [Metro.Classification] (classificationId)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_MetricTarget_timeId FOREIGN KEY (timeId)
        REFERENCES [Metro.Time] (timeId)
        ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE [Metro.Operational] (    
    timeId CHAR(7) NOT NULL,
    lineId CHAR(3) NOT NULL,
    operationalId CHAR(5) NOT NULL,
    operationalAnnualCost DECIMAL(10,2),
    operationalPeakVehicles INT,
    operationalPopulation INT,
    operationalPopPOC INT,
    operationalPopLowInc INT,
    operationalStopsCount INT,
    operationalPctShelters DECIMAL(3,2),
    operationalPctBenches DECIMAL(3,2),
    operationalPctRTSigns DECIMAL(3,2),
    operationalRevenueMiles INT,
    operationalDeadheadMiles INT,
    operationalLineGrade CHAR(1),
    CONSTRAINT pk_Operational_operationalId PRIMARY KEY (operationalId),
    CONSTRAINT fk_Operational_lineId FOREIGN KEY (lineId)
        REFERENCES [Metro.Line] (lineId)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_Operational_timeId FOREIGN KEY (timeId)
        REFERENCES [Metro.Time] (timeId)
        ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE [Metro.LinePerformance] (
    timeId CHAR(7) NOT NULL,
    lineId CHAR(3) NOT NULL,
    linePerformanceId CHAR(5) NOT NULL,
    linePerformancePPRM DECIMAL(2,1),
    linePerformanceOTP DECIMAL(3,2),
    linePerformanceCrowding DECIMAL(3,2),
    linePerformanceOpsCostperPAX DECIMAL(4,2),
    linePerformanceCostRecovery DECIMAL(3,2),
    CONSTRAINT pk_LinePerformance_linePerformanceId PRIMARY KEY (linePerformanceId),
    CONSTRAINT fk_LinePerformance_timeId FOREIGN KEY (timeId)
        REFERENCES [Metro.Time] (timeId)
        ON DELETE CASCADE ON UPDATE CASCADE,
 CONSTRAINT fk_LinePerformance_lineId FOREIGN KEY (lineId)
        REFERENCES [Metro.Line] (lineId)
        ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE [Metro.RoutePerformance] (
    timeId CHAR(7) NOT NULL,
    routeId CHAR(3) NOT NULL,
    routePerformanceId CHAR(5) NOT NULL,
    routePerformancePPRM DECIMAL(2,1),
    routePerformanceOTP DECIMAL(3,2),
    routePerformanceCrowding DECIMAL(3,2),
    routePerformanceOpsCostperPAX DECIMAL(4,2),
    routePerformanceCostRecovery DECIMAL(3,2),
    routePerformanceStopsPerMile DECIMAL(2,1),
    routePerformanceCircuity DECIMAL(3,2),
    routePerformanceAvgDailyRidership INT,
    CONSTRAINT pk_RoutePerformance_routePerformanceId PRIMARY KEY (routePerformanceId),
    CONSTRAINT fk_RoutePerformance_timeId FOREIGN KEY (timeId)
        REFERENCES [Metro.Time] (timeId)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_RoutePerformance_routeId FOREIGN KEY (routeId)
        REFERENCES [Metro.Route] (routeId)
        ON DELETE CASCADE ON UPDATE CASCADE);

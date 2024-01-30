USE PROJEKT;

SELECT * FROM weatherdata;
SELECT * FROM weatherdatanoaa;
SELECT * FROM marinedatanoaa;

-- 1. Abfragemöglichkeit (zeitlich und örtlich einstellbare) Durchschnittserrechnung
SET @Monat = 1, @Tag = 10, @StationState = 'Alaska';

SELECT @StationState AS Ort, ROUND(AVG((WD_TemperatureMax - 32) * 5/9), 2) AS "Durchschnittstemperatur (Maximum) in Celsius", ROUND(AVG((WD_TemperatureMin - 32) * 5/9), 2) AS "Durchschnittstemperatur (Minimum) in Celsius"
FROM weatherdata
WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState;

-- "Tendenzentwicklung" erzeugt aus 1. Abfragemöglichkeit
SET @Monat = 1, @Tag = 10, @StationState = 'Alaska';

SELECT 
    ROUND(AVG((WD_TemperatureMax - 32) * 5/9), 2) AS "Durchschnittstemperatur (Maximum) in Celsius",
    ROUND(AVG((WD_TemperatureMin - 32) * 5/9), 2) AS "Durchschnittstemperatur (Minimum) in Celsius",
    AVG(CASE WHEN WD_TemperatureMax > (SELECT AVG(WD_TemperatureMax) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN 1
             WHEN WD_TemperatureMax < (SELECT AVG(WD_TemperatureMax) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN -1
             ELSE 0 END) AS "Tendenz (Maximum)",
    AVG(CASE WHEN WD_TemperatureMin > (SELECT AVG(WD_TemperatureMin) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN 1
             WHEN WD_TemperatureMin < (SELECT AVG(WD_TemperatureMin) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN -1
             ELSE 0 END) AS "Tendenz (Minimum)"
FROM weatherdata
WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState;

-- 2. Abfragemöglichkeit Zusammenfassung des Niederschlags in Inches
SELECT ROUND(SUM(WD_Rain * 25.4 / 1000), 2) AS "Gesamtmenge des Regens (Liter)" FROM weatherdata;

-- "Tendenz" auf Regen / Schnee
SET @Monat = 1, @Tag = 10, @StationState = 'Alaska';

SELECT @StationState AS Ort,
    ROUND(AVG((WD_TemperatureMax - 32) * 5/9), 2) AS "Durchschnittstemperatur (Maximum) in Celsius",
    ROUND(AVG((WD_TemperatureMin - 32) * 5/9), 2) AS "Durchschnittstemperatur (Minimum) in Celsius",
    AVG(CASE WHEN WD_TemperatureMax > (SELECT AVG(WD_TemperatureMax) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN 1
             WHEN WD_TemperatureMax < (SELECT AVG(WD_TemperatureMax) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN -1
             ELSE 0 END) AS "Tendenz (Maximum)",
    AVG(CASE WHEN WD_TemperatureMin > (SELECT AVG(WD_TemperatureMin) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN 1
             WHEN WD_TemperatureMin < (SELECT AVG(WD_TemperatureMin) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN -1
             ELSE 0 END) AS "Tendenz (Minimum)",
    AVG(CASE WHEN WD_Rain > (SELECT AVG(WD_Rain) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN 1
             WHEN WD_Rain < (SELECT AVG(WD_Rain) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN -1
             ELSE 0 END) AS "Tendenz (Regen)",
    CASE 
        WHEN AVG(CASE WHEN WD_Rain > (SELECT AVG(WD_Rain) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN 1
                     WHEN WD_Rain < (SELECT AVG(WD_Rain) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN -1
                     ELSE 0 END) > 0 THEN 'wahrscheinlich'
        WHEN AVG(CASE WHEN WD_Rain > (SELECT AVG(WD_Rain) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN 1
                     WHEN WD_Rain < (SELECT AVG(WD_Rain) FROM weatherdata WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState) THEN -1
                     ELSE 0 END) < 0 THEN 'nicht wahrscheinlich'
        ELSE 'neutral'
    END AS "Tendenz-Wort(Regen)"
FROM weatherdata
WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState;


-- Korrelation von weatherdata
DELIMITER $$
 
CREATE PROCEDURE CalcCorrelation(IN tbl_name VARCHAR(64), IN col1_name VARCHAR(64), IN col2_name VARCHAR(64))
BEGIN
    SET @s = CONCAT('SELECT (COUNT(*) * SUM(', col1_name, ' * ', col2_name, ') - SUM(', col1_name, ') * SUM(', col2_name, ')) / 
                        (SQRT((COUNT(*) * SUM(', col1_name, ' * ', col1_name, ') - SUM(', col1_name, ') * SUM(', col1_name, ')) *
                              (COUNT(*) * SUM(', col2_name, ' * ', col2_name, ') - SUM(', col2_name, ') * SUM(', col2_name, ')))) AS Correlation FROM ', tbl_name, ';');
 
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
 
DELIMITER;
DROP PROCEDURE CalcCorrelation;
 
 
CALL CalcCorrelation('weatherdata', 'WD_TemperatureAvg', 'WD_WindSpeed');
CALL CalcCorrelation('weatherdata', 'WD_TemperatureMax', 'WD_TemperatureMin');
CALL CalcCorrelation('weatherdata', 'WD_TemperatureMax', 'WD_Rain');
CALL CalcCorrelation('weatherdata', 'WD_TemperatureMin', 'WD_Rain');


-- Windrichtungsangabe + Windgeschwindigkeit (+Einschätzung)
SELECT 
    WD_WindDirection, 
    CASE 
        WHEN WD_WindDirection = 00 THEN 'Calm (no motion for dsds, or no waves)'
        WHEN WD_WindDirection = 36 THEN 'Nord'
        WHEN WD_WindDirection > 27 AND WD_WindDirection < 36 THEN 'Nord-Nordwest'
        WHEN WD_WindDirection = 09 THEN 'Ost'
        WHEN WD_WindDirection > 0 AND WD_WindDirection < 09 THEN 'Nord-Ost'
        WHEN WD_WindDirection = 18 THEN 'Süd'
        WHEN WD_WindDirection > 09 AND WD_WindDirection < 18 THEN 'Ost-Südost'
        WHEN WD_WindDirection = 27 THEN 'West'
        WHEN WD_WindDirection > 18 AND WD_WindDirection <= 27 THEN 'Südwest'
        ELSE 'Unbekannt'  -- Oder eine andere entsprechende Nachricht für unbekannte Werte
    END AS Windrichtung, ROUND(WD_WindSpeed * 1.60934, 2) AS Windgeschwindigkeit_kmh,
	CASE 
        WHEN WD_WindSpeed < 5 THEN 'Schwach'
        WHEN WD_WindSpeed >= 5 AND WD_WindSpeed < 10 THEN 'Mäßig'
        WHEN WD_WindSpeed >= 10 AND WD_WindSpeed < 20 THEN 'Stark'
        WHEN WD_WindSpeed >= 20 THEN 'Sehr stark'
        ELSE 'Unbekannt'
    END AS Windgeschwindigkeit_Einschätzung
FROM weatherdata;

-- Umwandlung in View
CREATE VIEW WeatherDataView AS
SELECT 
    WD_WindDirection, 
    CASE 
        WHEN WD_WindDirection = 00 THEN 'Calm (no motion for dsds, or no waves)'
        WHEN WD_WindDirection = 36 THEN 'Nord'
        WHEN WD_WindDirection > 27 AND WD_WindDirection < 36 THEN 'Nord-Nordwest'
        WHEN WD_WindDirection = 09 THEN 'Ost'
        WHEN WD_WindDirection > 0 AND WD_WindDirection < 09 THEN 'Nord-Ost'
        WHEN WD_WindDirection = 18 THEN 'Süd'
        WHEN WD_WindDirection > 09 AND WD_WindDirection < 18 THEN 'Ost-Südost'
        WHEN WD_WindDirection = 27 THEN 'West'
        WHEN WD_WindDirection > 18 AND WD_WindDirection <= 27 THEN 'Südwest'
        ELSE 'Unbekannt'
    END AS Windrichtung, 
    ROUND(WD_WindSpeed * 1.60934, 2) AS Windgeschwindigkeit_kmh,
    CASE 
        WHEN WD_WindSpeed < 5 THEN 'Schwach'
        WHEN WD_WindSpeed >= 5 AND WD_WindSpeed < 10 THEN 'Mäßig'
        WHEN WD_WindSpeed >= 10 AND WD_WindSpeed < 20 THEN 'Stark'
        WHEN WD_WindSpeed >= 20 THEN 'Sehr stark'
        ELSE 'Unbekannt'
    END AS Windgeschwindigkeit_Einschätzung, WD_DateMonth, WD_DateDay, WD_StationState
FROM weatherdata;

-- Windrichtungstendenz
SET @Monat = 1, @Tag = 10, @StationState = 'Alaska';

SELECT @StationState AS Ort, 
    AVG(CASE 
        WHEN Windrichtung = 'Nord' THEN 1
        WHEN Windrichtung = 'Nord-Nordwest' THEN -1
        WHEN Windrichtung = 'Ost' THEN 2
        WHEN Windrichtung = 'Nord-Ost' THEN -2
        WHEN Windrichtung = 'Süd' THEN 3
        WHEN Windrichtung = 'Ost-Südost' THEN -3
        WHEN Windrichtung = 'West' THEN 4
        WHEN Windrichtung = 'Südwest' THEN -4
        -- Fügen Sie hier weitere Bedingungen für andere Windrichtungen hinzu
        ELSE 0
    END) AS "Tendenz Windrichtung"
FROM WeatherDataView
WHERE WD_DateMonth = @Monat AND WD_DateDay = @Tag AND WD_StationState = @StationState;











###############
-- Weitere Möglichkeiten
###############

-- Verknüpfung von NOAA (weatherdatanoaa und marinedatanoaa)
-- Aggregation für marinedatanoaa
SELECT CONCAT(MDNOAA_Latitude, ', ', MDNOAA_Longitude) AS Location, AVG(MDNOAA_AirTemperature) AS AvgMarineAirTemperature
FROM marinedatanoaa
GROUP BY MDNOAA_Latitude, MDNOAA_Longitude;

-- Aggregation für weatherdatanoaa
SELECT CONCAT(WDNOAA2_Latitude, ', ', WDNOAA2_Longitude) AS Location, AVG(WDNOAA2_TMAX - WDNOAA2_TMIN) AS AvgWeatherTemperature 
FROM weatherdatanoaa
GROUP BY WDNOAA2_Latitude, WDNOAA2_Longitude;

-- Kombination beider Aggregationen
SELECT CONCAT(MDNOAA_Latitude, ', ', MDNOAA_Longitude) AS Location, AVG(MDNOAA_AirTemperature) AS AvgAirTemperature, NULL AS AvgTemperature
FROM marinedatanoaa
GROUP BY MDNOAA_Latitude, MDNOAA_Longitude

UNION ALL

SELECT CONCAT(WDNOAA2_Latitude, ', ', WDNOAA2_Longitude) AS Location, NULL AS AvgAirTemperature, AVG(WDNOAA2_TMAX - WDNOAA2_TMIN) AS AvgTemperature 
FROM weatherdatanoaa
GROUP BY WDNOAA2_Latitude, WDNOAA2_Longitude;
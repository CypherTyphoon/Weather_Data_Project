CREATE DATABASE IF NOT EXISTS Projekt;

USE PROJEKT;

-- Erzeugung der Datentabelle 1: Datenquelle: https://corgis-edu.github.io/corgis/csv/weather/
CREATE TABLE IF NOT EXISTS Weatherdata(
WD_ID INT AUTO_INCREMENT PRIMARY KEY,
WD_Rain FLOAT,
WD_DateFull DATE,
WD_DateMonth INT,
WD_DateDay INT,
WD_DateYear INT,
WD_StationCity VARCHAR (48),
WD_StationCode VARCHAR (3),
WD_StationLocation VARCHAR (32),
WD_StationState VARCHAR (20),
WD_TemperatureAvg INT,
WD_TemperatureMax INT,
WD_TemperatureMin INT,
WD_WindDirection INT,
WD_WindSpeed FLOAT
);


SHOW GLOBAL VARIABLES LIKE 'local_infile'; -- Validierung der Sicherheitseinstellungen
SET GLOBAL local_infile = 1; -- setzen der Sicherheitseinstellungen für "LOAD DATA INFILE"

SHOW VARIABLES LIKE "secure_file_priv"; -- prüfen der Pfad-Angabe für "sichere" Dateien"

-- Laden der Daten aus einer CSV heraus
LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.2//Uploads//corgis_weekly_2016_weather.csv'
INTO TABLE Weatherdata
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(WD_Rain, WD_DateFull, WD_DateMonth, WD_DateDay, WD_DateYear, WD_StationCity, WD_StationCode,
WD_StationLocation, WD_StationState, WD_TemperatureAvg, WD_TemperatureMax, WD_TemperatureMin, WD_WindDirection, WD_WindSpeed);

SELECT * FROM weatherdata;


-- Erzeugung der Datentabelle 2: Datenquelle: https://www.ncei.noaa.gov/cdo-web/datasets
	-- Global Daily Summaries
CREATE TABLE IF NOT EXISTS WeatherdataNOAA(
WDNOAA2_ID INT AUTO_INCREMENT PRIMARY KEY,
WDNOAA2_STATIONNETWORKCODE VARCHAR (10),
WDNOAA2_STATIONCODE VARCHAR (20),
WDNOAA2_STATION_NAME VARCHAR(50),
WDNOAA2_STATION_NAMESHORTS VARCHAR (12),
WDNOAA2_ELEVATION FLOAT,
WDNOAA2_LATITUDE FLOAT,
WDNOAA2_LONGITUDE FLOAT,
WDNOAA2_DATE DATE,
WDNOAA2_TMAX INT,
WDNOAA2_TMIN INT,
WDNOAA2_PRCP FLOAT
);

LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.2//Uploads//GHCND_sample_dailysummaries_csv.csv'
INTO TABLE WeatherdataNOAA
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@station, @station_name, WDNOAA2_ELEVATION, WDNOAA2_LATITUDE, WDNOAA2_LONGITUDE, WDNOAA2_DATE, WDNOAA2_TMAX, WDNOAA2_TMIN, WDNOAA2_PRCP)
SET 
    WDNOAA2_STATIONNETWORKCODE = SUBSTRING_INDEX(@station, ':', 1),
    WDNOAA2_STATIONCODE = SUBSTRING_INDEX(@station, ':', -1),
    WDNOAA2_STATION_NAME = SUBSTRING_INDEX(@station_name, ' ', 2),
    WDNOAA2_STATION_NAMESHORTS = TRIM(SUBSTR(@station_name, INSTR(@station_name, '2') + 1));

SELECT * FROM WeatherdataNOAA;


-- Erzeugung der Datentabelle 3: Datenquelle: https://www.ncei.noaa.gov/cdo-web/datasets
	-- Global Marine Data
CREATE TABLE IF NOT EXISTS MarinedataNOAA(
MDNOAA_ID INT AUTO_INCREMENT PRIMARY KEY,
MDNOAA_Identification VARCHAR (5),
MDNOAA_Latitude FLOAT,
MDNOAA_Longitude FLOAT,
MDNOAA_DateObservation DATE,
MDNOAA_TimeObservation TIME,
MDNOAA_IceAccretionShip VARCHAR(1),
MDNOAA_ThicknessIceAccretionShip VARCHAR(4),
MDNOAA_RateIceAccretionShip VARCHAR(1),
MDNOAA_SeaLevelPressure VARCHAR (8),
MDNOAA_CharacteristicsPressureTendency VARCHAR(1),
MDNOAA_PressureTendency VARCHAR (8),
MDNOAA_AirTemperature VARCHAR (8),
MDNOAA_WetBulbTemperature VARCHAR(5),
MDNOAA_DewPointTemperature VARCHAR (8),
MDNOAA_SeaSurfaceTemperature VARCHAR(5),
MDNOAA_WaveDirection VARCHAR(2),
MDNOAA_WavePeriod VARCHAR(2),
MDNOAA_WaveHeight VARCHAR (2),
MDNOAA_SwellDirection VARCHAR (2),
MDNOAA_SwellPeriod VARCHAR (2),
MDNOAA_SwellHeight VARCHAR (2),
MDNOAA_TotalCloudAmount VARCHAR (1),
MDNOAA_LowCloudAmount VARCHAR (2),
MDNOAA_LowCloudType VARCHAR (1),
MDNOAA_CloudHeightIndicator VARCHAR (1),
MDNOAA_CloudHeight VARCHAR (1),
MDNOAA_MiddleCloudType VARCHAR (1),
MDNOAA_HighCloudType VARCHAR (1),
MDNOAA_Visibility VARCHAR (2),
MDNOAA_VisibilityIndicator VARCHAR (2),
MDNOAA_PresentWeather VARCHAR (2),
MDNOAA_PastWeather VARCHAR (1),
MDNOAA_WindDirection VARCHAR (3),
MDNOAA_WindSpeed VARCHAR (3)
);

LOAD DATA INFILE 'C://ProgramData//MySQL//MySQL Server 8.2//Uploads//Marine_CSV_global_marine_sample.csv'
INTO TABLE MarinedataNOAA
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(MDNOAA_Identification, MDNOAA_Latitude, MDNOAA_Longitude, @observation_datetime, MDNOAA_IceAccretionShip,
 MDNOAA_ThicknessIceAccretionShip, MDNOAA_RateIceAccretionShip, MDNOAA_SeaLevelPressure, MDNOAA_CharacteristicsPressureTendency,
 MDNOAA_PressureTendency, MDNOAA_AirTemperature, MDNOAA_WetBulbTemperature, MDNOAA_DewPointTemperature, MDNOAA_SeaSurfaceTemperature,
 MDNOAA_WaveDirection, MDNOAA_WavePeriod, MDNOAA_WaveHeight, MDNOAA_SwellDirection, MDNOAA_SwellPeriod, MDNOAA_SwellHeight,
 MDNOAA_TotalCloudAmount, MDNOAA_LowCloudAmount, MDNOAA_LowCloudType, MDNOAA_CloudHeightIndicator, MDNOAA_CloudHeight,
 MDNOAA_MiddleCloudType, MDNOAA_HighCloudType, MDNOAA_Visibility, MDNOAA_VisibilityIndicator, MDNOAA_PresentWeather,
 MDNOAA_PastWeather, MDNOAA_WindDirection, MDNOAA_WindSpeed)
SET MDNOAA_DateObservation = STR_TO_DATE(SUBSTRING_INDEX(@observation_datetime, 'T', 1), '%Y-%m-%d'),
    MDNOAA_TimeObservation = SUBSTRING_INDEX(@observation_datetime, 'T', -1);

SELECT * FROM MarinedataNOAA;
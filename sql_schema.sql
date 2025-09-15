DROP TABLE IF EXISTS collisions;
CREATE TABLE collisions (
    ObjectId INT PRIMARY KEY,
    Geo_ID VARCHAR(50),
    Accident_Year INT,
    Accident_Date DATE,
    Accident_Time TIME,
    Location VARCHAR(255),
    Location_Type VARCHAR(100),
    Classification_Of_Accident VARCHAR(100),
    Initial_Impact_Type VARCHAR(100),
    Road_Surface_Condition VARCHAR(100),
    Environment_Condition VARCHAR(100),
    Light VARCHAR(50),
    Traffic_Control VARCHAR(100),
    Num_of_Vehicle INT,
    Num_Of_Pedestrians INT,
    Num_of_Bicycles INT,
    Num_of_Motorcycles INT,
    Max_Injury VARCHAR(50),
    Num_of_Injuries INT,
    Num_of_Minimal_Injuries INT,
    Num_of_Minor_Injuries INT,
    Num_of_Major_Injuries INT,
    Num_of_Fatal_Injuries INT,
    X_Coordinate DECIMAL(12,4),
    Y_Coordinate DECIMAL(12,4),
    Lat DECIMAL(10,6),
    Longitude DECIMAL(10,6)
);


COPY collisions
FROM
'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\Traffic_Collision_Data.csv'
DELIMITER ',' CSV HEADER;
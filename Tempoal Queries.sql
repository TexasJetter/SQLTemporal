DECLARE @Id1 UNIQUEIDENTIFIER = '7b93789a-18c3-4ea1-b612-383b81e65876';
DECLARE @Id2 UNIQUEIDENTIFIER = 'e23273d7-a7cb-4884-9158-9d67841436e6';

-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
---- Standard SQL table with no Temporal aspect. 
---- Note that when we change a record we have no history of what came before
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--CREATE TABLE Department
--(
--    DeptID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY NonCLUSTERED DEFAULT (NewId())
--  , DeptName NVARCHAR(50) NOT NULL DEFAULT('')
--  , UpdatedBy NVARCHAR(50) NOT NULL DEFAULT('')
--)

--INSERT INTO Department ([DeptID] ,[DeptName] ,[UpdatedBy]) VALUES (@Id1, 'Sales', 'Jeff') 
--INSERT INTO Department ([DeptID] ,[DeptName] ,[UpdatedBy]) VALUES (@Id2, 'Production', 'Jeff') 
--WAITFOR DELAY '00:00:02'; -- 2 Seconds
--UPDATE Department SET DeptName = 'Magic', UpdatedBy = 'Merlin' WHERE DeptId = @Id2


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
---- SQL table with Anonymous History table. 
---- Note the randomly assigned History table name
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--CREATE TABLE Department_Temporal_Anonymous 
--(
--    DeptID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY NonCLUSTERED DEFAULT (NewId())
--  , DeptName NVARCHAR(50) NOT NULL DEFAULT('')
--  , UpdatedBy NVARCHAR(50) NOT NULL DEFAULT('')
--  , SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL
--  , SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL
--  , PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime)
--)
--WITH (SYSTEM_VERSIONING = ON);

--INSERT INTO Department_Temporal_Anonymous ([DeptID] ,[DeptName] ,[UpdatedBy]) VALUES (@Id1, 'Sales', 'Jeff') 
--INSERT INTO Department_Temporal_Anonymous ([DeptID] ,[DeptName] ,[UpdatedBy]) VALUES (@Id2, 'Production', 'Jeff') 
--WAITFOR DELAY '00:00:02'; -- 2 Seconds
--UPDATE Department_Temporal_Anonymous SET DeptName = 'Magic', UpdatedBy = 'Merlin' WHERE DeptId = @Id2


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
---- SQL table with Named History table. 
---- Note the defined History table name
---- Also note we added the key word HIDDEN when creating the Sys columns. 
---- This means that we will not see them in a Select * query, we must explicity ask for them.
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
--CREATE TABLE Department_Temporal_Default
--(
--    DeptID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY NonCLUSTERED DEFAULT (NewId())
--  , DeptName NVARCHAR(50) NOT NULL DEFAULT('')
--  , UpdatedBy NVARCHAR(50) NOT NULL DEFAULT('')
--  , SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
--  , SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
--  , PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime)
--)
--WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.DepartmentHistory));

--INSERT INTO Department_Temporal_Default ([DeptID] ,[DeptName] ,[UpdatedBy]) VALUES (@Id1, 'Sales', 'Jeff') 
--INSERT INTO Department_Temporal_Default ([DeptID] ,[DeptName] ,[UpdatedBy]) VALUES (@Id2, 'Production', 'Jeff') 
--WAITFOR DELAY '00:00:02'; -- 2 Seconds
--UPDATE Department_Temporal_Default SET DeptName = 'Magic', UpdatedBy = 'Merlin' WHERE DeptId = @Id2


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
---- Quering a Temporal Table
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------
---- A standard Select * query only shows the current records.
---- Since we created the Sys columns with the HIDDEN option they do not show
-------------------------------------------------------------------------------------------------
--SELECT * FROM [Department_Temporal_Default]

-------------------------------------------------------------------------------------------------
---- If we want to see historical data we add the key phrase FOR SYSTEM_TIME __
---- Where __ can be:
---- ALL
---- FROM <start_date_time> TO <end_date_time>
---- BETWEEN <start_date_time> AND <end_date_time>
---- CONTAINED IN (<start_date_time> , <end_date_time>)
-------------------------------------------------------------------------------------------------
--SELECT *
--  FROM [Temporal_Testbed].[dbo].[Department_Temporal_Default]
--	FOR SYSTEM_TIME AS OF '2021-07-07 13:49:45.1669939' --<<<<<<<<<<<<<<< Change date based on inserted data...
--Order by SysStartTime Desc

--SELECT *, SysStartTime, SysEndTime
--  FROM [Temporal_Testbed].[dbo].[Department_Temporal_Default]
--	FOR SYSTEM_TIME ALL 
--Order by SysStartTime Desc



-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- Once SYSTEM_VERSIONING is on SSMS will no longer show options to modify the table schema
-- Right clicking on the table no longer shows DESIGN or DELETE menu items
-- Table schema changes must be done using a ALTER TABLE query
-------------------------------------------------------------------------------------------------
--ALTER TABLE Department_Temporal_Default
--	ALTER COLUMN DeptName NVARCHAR(100)

-------------------------------------------------------------------------------------------------
-- If you add a NOT NULL column you MUST provide a default constraint
-- ALL historical data will be backfilled with the default value
-------------------------------------------------------------------------------------------------
--ALTER TABLE Department_Temporal_Default
--	ADD DeptLocation NVARCHAR(100) NOT NULL
--	CONSTRAINT DF_Department_Temporal_Default_DeptLocation DEFAULT 'Houston'

-------------------------------------------------------------------------------------------------
-- Some operations require you to turn the SYSTEM_VERSIONING off
-- Adding a computed or IDENTIY column or Deleting the table are a few examples
-------------------------------------------------------------------------------------------------
--ALTER TABLE Department_Temporal_Anonymous SET (SYSTEM_VERSIONING = OFF)
--DROP TABLE Department_Temporal_Anonymous
--GO
--DROP TABLE MSSQL_TemporalHistoryFor_XXXXX

-------------------------------------------------------------------------------------------------
-- Turrning SYSTEM_VERSIONING OFF "un joins" the tables and they can be see
-- as separate tables in SMS
-------------------------------------------------------------------------------------------------
--ALTER TABLE Department_Temporal_Default SET (SYSTEM_VERSIONING = OFF)

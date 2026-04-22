-- ═══════════════════════════════════════════════════════
--  CrimeLens India — SQL Server Setup Script
--  Run this in SQL Server Management Studio (SSMS)
-- ═══════════════════════════════════════════════════════

-- 1. Create database (skip if already exists)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'CrimeDB')
    CREATE DATABASE CrimeDB;
GO

USE CrimeDB;
GO

-- 2. Create crimes table
IF OBJECT_ID('crimes', 'U') IS NOT NULL
    DROP TABLE crimes;
GO

CREATE TABLE crimes (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    state       NVARCHAR(100)     NOT NULL,
    district    NVARCHAR(100)     NOT NULL,
    crime_type  NVARCHAR(100)     NOT NULL,
    crime_rate  FLOAT             NOT NULL,   -- rate per 100,000 population
    crime_count INT               NULL,       -- raw incident count
    severity    NVARCHAR(10)      NOT NULL    -- 'HIGH', 'MEDIUM', 'LOW'
        CHECK (severity IN ('HIGH','MEDIUM','LOW')),
    year        INT               NOT NULL DEFAULT 2013
);
GO

-- 3. Index for fast lookups
CREATE INDEX idx_crimes_lookup
    ON crimes (state, district, crime_type);
GO


-- ═══════════════════════════════════════════════════════
--  HOW TO MATCH YOUR EXISTING TABLE
--  If your table is named differently, just change the
--  column names in app.py to match yours. The query is:
--
--    SELECT crime_rate, severity, crime_count
--    FROM   <your_table>
--    WHERE  state = ? AND district = ? AND crime_type = ?
--
--  Minimum required columns:
--    state       → state name  (TEXT)
--    district    → district    (TEXT)
--    crime_type  → type label  (TEXT)
--    crime_rate  → numeric     (FLOAT or INT)
--    severity    → HIGH/MEDIUM/LOW (TEXT)
-- ═══════════════════════════════════════════════════════


-- 4. Sample data (Maharashtra) — replace with your actual data
INSERT INTO crimes (state, district, crime_type, crime_rate, crime_count, severity) VALUES
-- Maharashtra
('Maharashtra', 'Mumbai',     'Murder',           4.2,  512,  'MEDIUM'),
('Maharashtra', 'Mumbai',     'Rape',             8.1,  987,  'HIGH'),
('Maharashtra', 'Mumbai',     'Robbery',          12.4, 1512, 'HIGH'),
('Maharashtra', 'Mumbai',     'Kidnapping',       6.3,  768,  'MEDIUM'),
('Maharashtra', 'Mumbai',     'Assault on Women', 9.8,  1193, 'HIGH'),
('Maharashtra', 'Mumbai',     'Dowry Deaths',     1.2,  146,  'LOW'),
('Maharashtra', 'Mumbai',     'Burglary',         14.1, 1718, 'HIGH'),
('Maharashtra', 'Mumbai',     'Theft',            22.3, 2718, 'HIGH'),
('Maharashtra', 'Mumbai',     'Riots',            3.1,  378,  'LOW'),
('Maharashtra', 'Mumbai',     'Dacoity',          2.2,  268,  'LOW'),

('Maharashtra', 'Pune',       'Murder',           2.8,  341,  'LOW'),
('Maharashtra', 'Pune',       'Rape',             5.4,  658,  'MEDIUM'),
('Maharashtra', 'Pune',       'Robbery',          8.7,  1060, 'MEDIUM'),
('Maharashtra', 'Pune',       'Kidnapping',       4.1,  500,  'MEDIUM'),
('Maharashtra', 'Pune',       'Assault on Women', 6.2,  756,  'MEDIUM'),
('Maharashtra', 'Pune',       'Dowry Deaths',     0.9,  110,  'LOW'),
('Maharashtra', 'Pune',       'Burglary',         10.2, 1244, 'HIGH'),
('Maharashtra', 'Pune',       'Theft',            16.8, 2049, 'HIGH'),
('Maharashtra', 'Pune',       'Riots',            2.1,  256,  'LOW'),
('Maharashtra', 'Pune',       'Dacoity',          1.5,  183,  'LOW'),

('Maharashtra', 'Nagpur',     'Murder',           3.6,  439,  'MEDIUM'),
('Maharashtra', 'Nagpur',     'Rape',             6.9,  841,  'MEDIUM'),
('Maharashtra', 'Nagpur',     'Robbery',          10.1, 1232, 'HIGH'),
('Maharashtra', 'Nagpur',     'Kidnapping',       5.2,  634,  'MEDIUM'),
('Maharashtra', 'Nagpur',     'Assault on Women', 7.8,  951,  'MEDIUM'),
('Maharashtra', 'Nagpur',     'Dowry Deaths',     2.1,  256,  'LOW'),
('Maharashtra', 'Nagpur',     'Burglary',         11.3, 1378, 'HIGH'),
('Maharashtra', 'Nagpur',     'Theft',            18.2, 2219, 'HIGH'),
('Maharashtra', 'Nagpur',     'Riots',            4.2,  512,  'MEDIUM'),
('Maharashtra', 'Nagpur',     'Dacoity',          1.8,  219,  'LOW'),

('Maharashtra', 'Aurangabad', 'Murder',           5.1,  622,  'MEDIUM'),
('Maharashtra', 'Aurangabad', 'Rape',             7.3,  890,  'HIGH'),
('Maharashtra', 'Aurangabad', 'Robbery',          9.4,  1146, 'MEDIUM'),
('Maharashtra', 'Aurangabad', 'Kidnapping',       4.8,  585,  'MEDIUM'),
('Maharashtra', 'Aurangabad', 'Assault on Women', 8.9,  1085, 'HIGH'),
('Maharashtra', 'Aurangabad', 'Dowry Deaths',     3.2,  390,  'MEDIUM'),
('Maharashtra', 'Aurangabad', 'Burglary',         9.8,  1195, 'MEDIUM'),
('Maharashtra', 'Aurangabad', 'Theft',            15.4, 1878, 'HIGH'),
('Maharashtra', 'Aurangabad', 'Riots',            5.6,  683,  'MEDIUM'),
('Maharashtra', 'Aurangabad', 'Dacoity',          2.4,  293,  'LOW'),

-- Delhi
('Delhi', 'Central Delhi',   'Murder',           7.2,  878,  'HIGH'),
('Delhi', 'Central Delhi',   'Rape',             14.8, 1805, 'HIGH'),
('Delhi', 'Central Delhi',   'Robbery',          18.3, 2231, 'HIGH'),
('Delhi', 'Central Delhi',   'Kidnapping',       12.1, 1476, 'HIGH'),
('Delhi', 'Central Delhi',   'Assault on Women', 16.2, 1976, 'HIGH'),
('Delhi', 'Central Delhi',   'Dowry Deaths',     4.3,  524,  'MEDIUM'),
('Delhi', 'Central Delhi',   'Burglary',         20.1, 2452, 'HIGH'),
('Delhi', 'Central Delhi',   'Theft',            28.6, 3489, 'HIGH'),
('Delhi', 'Central Delhi',   'Riots',            6.4,  780,  'MEDIUM'),
('Delhi', 'Central Delhi',   'Dacoity',          5.1,  622,  'MEDIUM'),

('Delhi', 'South Delhi',     'Murder',           4.1,  500,  'MEDIUM'),
('Delhi', 'South Delhi',     'Rape',             9.2,  1122, 'HIGH'),
('Delhi', 'South Delhi',     'Robbery',          11.4, 1390, 'HIGH'),
('Delhi', 'South Delhi',     'Kidnapping',       7.8,  951,  'MEDIUM'),
('Delhi', 'South Delhi',     'Assault on Women', 10.3, 1256, 'HIGH'),
('Delhi', 'South Delhi',     'Dowry Deaths',     2.8,  341,  'LOW'),
('Delhi', 'South Delhi',     'Burglary',         14.2, 1732, 'HIGH'),
('Delhi', 'South Delhi',     'Theft',            21.3, 2598, 'HIGH'),
('Delhi', 'South Delhi',     'Riots',            3.2,  390,  'MEDIUM'),
('Delhi', 'South Delhi',     'Dacoity',          3.1,  378,  'MEDIUM'),

('Delhi', 'North Delhi',     'Murder',           6.8,  829,  'HIGH'),
('Delhi', 'North Delhi',     'Rape',             13.1, 1598, 'HIGH'),
('Delhi', 'North Delhi',     'Robbery',          16.2, 1976, 'HIGH'),
('Delhi', 'North Delhi',     'Kidnapping',       10.4, 1268, 'HIGH'),
('Delhi', 'North Delhi',     'Assault on Women', 14.7, 1793, 'HIGH'),
('Delhi', 'North Delhi',     'Dowry Deaths',     5.1,  622,  'MEDIUM'),
('Delhi', 'North Delhi',     'Burglary',         18.3, 2231, 'HIGH'),
('Delhi', 'North Delhi',     'Theft',            25.4, 3098, 'HIGH'),
('Delhi', 'North Delhi',     'Riots',            7.2,  878,  'HIGH'),
('Delhi', 'North Delhi',     'Dacoity',          4.6,  561,  'MEDIUM'),

-- Uttar Pradesh
('Uttar Pradesh', 'Lucknow',  'Murder',           8.9,  1085, 'HIGH'),
('Uttar Pradesh', 'Lucknow',  'Rape',             11.2, 1366, 'HIGH'),
('Uttar Pradesh', 'Lucknow',  'Robbery',          15.4, 1878, 'HIGH'),
('Uttar Pradesh', 'Lucknow',  'Kidnapping',       13.2, 1610, 'HIGH'),
('Uttar Pradesh', 'Lucknow',  'Assault on Women', 12.8, 1561, 'HIGH'),
('Uttar Pradesh', 'Lucknow',  'Dowry Deaths',     8.4,  1024, 'HIGH'),
('Uttar Pradesh', 'Lucknow',  'Burglary',         16.1, 1964, 'HIGH'),
('Uttar Pradesh', 'Lucknow',  'Theft',            20.3, 2476, 'HIGH'),
('Uttar Pradesh', 'Lucknow',  'Riots',            9.1,  1110, 'HIGH'),
('Uttar Pradesh', 'Lucknow',  'Dacoity',          7.2,  878,  'HIGH'),

('Uttar Pradesh', 'Agra',     'Murder',           7.4,  902,  'HIGH'),
('Uttar Pradesh', 'Agra',     'Rape',             9.8,  1195, 'HIGH'),
('Uttar Pradesh', 'Agra',     'Robbery',          13.2, 1610, 'HIGH'),
('Uttar Pradesh', 'Agra',     'Kidnapping',       11.4, 1390, 'HIGH'),
('Uttar Pradesh', 'Agra',     'Assault on Women', 10.6, 1293, 'HIGH'),
('Uttar Pradesh', 'Agra',     'Dowry Deaths',     7.1,  866,  'HIGH'),
('Uttar Pradesh', 'Agra',     'Burglary',         14.3, 1744, 'HIGH'),
('Uttar Pradesh', 'Agra',     'Theft',            18.6, 2268, 'HIGH'),
('Uttar Pradesh', 'Agra',     'Riots',            8.2,  1000, 'HIGH'),
('Uttar Pradesh', 'Agra',     'Dacoity',          6.4,  780,  'MEDIUM');
GO


-- 5. Verify
SELECT state, COUNT(DISTINCT district) AS districts, COUNT(*) AS records
FROM crimes
GROUP BY state
ORDER BY state;
GO

USE CATALOG data_{ENV};

-- Granting DATA READER access to the bronze schema to the SpetlrLhV2-table-users group
GRANT USE SCHEMA, EXECUTE, READ VOLUME, SELECT ON SCHEMA nyc_tlc_bronze TO `SpetlrLhV2-table-users`;

-- Granting DATA READER access to the silver schema to the SpetlrLhV2-table-users group
GRANT USE SCHEMA, EXECUTE, READ VOLUME, SELECT ON SCHEMA nyc_tlc_silver TO `SpetlrLhV2-table-users`;

-- Granting DATA READER access to the gold schema to the SpetlrLhV2-table-users group
GRANT USE SCHEMA, EXECUTE, READ VOLUME, SELECT ON SCHEMA nyc_tlc_gold TO `SpetlrLhV2-table-users`;

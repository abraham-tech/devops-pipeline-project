-- Create the Artifactory database schema
CREATE SCHEMA IF NOT EXISTS artifactory;

-- Grant necessary permissions to the Artifactory user
GRANT ALL PRIVILEGES ON DATABASE artifactory TO artifactory;
GRANT ALL PRIVILEGES ON SCHEMA artifactory TO artifactory;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA artifactory TO artifactory;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA artifactory TO artifactory;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA artifactory GRANT ALL PRIVILEGES ON TABLES TO artifactory;
ALTER DEFAULT PRIVILEGES IN SCHEMA artifactory GRANT ALL PRIVILEGES ON SEQUENCES TO artifactory;

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

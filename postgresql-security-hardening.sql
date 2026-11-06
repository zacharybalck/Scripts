-- ==========================================
-- PostgreSQL Hardening & Audit Configuration
-- ==========================================

-- Ensure password encryption defaults to SCRAM-SHA-256 (strongest built-in hashing)
ALTER SYSTEM SET password_encryption = 'scram-sha-256';

-- Enforce SSL connections for all clients
ALTER SYSTEM SET ssl = 'on';

-- Configure statement logging for security auditing (logs connections, disconnections, and long queries)
ALTER SYSTEM SET log_connections = 'on';
ALTER SYSTEM SET log_disconnections = 'on';
ALTER SYSTEM SET log_statement = 'ddl'; -- Log all DDL statements (CREATE, ALTER, DROP)
ALTER SYSTEM SET log_min_duration_statement = 250; -- Log queries taking longer than 250ms

-- Reload server configuration without restarting the service
SELECT pg_reload_conf();

-- Verify current security parameter settings
SELECT name, setting, unit 
FROM pg_settings 
WHERE name IN ('password_encryption', 'ssl', 'log_connections', 'log_statement');

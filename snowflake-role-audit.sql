-- ==========================================
-- Snowflake Security & Privilege Audit
-- ==========================================

-- 1. Review users and their last login timestamps to flag dormant accounts
SELECT 
    NAME,
    LOGIN_NAME,
    CREATED_ON,
    LAST_SUCCESS_LOGIN,
    DISABLED,
    DEFAULT_ROLE
FROM 
    SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE 
    DELETED_ON IS NULL
ORDER BY 
    LAST_SUCCESS_LOGIN DESC;

-- 2. Audit accounts possessing ACCOUNTADMIN or security administrative privileges
SELECT 
    GRANTEE_NAME AS USER_NAME,
    ROLE AS PRIVILEGED_ROLE,
    GRANTED_ON,
    CREATED_ON
FROM 
    SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE 
    ROLE IN ('ACCOUNTADMIN', 'SECURITYADMIN', 'SYSADMIN')
    AND DELETED_ON IS NULL;

-- 3. Identify public role grants (potential security exposure)
SELECT 
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    PRIVILEGE
FROM 
    SNOWFLAKE.ACCOUNT_USAGE.TABLE_PRIVILEGES
WHERE 
    GRANTEE = 'PUBLIC'
    AND DELETED_ON IS NULL;

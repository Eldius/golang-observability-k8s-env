
CREATE DATABASE rest_api;
CREATE USER rest_api WITH ENCRYPTED PASSWORD 'P@ss';
GRANT ALL ON DATABASE rest_api TO rest_api;

\c rest_api;
GRANT ALL ON SCHEMA public TO rest_api;

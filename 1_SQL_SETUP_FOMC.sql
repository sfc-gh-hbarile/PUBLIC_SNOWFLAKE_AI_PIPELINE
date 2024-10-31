--authors: John Heisler & Garrett Frere
--Create our warehouse
CREATE warehouse GEN_AI_FSI_WH warehouse_size = 'medium';

--Create our database
CREATE OR REPLACE DATABASE GEN_AI_FSI;

--create your schema
CREATE OR REPLACE SCHEMA GEN_AI_FSI.FOMC;

--create stage fed_LOGIC;
CREATE OR REPLACE STAGE FED_LOGIC DIRECTORY = (ENABLE = TRUE,  AUTO_REFRESH = true);

--create stage fed;
CREATE OR REPLACE STAGE FED_PDF DIRECTORY = (ENABLE = TRUE,  AUTO_REFRESH = true);

-- Create a sequence
CREATE OR REPLACE SEQUENCE FED_PDF_FULL_TEXT_SEQUENCE;
CREATE OR REPLACE SEQUENCE FED_PDF_CHUNK_SEQUENCE;

--store model data for meta analysis
CREATE OR REPLACE TABLE MODELS (model varchar, context_window int);

--isnert values into models table 
INSERT INTO MODELS
    VALUES
        --('snowflake-arctic', 4096) 
        ('mistral-large', 32000),
        ('reka-flash', 100000),
        ('reka-core', 32000),
        ('jamba-instruct', 256000), 
        ('mixtral-8x7b', 32000),
        ('llama2-70b-chat', 4096),
        ('llama3-8b', 8000),
        ('llama3-70b', 8000),
        ('llama3.1-8b', 128000), 
        ('llama3.1-70b', 128000), 
        ('llama3.1-405b', 128000), 
        ('mistral-7b', 32000),
        ('gemma-7b', 8000);

--create our full text table
CREATE OR REPLACE TABLE PDF_FULL_TEXT (
	ID NUMBER(19,0),
	RELATIVE_PATH VARCHAR(16777216),
	SIZE NUMBER(38,0),
	LAST_MODIFIED TIMESTAMP_TZ(3),
	MD5 VARCHAR(16777216),
	ETAG VARCHAR(16777216),
	FILE_URL VARCHAR(16777216),
	FILE_TEXT VARCHAR(16777216),
	FILE_DATE DATE,
    SENTIMENT VARCHAR(16777216)
);

CREATE OR REPLACE TABLE GEN_AI_FSI.FOMC.PDF_CHUNKS (
	ID NUMBER(19,0),
    FULL_TEXT_FK NUMBER(19,0),
	RELATIVE_PATH VARCHAR(16777216),
    FILE_DATE DATE,
	CHUNK VARCHAR(16777216)
);

--In order to go to the public internet and download the PDFs, we need a network rule and network access integration.
--create the network rule
CREATE OR REPLACE NETWORK RULE FED_RESERVE
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('www.federalreserve.gov');

--add the network rule to external access integration
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION FED_RESERVE_ACCESS_INTEGRATION
  ALLOWED_NETWORK_RULES = (FED_RESERVE)
  ENABLED = true;

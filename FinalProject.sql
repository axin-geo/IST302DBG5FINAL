/*Create tables*/
 
drop table [dbo].[G5_SALES]
drop table [dbo].[G5_CHANNELS]
drop table [dbo].G5_CUSTOMERS
drop table [dbo].G5_PRODUCTS
drop table [dbo].G5_PROMOTIONS
drop table [dbo].G5_COUNTRY
drop table dbo.G5_CusEx
drop table dbo.G5_CusIn

--  1. G5_CHANNELS Table
--- 1.1 create table
CREATE TABLE G5_CHANNELS  (
CHANNEL_ID int not NULL unique,
CHANNEL_DESC varchar(50) not NULL,
CHANNEL_CLASS Varchar(50) not Null
CONSTRAINT PK_CHANNEL_ID PRIMARY KEY clustered (CHANNEL_ID)
)

--- 1.2 populate the new table
INSERT INTO [dbo].[G5_CHANNELS]
SELECT [CHANNEL_ID], [CHANNEL_DESC], [CHANNEL_DESC] FROM [dbo].[LI_CHANNELS]

-- 2. Create G5_Customer Table with the data field definition we want
--- 2.1 Create G5_CusEx table

select * into G5_CusEx
from [dbo].[LI_CUSTOMERS_EXT]

--- 2.2 Create G5_CusIn table
select * into G5_CusIn
from [dbo].[LI_CUSTOMERS_INTX]

--- 2.3 Join tables together
select cx.[CUST_ID], [CUST_FIRST_NAME],[CUST_LAST_NAME],
	cx.[CUST_GENDER],[CUST_YEAR_OF_BIRTH],[CUST_MARITAL_STATUS],
	[CUST_INCOME_LEVEL],[CUST_CREDIT_LIMIT],
	[CUST_MAIN_PHONE_NUMBER],[CUST_EMAIL],
	[CUST_STREET_ADDRESS],[CUST_POSTAL_CODE],
	[CUST_CITY],[CUST_STATE_PROVINCE],
	[COUNTRY_ID],[CUST_TOTAL],
	[COUNTRY_NAME],[COUNTRY_SUBREGION],
	[COUNTRY_REGION],[COUNTRY_TOTAL]
into G5_CUSTOMERS
from G5_CusEx cx
join G5_CusIn ci on cx.CUST_ID = ci.CUST_ID

--- 2.4 Table clean up
---- CONSTRAINT_MARITAL_STATUS
--- widow, divorced, single, married, separated, null, 5 migtht be space
-- case value to clean up marital status
update G5_CUSTOMERS
set CUST_MARITAL_STATUS = null
where CUST_MARITAL_STATUS = 'Mabsent'

update G5_CUSTOMERS
set CUST_MARITAL_STATUS = 'single'
where CUST_MARITAL_STATUS = 'NeverM'

update G5_CUSTOMERS
set CUST_MARITAL_STATUS = 'divorced'
where CUST_MARITAL_STATUS = 'Divorc.'

update G5_CUSTOMERS
set CUST_MARITAL_STATUS = 'married'
where CUST_MARITAL_STATUS = 'Mar-AF'

update G5_CUSTOMERS
set CUST_MARITAL_STATUS = 'widowed'
where CUST_MARITAL_STATUS = 'Widowed' OR CUST_MARITAL_STATUS = 'widow'

update G5_CUSTOMERS
set CUST_MARITAL_STATUS = 'separated'
where CUST_MARITAL_STATUS = 'Separ.'

update G5_CUSTOMERS
set CUST_MARITAL_STATUS = null
where CUST_MARITAL_STATUS = ' '

--- 2.5 alter table G5_Customer table
alter table G5_CUSTOMERS alter column CUST_ID int not Null;
alter table G5_CUSTOMERS alter column CUST_FIRST_NAME Varchar(50);
alter table G5_CUSTOMERS alter column CUST_LAST_NAME Varchar(40);
alter table G5_CUSTOMERS alter column CUST_GENDER char(1);
alter table G5_CUSTOMERS alter column CUST_MAIN_PHONE_NUMBER  varchar(25);
alter table G5_CUSTOMERS alter column CUST_EMAIL varchar(30);
alter table G5_CUSTOMERS alter column CUST_STREET_ADDRESS varchar(40);
alter table G5_CUSTOMERS alter column CUST_POSTAL_CODE varchar(10);
alter table G5_CUSTOMERS alter column CUST_CITY  varchar(30);
alter table G5_CUSTOMERS alter column CUST_STATE_PROVINCE varchar(40);
alter table G5_CUSTOMERS alter column COUNTRY_ID char(5);
alter table G5_CUSTOMERS alter column COUNTRY_NAME varchar(50);
alter table G5_CUSTOMERS alter column COUNTRY_SUBREGION varchar(30);
alter table G5_CUSTOMERS alter column COUNTRY_REGION varchar(20);
alter table G5_CUSTOMERS alter column CUST_YEAR_OF_BIRTH int;
alter table G5_CUSTOMERS alter column CUST_MARITAL_STATUS varchar(20) null;
alter table G5_CUSTOMERS alter column CUST_INCOME_LEVEL varchar(30);
alter table G5_CUSTOMERS alter column CUST_CREDIT_LIMIT decimal(20, 0);
alter table G5_CUSTOMERS drop column COUNTRY_TOTAL;
alter table G5_CUSTOMERS drop column CUST_TOTAL;
alter table G5_CUSTOMERS ADD CONSTRAINT PK_CUST_ID PRIMARY KEY clustered (CUST_ID);
alter table G5_CUSTOMERS ADD CONSTRAINT CONSTRAINT_GENDER CHECK (CUST_GENDER='f' OR CUST_GENDER='m' OR CUST_GENDER='F' OR CUST_GENDER='M');
alter table G5_CUSTOMERS ADD CONSTRAINT CONSTRAINT_MARITAL_STATUS CHECK (CUST_MARITAL_STATUS='single' OR  CUST_MARITAL_STATUS='married' OR CUST_MARITAL_STATUS='divorced'OR CUST_MARITAL_STATUS='separated' OR CUST_MARITAL_STATUS='widowed' OR CUST_MARITAL_STATUS is null);
alter table G5_CUSTOMERS alter column COUNTRY_ID int not null
alter table G5_CUSTOMERS ADD CONSTRAINT FK_COUNTRY_ID FOREIGN KEY (COUNTRY_ID) references G5_COUNTRY (COUNTRY_ID);

-- 3. Create Country table from G5_CUSTOMERS
go
select DISTINCT [COUNTRY_ID], COUNTRY_NAME, COUNTRY_SUBREGION, COUNTRY_REGION
into G5_COUNTRY
from G5_CUSTOMERS
go
alter table G5_COUNTRY alter column COUNTRY_ID int not null
go
alter table G5_COUNTRY ADD CONSTRAINT CONSTRAINT_COUNTRY_REGION CHECK ([COUNTRY_REGION]='Oceania' OR [COUNTRY_REGION]='Europe' OR [COUNTRY_REGION]='Americas' OR [COUNTRY_REGION]='Africa' OR [COUNTRY_REGION]='Asia');
alter table G5_COUNTRY ADD CONSTRAINT PK_COUNTRY_ID PRIMARY KEY clustered (COUNTRY_ID);

-- 3.1 Delete the country columns from G5_CUSTOMERS
alter table G5_CUSTOMERS drop column COUNTRY_NAME;
alter table G5_CUSTOMERS drop column COUNTRY_SUBREGION;
alter table G5_CUSTOMERS drop column COUNTRY_REGION;

-- 4. Create Products table
select * into
G5_PRODUCTS from
[dbo].[LI_PRODUCTS]

-- 4.1 clean up
alter table G5_PRODUCTS drop column [PROD_MIN_PRICE];
alter table G5_PRODUCTS drop column [PROD_STATUS];
alter table G5_PRODUCTS drop column [PROD_TOTAL];
alter table G5_PRODUCTS drop column [PROD_DESC];
alter table G5_PRODUCTS drop column [PROD_SUBCAT_DESC];
alter table G5_PRODUCTS drop column PROD_CATEGORY ;
alter table G5_PRODUCTS drop column [PROD_UNIT_OF_MEASURE];
alter table G5_PRODUCTS drop column [PROD_PACK_SIZE];

-- 4.2 alter data definitions
go
sp_rename 'G5_PRODUCTS.PROD_CAT_DESC','PROD_CATEGORY','COLUMN'
go
alter table G5_PRODUCTS alter column PROD_ID int not NULL;
alter table G5_PRODUCTS alter column PROD_NAME Varchar(50) not NULL;
alter table G5_PRODUCTS alter column PROD_SUBCATEGORY Varchar(50) not NULL;
alter table G5_PRODUCTS alter column PROD_CATEGORY Varchar(50) not NULL;
alter table G5_PRODUCTS alter column PROD_WEIGHT_CLASS int not NULL;
alter table G5_PRODUCTS alter column PROD_LIST_PRICE decimal(20, 2) not NULL;
alter table G5_PRODUCTS ADD CONSTRAINT PK_PROD_ID PRIMARY KEY clustered (PROD_ID);

-- 5. Create Promotions Table
--- 5.1 create and populate Promotions table
select * into
G5_PROMOTIONS from
[dbo].[LI_PROMOTIONS]

--- 5.2 APPLY CONSTRAINT AND NEW DATA FILED DEFINITION
alter table G5_PROMOTIONS alter column PROMO_ID integer not null;
alter table G5_PROMOTIONS alter column PROMO_NAME varchar(30) not null;
alter table G5_PROMOTIONS alter column PROMO_SUBCATEGORY varchar(30) not null;
alter table G5_PROMOTIONS alter column PROMO_CATEGORY varchar(30) not null;
alter table G5_PROMOTIONS alter column PROMO_COST integer not null;
alter table G5_PROMOTIONS alter column PROMO_BEGIN_DATE date null;
alter table G5_PROMOTIONS alter column PROMO_END_DATE date not null;
alter table G5_PROMOTIONS DROP column PROMO_TOTAL;

alter table G5_PROMOTIONS ADD CONSTRAINT PK_PROMO_ID PRIMARY KEY clustered (PROMO_ID)

-- 6. Create Sales Table
--- 6.1 Create G5_SALES table

select * into
G5_SALES from
(select * from [dbo].[LI_SALES_12_13]
union
select * from [dbo].[LI_SALES_14]) a
order by [SALESTRANS_ID]

go
--- 6.2 Table clean up
-- alter table G5_SALES ADD CONSTRAINT PK_CUST_ID PRIMARY KEY clustered (CUST_ID);

alter table G5_SALES alter column SALESTRANS_ID integer not null;
alter table G5_SALES alter column PROD_ID integer not null;
alter table G5_SALES alter column CUST_ID integer not null;
alter table G5_SALES alter column CHANNEL_ID integer not null;
alter table G5_SALES alter column PROMO_ID integer not null;
alter table G5_SALES alter column SALE_DATE date null;
alter table G5_SALES alter column SHIPPING_DATE date null;
alter table G5_SALES alter column PAYMENT_DATE date null;
alter table G5_SALES alter column QUANTITY_SOLD integer not null;
go
sp_rename 'G5_SALES.AMOUNT_SOLD','TOTAL_PRICE','COLUMN';
alter table G5_SALES alter column TOTAL_PRICE decimal(20,2) not null; 
alter table G5_SALES alter column UNIT_PRICE decimal(20,2) not null;

alter table G5_SALES ADD CONSTRAINT PK_SALESTRANS_ID PRIMARY KEY (SALESTRANS_ID);
alter table G5_SALES ADD CONSTRAINT FK_PROD_ID FOREIGN KEY (PROD_ID) references G5_PRODUCTS (PROD_ID);
alter table G5_SALES ADD CONSTRAINT FK_CUST_ID FOREIGN KEY (CUST_ID) references G5_CUSTOMERS (CUST_ID);
alter table G5_SALES ADD CONSTRAINT FK_PROMO_ID FOREIGN KEY (PROMO_ID) references G5_PROMOTIONS (PROMO_ID);
alter table G5_SALES ADD CONSTRAINT FK_CHANNEL_ID FOREIGN KEY (CHANNEL_ID) references G5_CHANNELS (CHANNEL_ID)

-- 7 Test Intergrity constraints and Record any integrity constraint violation
-- 7.1 [G5_CHANNELS] CONSTRAINT PK_CHANNEL_ID PRIMARY KEY clustered (CHANNEL_ID)
INSERT INTO [G5_CHANNELS] VALUES
(2,
'Gift',
'Final');

-- 7.2 [G5_COUNTRY]
---alter table G5_COUNTRY ADD CONSTRAINT CONSTRAINT_COUNTRY_REGION CHECK ([COUNTRY_REGION]='Oceania' OR [COUNTRY_REGION]='Europe' OR [COUNTRY_REGION]='Americas' OR [COUNTRY_REGION]='Africa' OR [COUNTRY_REGION]='Asia');
update [dbo].[G5_COUNTRY]
set [COUNTRY_REGION] = 'Mars'
where [COUNTRY_ID] = 52785
go

-- 7.3 [G5_CUSTOMERS]
-- a. alter table G5_CUSTOMERS ADD CONSTRAINT PK_CUST_ID PRIMARY KEY clustered (CUST_ID);
-- b. alter table G5_CUSTOMERS ADD CONSTRAINT CONSTRAINT_GENDER CHECK (CUST_GENDER='f' OR CUST_GENDER='m' OR CUST_GENDER='F' OR CUST_GENDER='M');
update [dbo].G5_CUSTOMERS
set CUST_GENDER = 'w'
where [CUST_ID] = 1
go

-- c. alter table G5_CUSTOMERS ADD CONSTRAINT CONSTRAINT_MARITAL_STATUS CHECK (CUST_MARITAL_STATUS='single' OR  CUST_MARITAL_STATUS='married' OR CUST_MARITAL_STATUS='divorced'OR CUST_MARITAL_STATUS='separated'OR CUST_MARITAL_STATUS='widow'OR CUST_MARITAL_STATUS is null);
update [dbo].G5_CUSTOMERS
set CUST_MARITAL_STATUS = 'Alone'
where [CUST_ID] = 2
go

--postive
update [dbo].G5_CUSTOMERS
set CUST_MARITAL_STATUS = 'divorced'
where [CUST_ID] = 2
go

-- 7.4 [G5_PRODUCTS]
alter table G5_PRODUCTS ADD CONSTRAINT PK_PROD_ID PRIMARY KEY clustered (PROD_ID);

-- 7.5 [G5_PROMOTIONS]
alter table G5_PROMOTIONS ADD CONSTRAINT PK_PROMO_ID PRIMARY KEY clustered (PROMO_ID) 

-- 7.6 [G5_SALES]
alter table G5_SALES ADD CONSTRAINT PK_SALESTRANS_ID PRIMARY KEY (SALESTRANS_ID);
alter table G5_SALES ADD CONSTRAINT FK_PROD_ID FOREIGN KEY (PROD_ID) references G5_PRODUCTS (PROD_ID);
alter table G5_SALES ADD CONSTRAINT FK_CUST_ID FOREIGN KEY (CUST_ID) references G5_CUSTOMERS (CUST_ID);
alter table G5_SALES ADD CONSTRAINT FK_PROMO_ID FOREIGN KEY (PROMO_ID) references G5_PROMOTIONS (PROMO_ID);
alter table G5_SALES ADD CONSTRAINT FK_CHANNEL_ID FOREIGN KEY (CHANNEL_ID) references G5_CHANNELS (CHANNEL_ID)

-- 8. Write Business Queries, and create 2 execution plans (A and B) , and identify the best one

-- Plan type A
-- Plan type B

-- BQ1 Select any channel from the G5_CHANNELS  that was not used by any sale transaction made. 
select [CHANNEL_ID]
from G5_CHANNELS 
EXCEPT 
select distinct [CHANNEL_ID]
from [2023DBFall_Group_5_DB].[dbo].[G5_SALES]

-- BQ2 2012 Sales Transaction History (Join Products table and Sales table). This table focuses on querying for the sales transactions that happened during 2012. Sales Product Performance evaluation.
create view VIEW_SALES_TRANS_HISTORY as
select [SALESTRANS_ID],s.[PROD_ID],[CUST_ID],[PROMO_ID],[SALE_DATE],[QUANTITY_SOLD],[TOTAL_PRICE],[UNIT_PRICE], [PROD_LIST_PRICE],[PROD_NAME]
from [G5_SALES] s
left join [G5_PRODUCTS] p on s.[PROD_ID] = p.[PROD_ID]
where SALE_DATE BETWEEN '2012-01-01' AND '2012-12-31'

-- BQ3 2012 Internet Sales Promotion History: (Join Sales table, channel, Promotions table). This table focus on query for sales promotions  that happened during a particular date/dates via the internet channel.
create view VIEW_INTERNET_SALES_PROMO_HISTORY as
select [SALESTRANS_ID],s.[PROD_ID],[CUST_ID],s.[CHANNEL_ID], s.[PROMO_ID],[SALE_DATE],[QUANTITY_SOLD],[TOTAL_PRICE],[UNIT_PRICE], [PROMO_NAME],[CHANNEL_DESC]
from [G5_SALES] s
left join [G5_PROMOTIONS] promo on s.PROMO_ID = promo.PROMO_ID
left join [dbo].[G5_CHANNELS] chan on s.[CHANNEL_ID] = chan.[CHANNEL_ID]
where SALE_DATE BETWEEN '2012-01-01' AND '2012-12-31' and [CHANNEL_DESC] = 'Internet'

-- BQ4 2012 Internet Sales History in Asia:  This table focus on query for sales promotions  that happened during a particular date/dates via the internet channel. 
create view VIEW_ASIA_INTERNET_SALES_HISTORY as
select [SALESTRANS_ID],[COUNTRY_REGION],s.[PROD_ID],s.[CUST_ID],[PROMO_ID],[SALE_DATE],[QUANTITY_SOLD],[TOTAL_PRICE],[UNIT_PRICE],[CHANNEL_DESC]
from [G5_SALES] s
left join [dbo].[G5_CUSTOMERS] cus on s.[CUST_ID] = cus.[CUST_ID]
left join [dbo].[G5_CHANNELS] chan on s.[CHANNEL_ID] = chan.[CHANNEL_ID]
left join [dbo].[G5_COUNTRY] coun on cus.[COUNTRY_ID] = coun.[COUNTRY_ID]
where SALE_DATE BETWEEN '2012-01-01' AND '2012-12-31' 
and [CHANNEL_DESC] = 'Internet'
and [COUNTRY_REGION] = 'Asia'

-- BQ5 Customer Demography .which gender group of our customers in Asia have the highest sale from purchasing through internet in 2021.
create view ASIA_GENDER_GROUP_INTERNET_SALE_HISTORY AS
select [CUST_GENDER], SUM(TOTAL_PRICE) AS TOTAL_AMOUNT
FROM G5_SALES s
left join [dbo].[G5_CUSTOMERS] cus on s.[CUST_ID] = cus.[CUST_ID]
left join [dbo].[G5_CHANNELS] chan on s.[CHANNEL_ID] = chan.[CHANNEL_ID]
left join [dbo].[G5_COUNTRY] coun on cus.[COUNTRY_ID] = coun.[COUNTRY_ID]
where SALE_DATE BETWEEN '2012-01-01' AND '2012-12-31' 
and [CHANNEL_DESC] = 'Internet'
and [COUNTRY_REGION] = 'Asia'
group by [CUST_GENDER]

-- Procedure calculate the total sale made in a continent in 2012 via internet
create procedure spPrintTotalSale2012(
@ContinentRegion varchar(20)
)
as
select SUM(TOTAL_PRICE) AS TOTAL_AMOUNT
FROM G5_SALES s
left join [dbo].[G5_CUSTOMERS] cus on s.[CUST_ID] = cus.[CUST_ID]
left join [dbo].[G5_CHANNELS] chan on s.[CHANNEL_ID] = chan.[CHANNEL_ID]
left join [dbo].[G5_COUNTRY] coun on cus.[COUNTRY_ID] = coun.[COUNTRY_ID]
where SALE_DATE BETWEEN '2012-01-01' AND '2012-12-31' 
and [CHANNEL_DESC] = 'Internet'
and [COUNTRY_REGION] = @ContinentRegion
go

--execute the stored procedure
execute spPrintTotalSale2012 'Europe'
go
-- Procedure2 Select the product that has the highest sale in 2012 in a continent via certain channel
create procedure spPrintHigestProduct(
@ContinentRegion varchar(20),
@ChannelName varchar(50)
)
as
select [PROD_NAME], [TOTAL_PRICE]
from [G5_SALES] s
left join [G5_PRODUCTS] p on s.[PROD_ID] = p.[PROD_ID]
left join [dbo].[G5_CUSTOMERS] cus on s.[CUST_ID] = cus.[CUST_ID]
left join [dbo].[G5_CHANNELS] chan on s.[CHANNEL_ID] = chan.[CHANNEL_ID]
left join [dbo].[G5_COUNTRY] coun on cus.[COUNTRY_ID] = coun.[COUNTRY_ID]
where SALE_DATE BETWEEN '2012-01-01' AND '2012-12-31' 
and [CHANNEL_DESC] = @ChannelName
and [COUNTRY_REGION] = @ContinentRegion
and [TOTAL_PRICE]= (select max([TOTAL_PRICE]) from [G5_SALES] s left join [G5_PRODUCTS] p on s.[PROD_ID] = p.[PROD_ID]
left join [dbo].[G5_CUSTOMERS] cus on s.[CUST_ID] = cus.[CUST_ID]
left join [dbo].[G5_CHANNELS] chan on s.[CHANNEL_ID] = chan.[CHANNEL_ID]
left join [dbo].[G5_COUNTRY] coun on cus.[COUNTRY_ID] = coun.[COUNTRY_ID]
where SALE_DATE BETWEEN '2012-01-01' AND '2012-12-31' 
and [CHANNEL_DESC] = @ChannelName
and [COUNTRY_REGION] = @ContinentRegion)

go

-- executes
execute spPrintHigestProduct 'Asia', 'Direct Sales'
go

-- Indexes
select [CUST_GENDER], SUM(TOTAL_PRICE) AS TOTAL_AMOUNT
FROM G5_SALES s
left join [dbo].[G5_CUSTOMERS] cus on s.[CUST_ID] = cus.[CUST_ID]
left join [dbo].[G5_CHANNELS] chan on s.[CHANNEL_ID] = chan.[CHANNEL_ID]
left join [dbo].[G5_COUNTRY] coun on cus.[COUNTRY_ID] = coun.[COUNTRY_ID]
where SALE_DATE BETWEEN '2012-01-01' AND '2012-12-31' 
and [CHANNEL_DESC] = 'Internet'
and [COUNTRY_REGION] = 'Asia'
group by [CUST_GENDER]

-- creeate index on join

CREATE INDEX IDX_cust_id ON G5_SALES ([CUST_ID])
CREATE INDEX IDX_CHANNEL_ID ON [G5_CHANNELS] ([CHANNEL_ID])
CREATE INDEX IDX_COUNTRY_ID ON [G5_COUNTRY] ([COUNTRY_ID])
create index idx_composite on G5_SALES ([CUST_ID], [CHANNEL_ID],TOTAL_PRICE)

drop INDEX IDX_cust_id ON G5_SALES 
drop INDEX IDX_CHANNEL_ID ON [G5_CHANNELS] 
drop INDEX IDX_COUNTRY_ID ON [G5_COUNTRY] 
drop INDEX idx_composite ON G5_SALES 

-- Create users to grant security privileges with Views
-- "sale" and "mark"

create user sale without login
create user mark without login
go

-- grant privileges to sale
grant select on VIEW_SALES_TRANS_HISTORY to sale

grant insert on VIEW_ASIA_INTERNET_SALES_HISTORY to sale
grant select on VIEW_ASIA_INTERNET_SALES_HISTORY to sale
grant update on VIEW_ASIA_INTERNET_SALES_HISTORY to sale
grant delete on VIEW_ASIA_INTERNET_SALES_HISTORY to sale

grant insert on ASIA_GENDER_GROUP_INTERNET_SALE_HISTORY to sale
grant select on ASIA_GENDER_GROUP_INTERNET_SALE_HISTORY to sale
grant update on ASIA_GENDER_GROUP_INTERNET_SALE_HISTORY to sale
grant delete on ASIA_GENDER_GROUP_INTERNET_SALE_HISTORY to sale

-- grant privileges to mark
grant insert on VIEW_INTERNET_SALES_PROMO_HISTORY to mark
grant select on VIEW_INTERNET_SALES_PROMO_HISTORY to mark
grant update on VIEW_INTERNET_SALES_PROMO_HISTORY to mark
grant delete on VIEW_INTERNET_SALES_PROMO_HISTORY to mark

grant insert on VIEW_ASIA_INTERNET_SALES_HISTORY to mark
grant select on VIEW_ASIA_INTERNET_SALES_HISTORY to mark

grant insert on ASIA_GENDER_GROUP_INTERNET_SALE_HISTORY to mark
grant select on ASIA_GENDER_GROUP_INTERNET_SALE_HISTORY to mark
grant update on ASIA_GENDER_GROUP_INTERNET_SALE_HISTORY to mark
grant delete on ASIA_GENDER_GROUP_INTERNET_SALE_HISTORY to mark

-- positive and negative tests for sale 
execute as user = 'sale'
go

-- negative update
update [VIEW_INTERNET_SALES_PROMO_HISTORY] 
set [PROD_ID] = 34
where [SALESTRANS_ID] = 8
go
-- negative select
select * from [VIEW_INTERNET_SALES_PROMO_HISTORY] 
where [SALESTRANS_ID] = 58
go

-- positive and negative tests for mark
execute as user = 'mark'
go

-- negative update
update VIEW_ASIA_INTERNET_SALES_HISTORY
set [COUNTRY_REGION] = 'Europe'
where [SALESTRANS_ID] = 393

-- negative select
select * from VIEW_ASIA_INTERNET_SALES_HISTORY 
where [SALESTRANS_ID] = 58
go


revert



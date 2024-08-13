-- Создание таблицы по датасету:
CREATE TABLE intermediate_table (
    ID INT,
    Year_Birth int,
    Education VARCHAR(50),
    Marital_Status VARCHAR(20),
    Income INT,
    Kidhome INT,
    Teenhome INT,
    Dt_Customer DATE,
    Recency INT,
    MntWines DECIMAL(10, 2),
    MntFruits DECIMAL(10, 2),
    MntMeatProducts DECIMAL(10, 2),
    MntFishProducts DECIMAL(10, 2),
    MntSweetProducts DECIMAL(10, 2),
    MntGoldProds DECIMAL(10, 2),
    NumDealsPurchases INT,
    NumWebPurchases INT,
    NumCatalogPurchases INT,
    NumStorePurchases INT,
    NumWebVisitsMonth INT,
    AcceptedCmp3 TINYINT(1),
    AcceptedCmp4 TINYINT(1),
    AcceptedCmp5 TINYINT(1),
    AcceptedCmp1 TINYINT(1),
    AcceptedCmp2 TINYINT(1),
    Response TINYINT(1),
    Complain TINYINT(1),
    Country VARCHAR(50),
    PRIMARY KEY (ID)
);

-- Заполняем ее данными из csv файла:

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\marketing_data.csv'
INTO TABLE intermediate_table
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

-- Создаем 4 таблицы для дальнейшей работы с данными 
-- Создание таблицы с информацией о клиентах
CREATE TABLE customers (
    customer_id INT NOT NULL,
    year_birth int,
    education VARCHAR(50),
    marital_status VARCHAR(20),
    income DECIMAL(10, 2),
    kidhome INT,
    teenhome INT,
    dt_customer DATE,
    recency INT,
    country VARCHAR(50),
    PRIMARY KEY(customer_id)
);

-- Создание таблицы с информацией о покупках
CREATE TABLE purchases (
    purchase_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT,
    num_deals_purchases INT,
    num_web_purchases INT,
    num_catalog_purchases INT,
    num_store_purchases INT,
    num_web_visits_month INT,
    PRIMARY KEY(purchase_id),
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

-- Создание таблицы с информацией о взаимодействиях с кампаниями и жалобах
CREATE TABLE campaigns (
    campaign_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT,
    accepted_cmp3 TINYINT(1),
    accepted_cmp4 TINYINT(1),
    accepted_cmp5 TINYINT(1),
    accepted_cmp1 TINYINT(1),
    accepted_cmp2 TINYINT(1),
    response TINYINT(1),
    complain TINYINT(1),
    PRIMARY KEY(campaign_id),
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

-- Создание таблицы с информацией о расходах
CREATE TABLE spending (
    spending_id INT NOT NULL AUTO_INCREMENT,
    customer_id INT,
    mnt_wines DECIMAL(10, 2),
    mnt_fruits DECIMAL(10, 2),
    mnt_meat_products DECIMAL(10, 2),
    mnt_fish_products DECIMAL(10, 2),
    mnt_sweet_products DECIMAL(10, 2),
    mnt_gold_prods DECIMAL(10, 2),
    PRIMARY KEY(spending_id),
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);

-- Отвечаем на вопрос какая маркетинговая компания оказалась наиболее успешной, для этого обратимся к таблице campaigns
SELECT 
    'Campaign 3' AS Campaign, 
    SUM(accepted_cmp3) / COUNT(*) * 100 AS Success_Rate 
FROM campaigns
UNION
SELECT 
    'Campaign 4' AS Campaign, 
    SUM(accepted_cmp4) / COUNT(*) * 100 AS Success_Rate 
FROM campaigns
UNION
SELECT 
    'Campaign 5' AS Campaign, 
    SUM(accepted_cmp5) / COUNT(*) * 100 AS Success_Rate 
FROM campaigns
UNION
SELECT 
    'Campaign 1' AS Campaign, 
    SUM(accepted_cmp1) / COUNT(*) * 100 AS Success_Rate 
FROM campaigns
UNION
SELECT 
    'Campaign 2' AS Campaign, 
    SUM(accepted_cmp2) / COUNT(*) * 100 AS Success_Rate 
FROM campaigns
ORDER BY Success_Rate DESC;
-- Выясняем, что campaign 4 наиболее успешная

-- Как выглядит среднестатистический потребитель? Обратимся к таблице customers
SELECT 
AVG(year_birth) AS average_year_birth, AVG(income) AS average_income, AVG(kidhome) AS average_kidhome, AVG(teenhome) AS average_teenhome,AVG(recency) AS average_recency
FROM customers; 
SELECT education, COUNT(*) AS count
FROM customers
GROUP BY education
ORDER BY count DESC
LIMIT 1;
SELECT marital_status, COUNT(*) AS count
FROM customers
GROUP BY marital_status
ORDER BY count DESC
LIMIT 1;

-- Узнаем среднестатистический год рождения, доход, количество детей и подростков, семейное положение и образование, а также количество дней после последней покупки

-- Какой сегмент продуктов самый прибыльный
SELECT 
    'Wines' AS Product, SUM(mnt_wines) AS Total_Sales
FROM spending
UNION
SELECT 
    'Fruits' AS Product, SUM(mnt_fruits) AS Total_Sales
FROM spending
UNION
SELECT 
    'Meat Products' AS Product, SUM(mnt_meat_products) AS Total_Sales
FROM spending
UNION
SELECT 
    'Fish Products' AS Product, SUM(mnt_fish_products) AS Total_Sales
FROM spending
UNION
SELECT 
    'Sweet Products' AS Product, SUM(mnt_sweet_products) AS Total_Sales
FROM spending
UNION
SELECT 
    'Gold Products' AS Product, SUM(mnt_gold_prods) AS Total_Sales
FROM spending
ORDER BY Total_Sales DESC;

-- Выясняем, что самым прибыльным сегментом являются вина

-- Cамые неудачные каналы продаж
SELECT 
    'Deals' AS Channel, SUM(num_deals_purchases) AS Total_Interactions
FROM purchases
UNION
SELECT 
    'Web' AS Channel, SUM(num_web_purchases) AS Total_Interactions
FROM purchases
UNION
SELECT 
    'Catalog' AS Channel, SUM(num_catalog_purchases) AS Total_Interactions
FROM purchases
UNION
SELECT 
    'Store' AS Channel, SUM(num_store_purchases) AS Total_Interactions
FROM purchases
UNION
SELECT 
    'Web Visits' AS Channel, SUM(num_web_visits_month) AS Total_Interactions
FROM purchases
ORDER BY Total_Interactions ASC;

-- Выясняем, что самым неудачным каналом продаж является deals
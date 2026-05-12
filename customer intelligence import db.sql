LOAD DATA INFILE 'C:/Users/AVURA/Downloads/archive (8)/customer_rfm_final.csv'
INTO TABLE customer_rfm
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


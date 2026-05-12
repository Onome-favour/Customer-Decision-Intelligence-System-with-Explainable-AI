CREATE DATABASE IF NOT EXISTS customer_intelligence;
USE customer_intelligence;

CREATE TABLE IF NOT EXISTS customer_rfm (
    customer_id INT,
    recency INT,
    frequency INT,
    monetary FLOAT,
    r_score INT,
    f_score INT,
    m_score INT,
    rfm_score VARCHAR(10),
    segment VARCHAR(50),
    cluster INT,
    cluster_label VARCHAR(50)
);
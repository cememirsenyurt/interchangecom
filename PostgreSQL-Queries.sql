/* 
Name: Cem Emir Senyurt
Date: 04/11/2023
*/




-- 1. Table Creation and Analysis –-

-- SQL DDL statements


DROP SCHEMA IF EXISTS Interchange CASCADE;
CREATE SCHEMA Interchange;
SET search_path TO Interchange;
CREATE TABLE Users (
      user_id        text NOT NULL,
      email          text NOT NULL,
      first_name     text,
      last_name      text NOT NULL,
      joined_date    date NOT NULL,
      street         text,
      city           text,
      state          text,
      zip            text,
      categories     text,
   PRIMARY KEY (user_id)
);
CREATE TABLE Phones (
      user_id        text,
      number         text,
      kind           text,
   PRIMARY KEY (user_id, kind),
   FOREIGN KEY ( user_id) REFERENCES Users (user_id) ON DELETE CASCADE,
   CHECK (kind IN ('mobile', 'home', 'work'))
);
CREATE TABLE Buyers (
      user_id        text,
   PRIMARY KEY (user_id),
   FOREIGN KEY (user_id) REFERENCES Users (user_id) ON DELETE CASCADE
);
CREATE TABLE Sellers (
      user_id        text,
      website        text,
   PRIMARY KEY (user_id),
   FOREIGN KEY (user_id) REFERENCES Users (user_id) ON DELETE CASCADE
);




CREATE TABLE Items (
      item_id        text NOT NULL,
      name           text NOT NULL,
      price          decimal(8,2) NOT NULL,
      category       text NOT NULL,
      description    text,
      seller_user_id text NOT NULL,
      list_date      date NOT NULL,
      buyer_user_id  text,
      purchase_date  date,
   PRIMARY KEY (item_id),
   FOREIGN KEY (seller_user_id) REFERENCES Sellers (user_id) ON DELETE CASCADE,
   FOREIGN KEY (buyer_user_id) REFERENCES Buyers (user_id) ON DELETE CASCADE
);


CREATE TABLE Pictures (
      pic_num        int NOT NULL,
      item_id        text NOT NULL,
      format         text NOT NULL,
      url            text NOT NULL,
   PRIMARY KEY (pic_num, item_id),
   FOREIGN KEY (item_id) REFERENCES Items (item_id) ON DELETE CASCADE,
   CHECK (format IN ('png', 'jpeg', 'mp4'))
);
CREATE TABLE Ads (
      ad_id          text NOT NULL,
      plan           text NOT NULL,
      content        text,
      pic_num        int NOT NULL,
      item_id        text NOT NULL,
      seller_user_id text NOT NULL,
      placed_date    date NOT NULL,
   PRIMARY KEY (ad_id),
   FOREIGN KEY (item_id) REFERENCES Items (item_id) ON DELETE CASCADE,
   FOREIGN KEY (pic_num, item_id) REFERENCES Pictures (pic_num, item_id) ON DELETE CASCADE,
   FOREIGN KEY (seller_user_id) REFERENCES Sellers (user_id) ON DELETE CASCADE
);


CREATE TABLE Goods (
      item_id        text NOT NULL,
  PRIMARY KEY (item_id),
  FOREIGN KEY (item_id) REFERENCES Items (item_id) ON DELETE CASCADE
);
CREATE TABLE Services (
      item_id        text NOT NULL,
      frequency      text NOT NULL,
   PRIMARY KEY (item_id),
   FOREIGN KEY (item_id) REFERENCES Items (item_id) ON DELETE CASCADE,
   CHECK (frequency IN ('once', 'daily', 'weekly', 'monthly', 'quarterly', 'yearly'))
);
CREATE TABLE Ratings (
      buyer_id       text,
      seller_id      text,
      quality        int,
      pricing        int,
      delivery       int,
      rating_date    date NOT NULL,
   PRIMARY KEY (buyer_id, seller_id),
   FOREIGN KEY (buyer_id) REFERENCES Buyers (user_id) ON DELETE CASCADE,
   FOREIGN KEY (seller_id) REFERENCES Sellers (user_id) ON DELETE CASCADE
);


/*
item_id: Type text. Text is a variable length type that can be able to store character strings. Also, It’s NOT_NULL. NOT_NULL gives us the information that this column will never be assigned to a null value. 
name: Type text. It’s NOT_NULL.
price: Type is decimal(8,2). It’s NOT_NULL. decimal(8,2) is the type that defines numerical values with 8 exact digits, and 2 of those digits are after the decimal point.
category: Type text. It’s NOT_NULL.
description: Type text. It can be NULL or NOT_NULL.
seller_user_id: Type text. NOT_NULL.
list_date: Type date. It is the type to store dates. It’s NOT_NULL.
buyer_user: Type text. It can be NULL or NOT_NULL.
purchase_date: Type date. It can be NULL or NOT_NULL.
*/


-- 2. Data Loading (COPY commands) –


COPY users FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/users.csv' DELIMITER ',' CSV HEADER;


COPY phones FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/phones.csv' DELIMITER ',' CSV HEADER;


COPY buyers FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/buyers.csv' DELIMITER ',' CSV HEADER;


COPY sellers FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/sellers.csv' DELIMITER ',' CSV HEADER;


COPY items FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/items.csv' DELIMITER ',' CSV HEADER;


COPY goods FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/goods.csv' DELIMITER ',' CSV HEADER;


COPY pictures FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/pictures.csv' DELIMITER ',' CSV HEADER;


COPY ads FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/ads.csv' DELIMITER ',' CSV HEADER;


COPY ratings FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/ratings.csv' DELIMITER ',' CSV HEADER;


COPY services FROM '/Users/cememirsenyurt/Desktop/Homework1/Interchange CSV/services.csv' DELIMITER ',' CSV HEADER;




-- 3. Query Answers --


-- Problem A –
SELECT 
        (SELECT COUNT(*) FROM users) AS num_users,
        (SELECT COUNT(*) FROM items) AS num_items,
        (SELECT COUNT(*) FROM ads)   AS num_ads;



        -- Problem B –
SELECT u.user_id, email, first_name, last_name, zip
FROM users as u, buyers as b, sellers as s
WHERE s.user_id = b.user_id AND 
                u.user_id = s.user_id AND
                        email LIKE '%aol.com';


        -- Problem C –
SELECT i.item_id, i.name, i.category, i.price
FROM items as i, sellers as s, users as u
WHERE i.seller_user_id = s.user_id AND
        u.user_id = s.user_id AND
        u.email = 'Molina58@gmail.com'
ORDER BY i.price DESC;



        -- Problem D –
SELECT i.category, COUNT(i.item_id) as num_items, ROUND(AVG(i.price), 2) as avg_price
FROM items as i, sellers as s, users as u
WHERE i.seller_user_id = s.user_id AND
        u.user_id = s.user_id AND
        u.email = 'Molina58@gmail.com'
GROUP BY i.category;


        -- Problem E –
SELECT u.last_name || CASE WHEN u.first_name IS NOT NULL THEN ', ' || u.first_name ELSE '' END as full_name, 
        u.email, COUNT(DISTINCT i.category)
FROM users as u, items as i, sellers as s
WHERE i.seller_user_id = s.user_id AND
        s.user_id = u.user_id
GROUP BY u.last_name, u.first_name, u.email
HAVING COUNT(DISTINCT i.category) <= 5;

        -- Problem F –
SELECT DISTINCT u.user_id, u.email
FROM interchange.users u, interchange.items i, interchange.sellers s
WHERE i.seller_user_id = u.user_id AND
      u.user_id = s.user_id AND 
      i.category IN ('Electronics', 'Toys & Games') AND 
      u.user_id NOT IN (
        SELECT DISTINCT s.user_id
        FROM interchange.items i, interchange.sellers s
        WHERE i.seller_user_id = s.user_id AND
              i.category IN ('Home & Kitchen', 'Pet Supplies')
      )
GROUP BY u.user_id, u.email
ORDER BY u.user_id ASC;
        


        -- Problem G –
SELECT u.email, u.state, COUNT(DISTINCT interests) AS num_interests
FROM users u, UNNEST(string_to_array(u.categories, ';')) AS interests
GROUP BY u.user_id, u.email, u.state
ORDER BY num_interests DESC
LIMIT 10;




-- Problem H --
SELECT interests, COUNT(*) AS num_users
FROM (
  SELECT UNNEST(string_to_array(categories, ';')) AS interests
  FROM Users
) AS category_list
GROUP BY interests
ORDER BY num_users DESC;



        -- Problem I --                                                                 
  -- View DDL:
CREATE VIEW RatedSellers AS
SELECT u.last_name, u.first_name, r.seller_id,
        0.4*ROUND(AVG(r.quality), 2) + 0.4*ROUND(AVG(r.pricing), 2) + 0.2*ROUND(AVG(r.delivery), 2) as overall,
       ROUND(AVG(r.quality), 2) as quality, ROUND(AVG(r.pricing), 2) as pricing , ROUND(AVG(r.delivery), 2) as delivery
FROM users u, ratings r, sellers s
WHERE u.user_id = s.user_id AND
                s.user_id = r.seller_id
GROUP BY r.seller_id, u.last_name, u.first_name
HAVING AVG(r.quality) IS NOT NULL AND AVG(r.pricing) IS NOT NULL AND AVG(r.delivery) IS NOT NULL;






  -- View test query:
SELECT * FROM RatedSellers ORDER BY overall DESC LIMIT 10;
        


-- Problem J --                                                                 
  -- Table alteration DDL:
ALTER TABLE sellers ADD COLUMN rating FLOAT;


  -- Table update query:
UPDATE sellers
SET rating = rs.overall
FROM RatedSellers rs
WHERE rs.seller_id = sellers.user_id;

  -- Change verification query:
SELECT s.rating, rs.*
FROM sellers s, RatedSellers rs
WHERE s.user_id = rs.seller_id AND
                s.rating = rs.overall
ORDER BY s.rating DESC;




-- Problem K --                                                     
  -- Query against view:
        SELECT seller_id, overall
FROM RatedSellers
WHERE overall >= 4.5;


  -- Index DDL:


CREATE INDEX sellers_rating_index ON sellers(rating);

  -- Query against materialized data:


SELECT user_id as seller_id, rating as overall 
FROM sellers 
WHERE rating >= 4.5;


/*        
        -- Performance Analysis:


So, it is visible that the VIEW (RatedSellers) involved many Inner Joins and Aggregations, on the other hand, INDEX over Sellers performed very well and there is only one arrow which leads to the solution. Since, INDEX is very useful in terms of retrieving data from databases faster especially in larger dataset (and question asks what would you expect to happen if database grows), it might be very useful to use in the future.
*/


-- Problem L -- 
SELECT COALESCE(i.category, 'ALL') AS category, COALESCE(ad.plan, 'ALL') AS plan, COUNT(*) AS num_ads
FROM interchange.items i, interchange.ads ad
WHERE ad.item_id = i.item_id AND
        i.category NOT LIKE '%&%' AND 
                i.category <> 'Others' AND 
                        ad.plan IN ('platinum', 'gold', 'silver')
GROUP BY ROLLUP(i.category, ad.plan)
ORDER BY num_ads DESC;


-- Problem M --    
                                                            
  -- Limit-based query:
SELECT u.email, u.state, COUNT(DISTINCT interests) AS num_interests
FROM interchange.users u, UNNEST(string_to_array(u.categories, ';')) AS interests
WHERE u.state = 'California'
GROUP BY u.email, u.state
LIMIT 1;


 -- Ranking-based query:
        SELECT email, state, num_interests
FROM(
        SELECT u.email, u.state, COUNT(DISTINCT interests) AS num_interests,
                DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT interests) DESC) AS ranking
        FROM interchange.users u, UNNEST(string_to_array(u.categories, ';')) AS interests
        WHERE u.state = 'California'
        GROUP BY u.email, u.state
)subq
WHERE ranking = 1;

CREATE TABLE client_info (
  client_info_id SERIAL PRIMARY KEY,
  client_name varchar(255) NOT NULL,
  client_email varchar(255) NOT NULL,
  client_age integer NOT NULL
);

CREATE TABLE client_interests (
  client_interests_id SERIAL PRIMARY KEY,
  client_interest varchar(255) NOT NULL
);
 
CREATE TABLE client_info_interests (
  client_interests_id integer REFERENCES client_interests,
  client_info_id integer REFERENCES client_info
);

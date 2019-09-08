
CREATE TABLE musician_info (
  musician_info_id SERIAL PRIMARY KEY,
  musician_name varchar(255) NOT NULL,
  musician_dob date NOT NULL,
  musician_dod date
);

CREATE TABLE musician_characteristic (
  musician_characteristic_id SERIAL PRIMARY KEY,
  musician_characteristic varchar(255) NOT NULL
);
 
CREATE TABLE musician_info_characteristic (
  musician_characteristic_id integer REFERENCES musician_characteristic,
  musician_info_id integer REFERENCES musician_info
);

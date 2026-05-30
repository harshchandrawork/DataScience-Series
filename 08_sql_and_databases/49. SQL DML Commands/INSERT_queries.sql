CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR (255),
    email VARCHAR (255) NOT NULL UNIQUE,
    password VARCHAR (255) NOT NULL
);

INSERT INTO users (user_id, name, email, password)
VALUES (DEFAULT, 'neji', 'neji@email.com', '1234');

INSERT INTO users (name, email, password)
VALUES ('moneyk', 'moneyl@email.com', '1234');

INSERT INTO public.users (name, email, password)
VALUES ('ankit', 'ankit@email.com', '1234');

INSERT INTO learningdb.public.users (name, email, password)
VALUES ('hola', 'hola@email.com', '1234');

INSERT INTO learningdb.public.users
VALUES (8, 'gola', 'gola@email.com', '1234');

INSERT INTO learningdb.public.users (name, email)
VALUES ('trola', 'trola@email.com');

INSERT INTO users
VALUES (DEFAULT, 'sasuke', 'sasuke@email.com', '1234'),
       (DEFAULT, 'sakura', 'sakura@email.com', '1234'),
       (DEFAULT, 'narut', 'narut@email.com', '1234');
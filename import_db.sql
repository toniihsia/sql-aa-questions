DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  users_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  parent_reply INTEGER,
  users_id INTEGER NOT NULL,

  FOREIGN KEY (parent_reply) REFERENCES replies(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (users_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Jay', 'Hwang'),
  ('Tonia', 'Hsia'),
  ('Human', 'Species'),
  ('Human2', 'Species'),
  ('Human3', 'Species');

INSERT INTO
  questions (title, body, users_id)
VALUES
  ('title', 'body', (SELECT id FROM users WHERE fname = 'Jay')),
  ('title2', 'body2', (SELECT id FROM users WHERE fname = 'Tonia')),
  ('Human''s question', 'How do you SQL?', (SELECT id FROM users WHERE fname = 'Human')),
  ('Human''s second question', 'How do you SQLite', (SELECT id FROM users WHERE fname = 'Human')),
  ('Human2''s question', 'What?', (SELECT id FROM users WHERE fname = 'Human2')),
  ('Human3''s question', 'How?', (SELECT id FROM users WHERE fname = 'Human3')),
  ('Human2''s second question', 'Who?', (SELECT id FROM users WHERE fname = 'Human2')),
  ('Human2''s third question', 'Am I a human species?', (SELECT id FROM users WHERE fname = 'Human2'));

INSERT INTO
  replies (body, question_id, users_id)
VALUES
  ('body',
    (SELECT id FROM questions WHERE title = 'title'),
    (SELECT id FROM users WHERE fname = 'Jay')),

  ('body2',
    (SELECT id FROM questions WHERE title = 'title2'),
    (SELECT id FROM users WHERE fname = 'Tonia')),

  ('I don''t know how to SQL',
    (SELECT id FROM questions WHERE title = 'Human''s question'),
    (SELECT id FROM users WHERE fname = 'Jay')),

  ('I don''t know how to SQLITE',
    (SELECT id FROM questions WHERE title = 'Human''s second question'),
    (SELECT id FROM users WHERE fname = 'Jay')),

  ('Yes, you are a human species',
    (SELECT id FROM questions WHERE title = 'Human2''s third question'),
    (SELECT id FROM users WHERE fname = 'Human')),

  ('No, you are not a human. You can never become a human!',
    (SELECT id FROM questions WHERE title = 'Human2''s third question'),
    (SELECT id FROM users WHERE fname = 'Tonia')),

  ('Don''t hate',
    (SELECT id FROM questions WHERE title = 'Human2''s third question'),
    (SELECT id FROM users WHERE fname = 'Jay'));

  INSERT INTO
    question_follows (user_id, question_id)
  VALUES
    ((SELECT id FROM users WHERE fname = 'Tonia'), (SELECT id FROM questions WHERE id = 3)),
    ((SELECT id FROM users WHERE fname = 'Human'), (SELECT id FROM questions WHERE id = 3)),
    ((SELECT id FROM users WHERE fname = 'Jay'), (SELECT id FROM questions WHERE id = 5)),
    ((SELECT id FROM users WHERE fname = 'Human2'), (SELECT id FROM questions WHERE id = 5)),
    ((SELECT id FROM users WHERE fname = 'Human3'), (SELECT id FROM questions WHERE id = 1));

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Tonia'), (SELECT id FROM questions WHERE id = 3)),
  ((SELECT id FROM users WHERE fname = 'Jay'), (SELECT id FROM questions WHERE id = 3)),
  ((SELECT id FROM users WHERE fname = 'Human2'), (SELECT id FROM questions WHERE id = 2)),
  ((SELECT id FROM users WHERE fname = 'Human3'), (SELECT id FROM questions WHERE id = 3));

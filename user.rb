require_relative 'questions_db_connection'
require_relative 'question'
require_relative 'question_like'
require_relative 'question_follow'

class User
  def self.find_by_id(id)
    user = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    return nil if user.length < 1
    User.new(user.first)
  end

  def self.find_by_name(name)
    user = QuestionsDBConnection.instance.execute(<<-SQL, name)
      SELECT
        *
      FROM
        users
      WHERE
        name = ?
    SQL

    return nil if user.length < 1
    User.new(user.first)
  end

  attr_accessor :id, :fname, :lname

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    karma = QuestionsDBConnection.instance.execute(<<-SQL, @id)
      SELECT
        COUNT(DISTINCT questions.id) / CAST(COUNT(question_likes.user_id) AS FLOAT) AS average
      FROM questions
      LEFT OUTER JOIN question_likes
        ON question_likes.question_id = questions.id
        WHERE questions.users_id = ?
    SQL

    karma[0]['average']
  end

  def save
    if User.find_by_name(@id).nil?
      QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname)
        INSERT INTO
          users (@fname, @lname)
        VALUES
          (?, ?)
      SQL

      @id = QuestionsDBConnection.instance.last_insert_row_id
    else
      QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
        UPDATE
          users
        SET
          fname = ?, lname = ?
        WHERE
          id = ?
      SQL
    end

  end

end

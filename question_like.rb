require_relative 'questions_db_connection'
require_relative 'question'
require_relative 'user'

class QuestionLike
  def self.find_by_id(id)
    question_like = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL

    return nil if question_like.length < 1
    QuestionLike.new(question_like.first)
  end

  def self.likers_for_question_id(question_id)
    users = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN question_likes ON question_likes.user_id = users.id
      WHERE
        question_id = ?
    SQL

    raise "No one likes you" if users.empty?
    users.map { |user| User.new(user) }
  end

  def self.num_like_for_question_id(question_id)
    num_likes = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT COUNT(*)
      FROM users
      JOIN question_likes ON question_likes.user_id = users.id
      WHERE question_id = ?;
    SQL

    raise "No likes" if num_likes.empty?
    num_likes.map { |num| num.to_i }
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id,
        questions.title,
        questions.body,
        questions.users_id
      FROM
        questions
        JOIN question_likes ON question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL

    raise "You dont like anyone's questions" if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, n)
      SELECT
        questions.id
      FROM questions
        JOIN question_likes ON question_likes.question_id = questions.id
      GROUP BY question_id
      ORDER BY COUNT(user_id) DESC
      LIMIT ?
    SQL

    raise "No questions liked. Lulz" if questions.empty?
    questions.map { |question| Question.find_by_id(question['id']) }
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['quesiton_id']
  end
end

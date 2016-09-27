require 'byebug'
require_relative 'questions_db_connection'
require_relative 'question'

class QuestionsFollow
  def self.find_by_id(id)
    question_follow = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL

    return nil if question_follow.length < 1
    QuestionFollow.new(question_follow.first)
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
       *
      FROM
        users
        JOIN questions ON questions.users_id = users.id
      WHERE
        question.id = ?
    SQL

    raise "You have no followers" if users.empty?
    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM questions
        JOIN users ON questions.users_id = users.id
      WHERE
        users.id = ?
    SQL

    raise "You are not following any questions" if questions.empty?
    questions.map { |question| Question.new(question) }
  end

  def self.most_followed_questions(n)
    question_ids = QuestionsDBConnection.instance.execute(<<-SQL, n)
      SELECT
        questions.id
      FROM questions
        JOIN question_follows ON question_follows.question_id = questions.id
      GROUP BY question_id
      ORDER BY COUNT(user_id) DESC
      LIMIT ?
    SQL

    raise "no followed questions" if question_ids.empty?
    question_ids.map do |question|
      Question.find_by_id(question['id'])
    end
  end

  attr_accessor :id, :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end

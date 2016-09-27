class Reply
  def self.find_by_id(id)
    reply = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    return nil if reply.length < 1
    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        users_id = ?
    SQL

    return nil unless replies.length > 0
    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    return nil unless replies.length > 0
    replies.map { |reply| Reply.new(reply) }
  end

  attr_accessor :id, :body, :question_id, :parent_reply, :users_id

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @parent_reply = options['parent_reply']
    @users_id = options['users_id']
  end

  def author
    @users_id
  end

  def question
    Question.find_by_question_id(@question_id)
  end

  def parent_reply
    raise "There is no parent reply. You're an orphan reply." if @parent_reply == nil
    Reply.find_by_id(@parent_reply)
  end

  def child_replies
    child_replies = QuestionsDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL

    raise "There is no child reply. You are barren." if child_replies.empty?
    child_replies.map { |reply| Reply.new(reply) }
  end


end

class SuperClass
  def self.find_by_id(table_name, id)
    user = QuestionsDBConnection.instance.execute(<<-SQL, table_name, id)
      SELECT
        *
      FROM
        ?
      WHERE
        id = ?
    SQL

    # return nil if user.length < 1
    # User.new(user.first)
  end
end

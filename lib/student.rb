require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id

  def initialize(id = nil, name, grade)
    self.id = id
    self.name = name
    self.grade = grade
  end

  def self.create_table
    sql =  <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id != nil
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
    self.new_from_dbDB[:conn].execute("SELECT * FROM students WHERE id = (?)", self.id ).flatten

  end

  def self.create(name, grade)
    new_obj = self.new(name, grade)
    new_obj.save
    new_obj
  end

  def self.new_from_db(row)
    self.new(row[0], row[1], row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?;
    SQL

    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end
end

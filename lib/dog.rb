require 'pry'
class Dog

  attr_accessor :name, :breed
  attr_reader :id


  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table

    sql = <<-SQL
        DROP TABLE IF EXISTS dogs
          SQL
    DB[:conn].execute(sql)
  end

  def new_from_database(row)

  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
          INSERT INTO dogs (name, breed) VALUES (?,?)
            SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end
  end

  def self.create( name:, breed:)

    dog = self.new(name:name, breed:breed)
    dog.save
  end

  def update
    sql = <<-SQL
    "UPDATE dogs SET id = ?, name = ?, breed = ? WHERE id = ?"
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
      SQL
    result = DB[:conn].execute(sql, id)[0]
    self.new(id: result[0], name: result[1], breed: result[2])

  end

  def self.find_or_create_by(name:, breed:)

    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      binding.pry
      dog_data = dog[0]
      dog = self.new(id: dog[0], name: dog[1], breed: dog[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    binding.pry
    dog
  end
end

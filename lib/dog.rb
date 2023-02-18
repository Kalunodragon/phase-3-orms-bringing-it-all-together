class Dog
  attr_accessor :name, :breed, :id

  def initialize name:, breed:, id: nil
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create name:, breed:
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(r)
    self.new(id: r[0], name: r[1], breed: r[2])
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM dogs
    SQL
    DB[:conn].execute(sql).map do |r|
      self.new_from_db(r)
    end
  end

  def self.find_by_name name
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE dogs.name = ?
    SQL
    DB[:conn].execute(sql, name).map do |r|
      self.new_from_db(r)
    end.first
  end

  def self.find id
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE dogs.id = ?
    SQL
    DB[:conn].execute(sql, id).map do |r|
      self.new_from_db(r)
    end.first
  end

end

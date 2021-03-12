
class Dog
    attr_accessor :id

    def initialize(attributes)
        @id = nil
        attributes.each do |key, value|
            self.class.attr_accessor(key)
            self.send(("#{key}="), value)
        end
    end

    def self.create_table
        sql =  <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else 
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            return self
        end
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = self.new({id: row[0], name: row[1], breed: row[2]})
        dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        Dog.new({id: result[0], name: result[1], breed: result[2]})
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        Dog.new({id: result[0], name: result[1], breed: result[2]})
    end
    
    def self.find_or_create_by(attributes)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL
        object = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
        if !object.empty?
            object = self.new(id: object[0][0], name: object[0][1], breed: object[0][2])
        else
            object = self.create(attributes)
        end
        object
    end

end
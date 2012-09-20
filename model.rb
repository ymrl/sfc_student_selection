require 'sequel'
Sequel::Model.plugin(:schema)
DB = Sequel.connect("sqlite://db/sfs.db")

class Lecture < Sequel::Model
  set_schema do
    primary_key :id
    String :title        , :size=>255
    String :instructor   , :size=>255    
    String :yc           , :size=>255
    String :ks           , :size=>255
    String :place        , :size=>255
    TrueClass :selection
    TrueClass :finished
    Integer :applicants
    Integer :limit
    Float :odds
  end
  one_to_many :permissions
end
class Permission < Sequel::Model
  set_schema do
    primary_key :id
    String :number,        :size=>255
    Integer :lecture_id
  end
  many_to_one :lecture
end

Lecture.create_table if !Lecture.table_exists?
Permission.create_table if !Permission.table_exists?

require 'sequel'
Sequel::Model.plugin(:schema)
Sequel.connect("sqlite://db/senbatsu.db")

class LectureModel < Sequel::Model
  set_schema do
    primary_key :id
    string :serial
    string :title
    bool :selection
    bool :finished
  end
end
class PermissionModel < Sequel::Model
  set_schema do
    primary_key :id
    string :number
    string :lecture_serial
    string :lecture_title
  end
end

LectureModel.create_table if !LectureModel.table_exists?
PermissionModel.create_table if !PermissionModel.table_exists?

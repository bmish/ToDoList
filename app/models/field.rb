class Field < ActiveRecord::Base
  NONE = 0
  DONE = 1
  TITLE = 2
  CATEGORY = 3
  PRIORITY = 4
  CREATED = 5
  UPDATED = 6
  START = 7
  DUE = 8
  UNDERWAY = 9
  BLOCKED = 10
  LOCATION = 11
  FREQUENCY = 12
  DEPENDEE = 13
  STATUS = 14
  DELETED = 15

  def field
    return Field.getFieldFromString(self.name)
  end

  def isValid value
    if !value
      return false
    end

    if self.field == Field::CATEGORY && !(value.to_i > 0)
      return false
    elsif self.field == Field::PRIORITY && !(value.to_i >= 0 && value.to_i <= 3)
      return false
    elsif self.dataType == "string" && value.empty?
      return false
    end

    return true
  end

  def orderString
    sql = ''
    if (self.dataType == "string")
      sql += "lower("
    end
    sql += self.titleForDB
    if (self.dataType == "string")
      sql += ")"
    end
    return sql
  end

  def self.getDBFieldFromField field
    return Field.where(name: Field.getStringFromField(field)).first
  end

  def self.getStringFromField field
    str = ''
    if field == Field::DONE
      str = "done"
    elsif field == Field::TITLE
      str = "title"
    elsif field == Field::CATEGORY
      str = "category"
    elsif field == Field::PRIORITY
      str = "priority"
    elsif field == Field::CREATED
      str = "created_at"
    elsif field == Field::UPDATED
      str = "updated_at"
    elsif field == Field::START
      str = "start"
    elsif field == Field::DUE
      str = "due"
    elsif field == Field::UNDERWAY
      str = "underway"
    elsif field == Field::BLOCKED
      str = "blocked"
    elsif field == Field::LOCATION
      str = "location"
    elsif field == Field::FREQUENCY
      str = "frequency"
    elsif field == Field::DEPENDEE
      str = "dependee"
    elsif field == Field::STATUS
      str = "status"
    elsif field == Field::DELETED
      str = "deleted"
    else
      str = "none"
    end
    return str
  end

  def self.getFieldFromString str
    if str
      str = str.downcase
    end

    field = nil
    if str == 'done'
      field = Field::DONE
    elsif str == 'title'
      field = Field::TITLE
    elsif str == 'category'
      field = Field::CATEGORY
    elsif str == 'priority'
      field = Field::PRIORITY
    elsif str == 'created_at'
      field = Field::CREATED
    elsif str == 'updated_at'
      field = Field::UPDATED
    elsif str == 'start'
      field = Field::START
    elsif str == 'due'
      field = Field::DUE
    elsif str == 'underway'
      field = Field::UNDERWAY
    elsif str == 'blocked'
      field = Field::BLOCKED
    elsif str == 'location'
      field = Field::LOCATION
    elsif str == 'frequency'
      field = Field::FREQUENCY
    elsif str == 'dependee'
      field = Field::DEPENDEE
    elsif str == 'status'
      field = Field::STATUS
    elsif str == 'deleted'
      field = Field::DELETED
    else
      field = Field::NONE
    end
    return field
  end
end
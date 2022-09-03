# frozen_string_literal: true

require 'json'
require 'json/add/core'

# mixin
module BasicSerializable
  # should point to a class; change to a different
  # class (e.g. MessagePack, JSON, YAML) to get a different
  # serialization

  def serialize_util
    obj = {}
    instance_variables.map do |var|
      skip = false
      skip = yield(obj, var) if block_given?
      next if skip == true

      var_value = instance_variable_get(var)
      obj[var] = if %w[Integer String NilClass Array Hash FalseClass TrueClass].include?(var_value.class.to_s)
                   var_value
                 else
                   var_value.serialize_util
                 end
    end
    obj
  end

  def serialize
    JSON.dump serialize_util
  end

  def unserialize(obj)
    obj.each_key do |key|
      skip = false
      skip = yield(obj, key) if block_given?
      next if skip == true

      instance_variable_set(key, obj[key])
    end
  end
end

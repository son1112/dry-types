module Dry
  module Data
    class Type
      class Hash < Type
        def self.safe_constructor(hash_constructor, value_constructors, input)
          attributes = hash_constructor[input]

          value_constructors.each_with_object({}) do |(key, value_constructor), result|
            result[key] = value_constructor[attributes[key]]
          end
        end

        def self.strict_constructor(hash_constructor, value_constructors, input)
          attributes = hash_constructor[input]

          value_constructors.each_with_object({}) do |(key, value_constructor), result|
            begin
              value = attributes.fetch(key)
              result[key] = value_constructor[value]
            rescue TypeError
              raise SchemaError.new(key, value)
            rescue KeyError
              raise SchemaKeyError.new(key)
            end
          end
        end

        def strict(type_map)
          schema(type_map, :strict_constructor)
        end

        def schema(type_map, meth = :safe_constructor)
          value_constructors = type_map.each_with_object({}) { |(name, type_id), result|
            result[name] = Data[type_id]
          }

          self.class.new(
            self.class.method(meth).to_proc.curry.(constructor, value_constructors),
            primitive
          )
        end
      end
    end
  end
end
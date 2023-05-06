class StateSerializer
  include JSONAPI::Serializer
  attributes :name, :districts
end

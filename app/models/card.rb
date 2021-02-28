class Card
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :name, type: String
  validates :name, uniqueness: true
end

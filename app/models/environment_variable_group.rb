class EnvironmentVariableGroup < ActiveRecord::Base
  has_and_belongs_to_many :stages
  has_many :environment_variables

  accepts_nested_attributes_for :environment_variables

  default_scope -> { order(:name) }

  validates_presence_of :name
end

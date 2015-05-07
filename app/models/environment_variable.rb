class EnvironmentVariable < ActiveRecord::Base
  belongs_to :environment_variable_group

  validates_presence_of :key, :value, :scope
end

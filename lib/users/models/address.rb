# frozen_string_literal: true

module Users
  module Models
    class Address < ActiveRecord::Base
      include Shared::Concerns::Uuid

      belongs_to :user
    end
  end
end

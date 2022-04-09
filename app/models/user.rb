class User < ApplicationRecord
  has_many :sleeps, dependent: :destroy
end

class User < ApplicationRecord
  has_secure_password
  has_many :analyzes
  has_one_attached :video
end
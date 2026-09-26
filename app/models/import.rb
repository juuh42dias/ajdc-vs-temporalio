class Import < ApplicationRecord
  has_many :import_items, dependent: :delete_all
end

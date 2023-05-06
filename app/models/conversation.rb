class Conversation < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy

  has_noticed_notifications method_name: 'Notification'
end

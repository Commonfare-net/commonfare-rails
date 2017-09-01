class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :meta, polymorphic: true, optional: true, dependent: :destroy
  # you may need to check this out http://astockwell.com/blog/2014/07/polymorphic-associations-in-rails-4-part-2/

  delegate :name, to: :meta
end

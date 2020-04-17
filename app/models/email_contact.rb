# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.

class EmailContact < ActiveRecord::Base
  before_save { email.try(:downcase!) }
  
  validates :email, length: { maximum: 256 }, allow_blank: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
                  
  def self.admins_search(string)
    active_database = Rails.configuration.database_configuration[Rails.env]["adapter"]
    # Postgres requires created_at to be cast to a string
    created_at_query = if active_database == "postgresql"
      "created_at::text"
    else
      "created_at"
    end

    search_query = "email_contacts.email LIKE :search OR email_contacts.#{created_at_query} LIKE :search"

    search_param = "%#{string}%"

    where(search_query, search: search_param)
  end
  
  def self.admins_order(column, direction)
    return order(Arel.sql("email_contacts.#{column} #{direction}")) if column_names.include?(column)

  end
  
end

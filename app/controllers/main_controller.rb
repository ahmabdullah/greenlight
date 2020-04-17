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

class MainController < ApplicationController
  include Registrar
  # GET /
  def index
    #abort(ENV.inspect)
    # Store invite token
    unless params[:meeting].blank?
      @meeting = params[:meeting].titleize
      @room_running = room_running?(@meeting)
    end
    unless params[:errors].blank?
      errors_json = JSON.parse(params[:errors])
      unless errors_json.blank?
        errors = errors_json[0]
      else
        errors = errors_json
      end
      redirect_to root_path, flash: { alert: errors["message"] }
    end
    session[:invite_token] = params[:invite_token] if params[:invite_token] && invite_registration
  end
  
  def mail_data_save
    #actions on data here
    email_contact = EmailContact.new
    email_contact.email = params[:email]
    email_contact.save
    respond_to do |format|
      format.js
    end
  end
  
  # POST /demo_meeting
  def demo_meeting
    unless params[:meetingname].blank?
      meeting_name = params[:meetingname].titleize
      join_as_moderator = false
    else
      meeting_name = "Demo Meeting " + rand(2000..5000).to_s
      join_as_moderator = true
    end
    logger.info "Support: #{params[:username]} is starting room #{meeting_name}"
    
    #o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    moderator_pw = "moderator8597"
    
    #o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    attendee_pw = "attendee5879"
    
    opts = {}
    opts[:user_is_moderator] = join_as_moderator
    opts[:mute_on_start] = false
    opts[:require_moderator_approval] = false
    opts[:anyone_can_start] = true
    opts[:all_join_moderator] = false
    opts[:meeting_logout_url] = request.base_url + "/"
    opts[:moderator_message] = "<b>To invite someone to the meeting, send them this link: </b><p style='font-weight: bold; font-size: 14px;'>" + request.base_url + "?meeting=" + meeting_name.parameterize  + "</p>"
    #abort(opts.inspect)
    begin
      redirect_to demo_join_path(meeting_name, params[:username], opts, moderator_pw, attendee_pw)
    rescue BigBlueButton::BigBlueButtonException => e
      logger.error("Support: #{meeting_name} start failed: #{e}")

      redirect_to root_path, alert: I18n.t(e.key.to_s.underscore, default: I18n.t("bigbluebutton_exception"))
    end

  end
end

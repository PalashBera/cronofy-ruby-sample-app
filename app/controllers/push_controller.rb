class PushController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  skip_before_action :authorize

  def call
    channel = Channel.find { |channel| channel.path == params[:path] }

    unless channel.nil?
      body = params[:notification].keys.map { |key| "#{key}: #{params[:notification][key]}" }.join("\n")
      channel.last_body = "#{body}\n\n#{channel.last_body}"
      channel.last_called = Time.now
      channel.save
    end
  end
end
# frozen_string_literal: true

class NotificationActionBarComponent < ApplicationComponent
  attr_accessor :state, :update_all_path, :show_read_all_button

  def initialize(state:, update_all_path:, show_read_all_button: false)
    super

    @state = state
    @update_all_path = update_all_path
    @show_read_all_button = show_read_all_button
  end

  def button_text(all: false)
    text = %w[all unread].include?(state) ? 'Read' : 'Unread'
    if all
      "Mark all as '#{text}'"
    else
      "Mark selected as '#{text}'"
    end
  end

  def disable_with_content(all: false)
    spinner = tag.i(class: 'fas fa-spinner fa-spin ms-2')
    button_text(all: all) + spinner
  end
end

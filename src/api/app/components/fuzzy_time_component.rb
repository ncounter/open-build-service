# frozen_string_literal: true

class FuzzyTimeComponent < ApplicationComponent
  attr_reader :time

  def initialize(time:)
    super
    @time = time.utc
  end

  def human_time_ago
    now = Time.now.utc
    diff = now - time
    return 'now' if diff.abs < 60

    if diff.positive?
      "#{time_ago_in_words(time)} ago"
    else
      "in #{distance_of_time_in_words(now, time)}"
    end
  end
end

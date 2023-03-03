require 'rails_helper'

RSpec.describe FuzzyTimeComponent, type: :component do
  context 'time is in the past' do
    let(:time) { 2.days.ago }

    it { expect(render_inline(described_class.new(time: time))).to have_text('ago') }
  end

  context 'time in the last minute is present' do
    let(:time) { 1.second.ago }

    it { expect(render_inline(described_class.new(time: time))).to have_text('now') }
  end

  context 'time in the next minute is present' do
    let(:time) { 10.second.since }

    it { expect(render_inline(described_class.new(time: time))).to have_text('now') }
  end

  context 'time is in the future' do
    let(:time) { 1.day.since }

    it { expect(render_inline(described_class.new(time: time))).to have_text('in') }
  end
end

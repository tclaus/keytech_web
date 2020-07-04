# frozen_string_literal: true

require 'test_helper'

class RemoveUnconfirmedAccountsJobTest < ActiveJob::TestCase
  test 'That old unconfirmed accounts will be deleted' do
    # Create unconfirmed account
    now = Date.today
    time_ago = (now - 10.days)
    user = User.create(email: 'spam@example.com', password: '123-test')
    user.created_at = time_ago
    assert user.save!
    # Remove it
    RemoveUnconfirmedAccountsJob.perform_now
    assert_no_match User.last.email, 'spam@example.com'
  end
end

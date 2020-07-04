# frozen_string_literal: true

## Remove any fake mails that are not confirmed for a preiod of time
class RemoveUnconfirmedAccountsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    remove_unconfirmed_accounts
  end

  private

  def remove_unconfirmed_accounts
    time_ago = Date.today - 3.days
    invalid_users = User.where('sign_in_count = 0 and created_at < ?', time_ago)
    logger.info("Delete #{invalid_users.count} invalid user accounts")
    invalid_users.delete_all
  end
end

class Payment < ApplicationRecord
      has_one :reservations
      validates :already_payed, comparison: {greather_than_or_equal_to: 0, less_than_or_equal_to: :total}
      validates :payment_method, presence: true
      enum :status, {not_paid: 0, in_process: 1, paid: 2}
      validates :total, presence: true, comparison: {greather_than_or_equal_to: :already_payed}
end

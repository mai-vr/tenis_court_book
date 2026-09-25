class Payment < ApplicationRecord
      has_one :reservation

      AVAILABLE_METHODS = [
      { id: "cash", label: "Efectivo" },
      { id: "qr", label: "QR" },
      { id: "mercado_pago", label: "Mercado Pago" }
      ]   

      validates :payment_method, presence: true, inclusion: { in: AVAILABLE_METHODS.map { |method| method[:id] } }
      enum :status, {not_paid: 0, in_process: 1, paid: 2}, prefix: true      
      validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :already_payed, presence: true, numericality: { greater_than_or_equal_to: 0 }
      validates :already_payed, comparison: { less_than_or_equal_to: :total }, if: -> { total.present? && already_payed.present? }
end

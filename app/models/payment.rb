class Payment < ApplicationRecord
      has_one :reservation

      AVAILABLE_METHODS = [
      { id: "cash", label: "Efectivo" },
      { id: "qr", label: "QR" },
      { id: "mercado_pago", label: "Mercado Pago" }
      ]
      enum :status, { not_paid: 0, in_process: 1, paid: 2 }, prefix: true

      validates :payment_method, presence: true, inclusion: { in: AVAILABLE_METHODS.map { |method| method[:id] }, message: "no es un método de pago válido" }
      validates :status, presence: true, inclusion: { in: statuses.keys }
      validates :total, presence: true, numericality: { greater_than: 0 }
      validates :already_payed, presence: true, comparison: { less_than_or_equal_to: :total, message: "no puede ser mayor que el monto total" }, if: -> { total.present? && already_payed.present? }

      validate :status_matches_already_payed, if: -> { total.present? && already_payed.present? && status.present? }

      private
      def status_matches_already_payed
            if status_paid? && already_payed < total
                  errors.add(:status, "no puede marcarse como pagado ('paid') si el monto abonado es menor al total")
            elsif status_not_paid? && already_payed > 0
                  errors.add(:already_payed, "If status is not paid, there must be an amount already paid")
            end
      end
end

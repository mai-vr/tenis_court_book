require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  def setup
    @payment = Payment.new(
      payment_method: "cash",
      status: :in_process,
      total: 3000,
      already_payed: 3000
    )
  end

  test "es válido con un método de pago y montos permitidos" do
    assert @payment.valid?
  end

  test "rechaza métodos de pago no configurados" do
    @payment.payment_method = "criptomoneda"
    refute @payment.valid?
    assert_includes @payment.errors[:payment_method], "no es un método de pago válido"
  end

  test "monto ya pagado no puede superar el total" do
    @payment.total = 2000
    @payment.already_payed = 2500
    refute @payment.valid?
    assert_includes @payment.errors[:already_payed], "no puede ser mayor que el monto total"
  end

  test "no se puede marcar como paid si el monto pagado es menor al total" do
    @payment.status = :paid
    @payment.total = 3000
    @payment.already_payed = 1500
    refute @payment.valid?
    assert_includes @payment.errors[:status], "no puede marcarse como pagado ('paid') si el monto abonado es menor al total"
  end
end

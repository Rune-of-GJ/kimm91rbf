import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    clientKey: String,
    amount: Number,
    orderName: String,
    successUrl: String,
    failUrl: String,
    customerKey: String,
    customerEmail: String,
    customerName: String,
  }
  static targets = ["payBtn"]

  async pay(event) {
    event.preventDefault()
    this.payBtnTarget.disabled = true
    this.payBtnTarget.textContent = "결제 준비 중..."

    try {
      const { loadTossPayments } = await import("https://js.tosspayments.com/v2/payment")
      const tossPayments = await loadTossPayments(this.clientKeyValue)
      const payment = tossPayments.payment({ customerKey: this.customerKeyValue })

      await payment.requestPayment({
        method: "CARD",
        amount: { currency: "KRW", value: this.amountValue },
        orderId: crypto.randomUUID(),
        orderName: this.orderNameValue,
        successUrl: this.successUrlValue,
        failUrl: this.failUrlValue,
        customerEmail: this.customerEmailValue,
        customerName: this.customerNameValue,
      })
    } catch (e) {
      if (e?.code !== "USER_CANCEL") {
        console.error("Toss payment error:", e)
      }
      this.payBtnTarget.disabled = false
      this.payBtnTarget.textContent = "결제하기"
    }
  }
}

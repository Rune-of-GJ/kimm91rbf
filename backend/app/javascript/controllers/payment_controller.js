import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    clientKey: String,
    amount: Number,
    orderName: String,
    successUrl: String,
    failUrl: String,
    customerEmail: String,
    customerName: String,
  }
  static targets = ["payBtn"]

  async pay(event) {
    event.preventDefault()
    this.payBtnTarget.disabled = true
    this.payBtnTarget.textContent = "결제 준비 중..."

    try {
      const tossPayments = TossPayments(this.clientKeyValue)
      await tossPayments.requestPayment("카드", {
        amount: this.amountValue,
        orderId: "order-" + Date.now() + "-" + Math.random().toString(36).slice(2, 9),
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

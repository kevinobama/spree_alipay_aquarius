#encoding: utf-8
module Spree
  CheckoutController.class_eval do
    before_filter :checkout_to_pay_money, :only => [:update]
    private
    def checkout_to_pay_money
      return unless current_order.next_step_complete?
      return unless params[:order][:payments_attributes].present?
      if pay_by_billing_integration?
        if params["state"]=="payment"
          redirect_to alipay_partner_trade_path(:payment_method_id => params[:order][:payments_attributes].first[:payment_method_id])
        end
      end
    end

    def pay_by_billing_integration?
      if @order.next_step_complete?
        payment_method_info=Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
        if payment_method_info.type.include? "Alipay"
          return true
        end
      end
      return false
    end

  end
end
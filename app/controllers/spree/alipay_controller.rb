module Spree
  class AlipayController < StoreController

    def partner_trade
      logger.debug "go to alipayment #{params.to_yaml}"
      order = current_order || raise(ActiveRecord::RecordNotFound)
      order.line_items.each do |item|
        @product_name=item.variant.product.name
      end
      payment = Spree::Payment.create({:order_id => order.id, :amount => order.amount,  :payment_method_id=> payment_method.id})
      payment.started_processing!
      partner_trade = payment_method.set_partner_trade( payment.number, order, spree.order_url(order) , notify_alipay_url, {:subject=> "#{current_store.name} #{@product_name} #{order.number}"})
      redirect_to partner_trade
    end

    private
  
    def payment_method
      Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def provider
      payment_method.provider
    end
  end
end
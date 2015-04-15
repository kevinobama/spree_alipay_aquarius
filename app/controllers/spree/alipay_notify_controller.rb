module Spree
  class AlipayNotifyController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def notify_web
      Alipay.pid = "2088002627298374"
      Alipay.key="f4y25qc539qakg734vn2jpqq6gmybxoz"
      Alipay.seller_email = "areq22@aliyun.com"

      # except :controller_name, :action_name, :host, etc.
      # {"discount"=>"0.02", "logistics_type"=>"POST", "receive_zip"=>"999077", "payment_type"=>"1", "subject"=>"TalkGoal #R381807226", "logistics_fee"=>"0.03","trade_no"=>"2014111830597476", "buyer_email"=>"test@testing.com", "gmt_create"=>"2014-11-18 17:49:28", "notify_type"=>"trade_status_sync", "quantity"=>"1", "logistics_payment"=>"BUYER_PAY", "out_trade_no"=>"R381807226", "seller_id"=>"1111002381708888", "notify_time"=>"2014-11-18 17:49:52","trade_status"=>"WAIT_SELLER_SEND_GOODS", "is_total_fee_adjust"=>"N", "gmt_payment"=>"2014-11-18 17:49:52", "total_fee"=>"0.04", "seller_email"=>"seller@test.com", "price"=>"0.01", "buyer_id"=>"3333602021013333", "gmt_logistics_modify"=>"2014-11-18 17:49:40", "receive_phone"=>"999999999", "notify_id"=>"fe67a9a70e7372f11aa65985a556a11111", "receive_name"=>"Arthur CHAN", "use_coupon"=>"N", "sign_type"=>"MD5", "sign"=>"a9999ba0aac13a0ff511977b71b78888", "receive_address"=>"中国香港 九龍"}
      notify_params = params.except(*request.path_parameters.keys)
      notify_params.delete('commit')
      #logger.debug "notify alipayment params #{params.to_yaml}"
      if Alipay::Notify.verify?(notify_params)
        #logger.debug " notify starting"
        logger.info notify_params.inspect
        
        # Valid notify, code your business logic.
        # trade_status is base on your payment type
        # Example:
        #
        # case params[:trade_status]
        # when 'WAIT_BUYER_PAY'
        # when 'WAIT_SELLER_SEND_GOODS'
        # when 'TRADE_FINISHED'
        # when 'TRADE_CLOSED'
        # end
        # Alipay workflow
        # WAIT_BUYER_PAY(等待买家付款)
        # WAIT_SELLER_SEND_GOODS(买家已付款，等待卖家发货)
        # WAIT_BUYER_CONFIRM_GOODS(卖家已发货，等待买家收货)
        # TRADE_FINISHED(买家已收货，交易完成)
        # 
        # Spree Order status
        # payment - The store is ready to receive the payment information for the order.
        # confirm - The order is ready for a final review by the customer before being processed.
        # complete 
        if notify_params[:trade_status] == 'WAIT_SELLER_SEND_GOODS' || notify_params[:trade_status] == 'TRADE_FINISHED'
          out_trade_no = notify_params[:out_trade_no]
          payment = Spree::Payment.find_by_number(out_trade_no) || raise(ActiveRecord::RecordNotFound)
          
          #payment.update_columns( :response_code => notify_params[:trade_no])
          logger.debug " notify order is updating"
          payment.complete!
          logger.debug " notify order ended"
#         o.next!
          payment.order.next!
          #starting update course or membership status
          order=payment.order
          update_membership(order)
          create_course_purchase(order)
          logger.debug " notify ended"
        end
        return render :text => 'success'
      end
      return render :text => 'error'
    end
    
    # Alipay status
    # 1、已收货情况
    # WAIT_SELLER_AGRE(等待卖家同意退款)
    # WAIT_BUYER_RETURN_GOOD(卖家同意退款，等待买家退货)
    # WAIT_SELLER_CONFIRM_GOODS(买家退货，等待卖家收到退货)
    # REFUND_SUCCESS(买家收到退货，退款成功，交易关闭)
    # 2、未收货情况
    # WAIT_SELLER_AGREE(等待卖家同意退款)
    # REFUND_SUCCESS(卖家同意退款，退款成功，交易关闭)
    # 3、卖家未发货而退款成功，交易状态会变为TRADE_CLOSED
    # 4、卖家发货而退款成功后，交易状态变为TRADE_FINISHED
    def notify_refund
      
    end

    def update_membership(order)
        if order.state=="complete" && order.line_items.first.variant_id==Spree::Variant.find_by(sku:'membership').id
          User.update_member_ship(order.user_id)
          #flash.notice = "membership was successfully!"
          #redirect_to user_user_center_path
        end
    end

    def create_course_purchase(order)
        if order.state=="complete" && order.products.first.is_uniclass && !order.products.first.course.nil?
          Purchase.create_purchase(order)
        end
    end

  end
end
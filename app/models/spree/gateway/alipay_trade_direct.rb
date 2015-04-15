require 'alipay'

module Spree
  class Gateway::AlipayTradeDirect < Gateway

    preference :pid, :string
    preference :key, :string
    preference :seller_email, :string

    def supports?(source)
      true
    end

    def provider_class
      ::Alipay::Service
    end

    def provider
      setup_alipay
      ::Alipay::Service
    end

    def auto_capture?
      true
    end

    def source_required?
      false
    end

    def method_type
      'alipay_trade_direct'
    end


    def purchase(money, source, gateway_options)
      nil
    end

    def set_partner_trade(out_trade_no, order, return_url, notify_url, gateway_options={})
      alipay_key= preferred_key
      time = Time.now.strftime('%Y%m%d%H%M%S%L')
      #https://mapi.alipay.com/gateway.do?service=trade_create_by_buyer&_input_charset=utf-8&partner=2088002627298374&seller_email=areq22%40aliyun.com&payment_type=1&out_trade_no=aquarius20141210165948670&subject=Iphone+6&logistics_type=DIRECT&logistics_fee=0&logistics_payment=SELLER_PAY&price=0.01&quantity=1&discount=0.00&return_url=http%3A%2F%2Flocalhost%3A3000%2Freturn&notify_url=http%3A%2F%2Flocalhost%3A3000%2Fnotify&sign_type=MD5&sign=b74cdf8eea44cfe174c95a2e27c70a5a
      url="https://mapi.alipay.com/gateway.do"
      subject = gateway_options[:subject] || order.number

      options={
          :service=>"trade_create_by_buyer",
          :_input_charset=>"utf-8",
          :partner=>preferred_pid,
          :seller_email=>preferred_seller_email,
          :payment_type=>1,
          :out_trade_no=>out_trade_no,
          :subject=>subject,
          :logistics_type=>"EXPRESS",
          :logistics_fee=>0,
          :logistics_payment=>"BUYER_PAY",
          :price=>order.amount,
          :quantity=>1,
          :discount=>0.00,
          :return_url=>return_url,
          :notify_url=>notify_url
      }

      sign=""
      paymentlink=url<<"?"
      options.each do |key,value|
        paymentlink<<"#{key}=#{value}&"
      end
      md5sign=_sign(options,alipay_key)
      paymentlink<<"sign_type=MD5&sign=#{md5sign}"
      return paymentlink

    end

    private
    def _sign(options,alipay_key)

      sign_str=""
      options.sort.map do |key,value|
        if value
          sign_str<<"#{key}=#{value}&"
        end
      end
      sign_str=sign_str[0, sign_str.length - 1]

      sign_str<<"#{alipay_key}"
      sign_str=Digest::MD5.hexdigest(sign_str)
    end

  end
end

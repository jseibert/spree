# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class ShippingExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/shipping"

  define_routes do |map|
    map.namespace :admin do |admin|
      admin.resources :shipping_methods
    end  
    map.resources :shipments
    map.resources :orders, :has_many => :shipments
  end
  
  def activate
    Order.class_eval do
      has_many :shipments, :dependent => :destroy
      include Spree::ShippingCalculator
      # modify the transitions in core - go to shipping after address (instead of cc payment)
      Order.state_machines['state'].events['next'].transitions.delete_if { |t| t.options[:to] == "creditcard_payment" && t.options[:from] == "address" }
      Order.state_machines['state'].events['next'].transition(:to => 'shipment', :from => 'address')
      Order.state_machines['state'].events['next'].transition(:to => 'creditcard_payment', :from => 'shipment')
    end    
    AddressesController.class_eval do
      # limit the countries to the ones that are possible to ship to
      def load_countries
        return @countries = Country.all unless parent_model == Order
        @countries = @order.shipping_countries
        @countries = [Country.find(Spree::Config[:default_country_id])] if @countries.empty?
      end
    end
  end
  
  def deactivate
    # admin.tabs.remove "Shipping"
  end
  
end
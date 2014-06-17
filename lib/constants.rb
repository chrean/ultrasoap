require 'singleton'

module UltraSOAP
  class Constants
    include Singleton
    
    attr_accessor :lb_pool_modes

    def initialize()
      @lb_pool_modes = { 
        "force_active_test"   => "ForceActive-Test",
        "force_active_notest" => "ForceActive-NoTest",
        "force_fail_test"     => "ForceFail-Test",
        "force_fail_notest"   => "ForceFail-NoTest",
        "normal"              => "Normal"
      }
    end
  end
end

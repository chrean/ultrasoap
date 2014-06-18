require 'settingslogic'

module UltraSOAP
  class Settings < Settingslogic
    source "#{ENV['HOME']}/.ultrasoap"
  end
end

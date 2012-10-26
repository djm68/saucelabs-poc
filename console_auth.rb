#!/usr/bin/env ruby

require 'yaml'
require 'rubygems'
require 'selenium-webdriver'

exit 1 unless sauce_url = ENV['SAUCE_URL']
passwd = ENV['PASSWD'] || passwd = '~!@$%^*-/aZ'
domain = ENV['DOMAIN'] || domain = ''
config = ENV['CONFIG']
dashboard=''
fail_flag=0
hInfo = YAML.load_file "config/#{config}"

hInfo['HOSTS'].each_pair { |host,val|
  puts "Host: #{host}"
  puts val.inspect
  if hInfo['HOSTS']["#{host}"]['roles'].include? "dashboard"
    puts "#{host} is a Dashboard" 
    dashboard = host
  end
}

caps = Selenium::WebDriver::Remote::Capabilities.send ENV['BROWSER']
caps.version =  ENV['VERSION']
caps.platform = ENV['PLATFORM'].to_sym
caps[:name] = "#{config} Console Login Test"

driver = Selenium::WebDriver.for(
  :remote,
  :url => sauce_url,
  :desired_capabilities => caps)

if ENV['APP_PATH']
  driver.navigate.to "https://#{dashboard}#{domain}/#{ENV['APP_PATH']}"
else
  driver.navigate.to "https://#{dashboard}#{domain}"
end

# Login
element = driver.find_element(:name, 'username')
element.send_keys "admin@example.com"
element.submit
element = driver.find_element(:name, 'password')
element.send_keys "#{passwd}"
element.submit

if driver.title == "Puppet Node Manager"
  puts "Testcase 1 passed"
else
  puts "Testcase 1 failed"
  fail_flag=1
end

puts driver.title
driver.quit

exit fail_flag

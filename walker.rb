require 'selenium-webdriver'

class Walker
  def driver
    @driver ||= Selenium::WebDriver.for :firefox

    @driver
  end

  def halt
    driver.quit
  end

  def navigate_to_homepage
    driver.navigate.to "http://www.yandex.ru/"
    driver.find_element(:id, 'tab-market').click
    driver.find_element(:xpath, "//*[contains(text(), 'Спорт и отдых')]").click
  end
end

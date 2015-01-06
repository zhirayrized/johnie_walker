require './guru_walker'
require 'progress_bar'

class ProductsWalker < Walker
  attr_reader :product_urls

  def initialize
    @product_urls = []
    total_gurus = 16 # Total number of gurus
    current_guru = 0 # Used only for progress definition

    guru_walker = GuruWalker.new
    guru_walker.walk do |guru|
      current_guru += 1 # Used only for progress definition

      guru.find_element(:xpath, "//a[contains(text(), 'Посмотреть все модели')]").click
      guru.find_element(:xpath, "//a[contains(text(), 'новизне')]").click

      puts "Collecting product urls (category #{current_guru} of #{total_gurus})"

      total_count = guru.find_element(:xpath, "//p[not(@*)]").text.scan(/\d+/).first.to_i

      bar = ProgressBar.new(total_count)

      # First page
      @product_urls.concat(guru.find_elements(:class, 'b-offers__name').map { |el| el.attribute('href') })
      bar.increment! 10

      # Other pages
      while (guru.find_elements(:xpath, "//a[contains(text(), 'следующая')]").size() > 0) && (next_page = guru.find_element(:xpath, "//a[contains(text(), 'следующая')]"))
        guru.navigate.to next_page.attribute('href')
        @product_urls.concat(guru.find_elements(:class, 'b-offers__name').map { |el| el.attribute('href') })
        bar.increment! 10
      end
    end

    guru_walker.halt
  end

  def walk
    puts 'Collecting products'

    bar = ProgressBar.new(@product_urls.size)
    @product_urls.each do |url|
      driver.navigate.to url
      ProductsWalker.save(driver, 'product')
      driver.find_element(:xpath, "//a[contains(text(), 'все характеристики')]").click
      ProductsWalker.save(driver, 'specs')
      bar.increment!
    end
  end

  def self.save(page, scope = 'product')
    f = File.open("tmp/#{page.current_url.scan(/\d+/).first}-#{scope}.html", 'w+')
    f.write(page.page_source)
    f.close
  end
end

walker = ProductsWalker.new
walker.walk
walker.halt

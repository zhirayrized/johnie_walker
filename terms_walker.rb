require './guru_walker'
require 'csv'

class TermsWalker
  attr_reader :terms

  def initialize
    @terms = []

    guru_walker = GuruWalker.new
    guru_walker.walk do |guru|
      guru.find_element(:xpath, "//a[@class='catalogmodels-side__title']").click

      # get category
      category = nil
      guru.find_elements(:xpath, "//li[@class='breadcrumbs2__item']").each do |bc|
        category = bc.find_element(:xpath, ".//span[@itemprop='title']").text.strip
      end

      # get items
      guru.find_elements(:xpath, "//dl[@class='b-faq-entry']").each do |term_el|
        term = {}
        term[:name] = term_el.find_element(:xpath, ".//dt[@class='b-faq-entry__term']").text.strip
        term[:description] = term_el.find_element(:xpath, ".//dd[@class='b-faq-entry__description']").text.strip
        term[:category] = category
        @terms << term
      end
    end

    guru_walker.halt
  end

  def walk
    terms.each do |term|
      yield term
    end
  end
end

walker = TermsWalker.new
CSV.open("./properties.csv", "wb") do |csv|
  walker.walk do |term|
    csv << [term[:name], term[:description], term[:category]]
  end
end

require './walker'

class GuruWalker < Walker
  def walk
    each_gurus do |guru|
      yield guru
    end
  end

  protected
    def get_guru_urls_from_page(page)
      page.find_elements(:class, 'guru').map do |b|
        b.find_element(:tag_name, 'a').attribute('href')
      end
    end

    def recursive_each_guru_from_url(url = nil)
      driver.navigate.to url
      if (urls = get_guru_urls_from_page(driver)).any?
        urls.each do |nu|
          recursive_each_guru_from_url(nu) do |nu_dr|
            yield nu_dr
          end
        end
      else
        yield driver
      end
    end

    def each_gurus
      navigate_to_homepage
      recursive_each_guru_from_url(driver.current_url) do |guru|
        yield guru
      end
    end
end

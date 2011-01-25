class Shoes
  def self.show_manual lang
    $lang = lang
    load File.join(DIR, 'shoes/help.rb')
  end
end

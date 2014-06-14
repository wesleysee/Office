class Holiday < ActiveRecord::Base

  def type
    self.multiplier == 1 ? "Regular" : "Special Non-Working"
  end

  def self.search(search)
    if search
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

end

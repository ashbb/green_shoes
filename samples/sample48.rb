# Original code was written by Cecil Coupe
# He shared that in Shoes ML: http://librelist.com/browser//shoes/2011/2/17/radio-checked-method-broken/#1197b650c7dfdae2bc7c76bd9dad7e0e

require 'green_shoes'

Shoes.app width: 300, height: 300 do
  background gold..deeppink, angle: 45
  @opt = 'none'
  r1 = radio :grp do
    @opt = "First"
  end
  para "Radio 1", width: 70
  r2 = radio :grp do
    @opt = "Second"
  end
  para "Radio 2", width: 70
  r3 = radio :grp do
    @opt = "Third"   
  end
  para "Radio 3", width: 70

  stack do
    para "Default is #{@opt}"
    # Set default for Radio Group :grp
    r3.checked = true
    button "Do My Bidding" do
      @p.text += "Aye, Aye. Using #{@opt}\n"
    end
    para "Choices follow\n"
    @p = para
  end
end

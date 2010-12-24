# Hackety Hack with Green Shoes
require '../lib/green_shoes'
require './tabs_proc'

Shoes.app width: 480 do
  extend HH::TabsProc

  nostroke
  tabs = %w[home new try tour help cheat hand properties quit]
  mk_tabs_proc tabs
  tips = []
  
  tabs.each_with_index do |tab, i|
    y = i < 7 ? 8+30*i : 220+30*i
    tips << [rect( 38, y-4, 100, 26, fill: '#F7A', curve: 6).hide, 
                rect( 38, y-4, 10, 26, fill: '#F7A').hide, 
                para(fg(strong(tab.to_s.capitalize), forestgreen), left: 44, top: y-2).hide]
  end
  
  background './static/hhabout.png'
  background "#cdc", width: 38
  background "#dfa", width: 36
  background "#fda", width: 30
  background "#daf", width: 24
  background "#aaf", width: 18
  background "#7aa", width: 12
  background "#77a", width: 6

  tabs.each_with_index do |tab, i|
    x = 8
    y = i < 7 ? 8+30*i : 220+30*i
    bg = rect( x-4, y-4, 30, 26, fill: '#DFA', curve: 6).hide
    img = image("./static/tab-#{tab}.png").move(x, y)
    img.hover{bg.show; tips[i].each &:show}
    img.leave{bg.hide; tips[i].each &:hide}
    img.click{send "#{tab}_proc"}
  end
  
end

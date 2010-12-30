class Shoes
  class App
    def projector file
      projector = Projector.new
      projector.controller = SwingController.new
      projector.controller.content = TextureMappingData.new
      projector.controller.content.face_list = AkatsukiFace::create
      projector.controller.content.texture = Gdk::Pixbuf.new(file)
  
      def (projector.controller.content.texture).source_set(context)
        context.set_source_pixbuf(self)
      end
  
      @canvas.tap do |drawing_area|
        drawing_area.signal_connect('expose-event') do |widget, event|
          projector.controller.region(widget.allocation)
          projector.update
          projector.draw
          true
        end
        drawing_area.add_events(Gdk::Event::BUTTON_PRESS_MASK)
        drawing_area.signal_connect('button_press_event') do |widget, event|
          projector.controller.press(event)
          true
        end
        drawing_area.add_events(Gdk::Event::POINTER_MOTION_MASK)
        drawing_area.signal_connect('motion_notify_event') do |widget, event|
          projector.controller.motion(event)
          true
        end
        drawing_area.add_events(Gdk::Event::BUTTON_RELEASE_MASK)
        drawing_area.signal_connect('button_release_event') do |widget, event|
          projector.controller.release(event)
          true
        end
      end

      projector.widget = @canvas
      animate{projector.draw}
    end
  end
end

#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-
# Author:: MIZUTANI Tociyuki <tociyuki@gmail.com>
# Copyright: Copyright 2010 by MIZUTANI Tociyuki
# License:: GNU General Public License Version 2
#
#     wget -O akatsukiface.png http://img.f.hatena.ne.jp/images/fotolife/t/tociyuki/20101219/20101219152034_original.png
#     ruby akatsuki-papermodel.rb

#require 'gtk2'
require_relative 'matrix3d'
require 'observer'

module AkatsukiFace
  # JAXA PLANET-C Akatsuki paper craft
  #   http://www.jaxa.jp/countdown/f17/special/craft_j.html

  #IMG_SOURCE = 'akatsukiface.png'

  # body size: 1040mm 1450mm 1400mm
  SCALE = Vector[1040.0/1450.0, 1.0, 1400.0/1450.0, 1.0]
  FACES = [
    {
      'label' => 'loof',
      'angle' => -90.0, 'axis' => Vector[1.0, 0.0, 0.0, 1.0],
      'texture' => [0.00, 0.00, 0.25, 0.50], # left, top, width, height
    },
    {
      'label' => 'front',
      'angle' => 0.0, 'axis' => Vector[0.0, 1.0, 0.0, 1.0],
      'texture' => [0.00, 0.50, 0.25, 0.50],
    },
    {
      'label' => 'floor',
      'angle' => +90.0, 'axis' => Vector[1.0, 0.0, 0.0, 1.0],
      'texture' => [0.25, 0.00, 0.25, 0.50],
    },
    {
      'label' => 'right',
      'angle' => +90.0, 'axis' => Vector[0.0, 1.0, 0.0, 1.0],
      'texture' => [0.25, 0.50, 0.25, 0.50],
    },
    {
      'label' => 'back',
      'angle' => +180.0, 'axis' => Vector[0.0, 1.0, 0.0, 1.0],
      'texture' => [0.50, 0.50, 0.25, 0.50],
    },
    {
      'label' => 'left',
      'angle' => +270.0, 'axis' => Vector[0.0, 1.0, 0.0, 1.0],
      'texture' => [0.75, 0.50, 0.25, 0.50],
    },
  ]

  # divide MESH x MESH rectangles per a FACE
  MESH = 2

  # the modeling unit: right-hand 3d object coordinates
  VERTEXS = [
    Vector[0.0, 0.0, +1.0, 1.0], # left bottom
    Vector[1.0, 0.0, +1.0, 1.0], # right bottom
    Vector[1.0, 1.0, +1.0, 1.0], # right top
    Vector[0.0, 1.0, +1.0, 1.0], # left top
  ]
  # the texture unit: left-hand 2d Gtk::DrawingArea coordinates
  TEXTURES = [
    Vector[0.0, 1.0], # left bottom
    Vector[1.0, 1.0], # right bottom
    Vector[1.0, 0.0], # right top
    Vector[0.0, 0.0], # left top
  ]

  def create
    scale = Matrix3d::scale(SCALE)
    divide = MESH.to_f
    FACES.inject([]) do |list, face|
      transform = scale * Matrix3d::rotate(face['angle'], face['axis'])
      (0 ... MESH).to_a.product((0 ... MESH).to_a).each do |part|
        x, y = part.map{|i| i.to_f }
        v = VERTEXS.map {|c|
          transform * Vector[
            (c[0] + x) * 2.0 / divide - 1.0,
            (c[1] + divide - 1.0 - y) * 2.0 / divide - 1.0,
            c[2],
            c[3]
          ]
        }
        t = TEXTURES.map {|c|
          left, top, width, height = face['texture']
          Vector[
            (c[0] + x) * width / divide + left,
            (c[1] + y) * height / divide + top
          ]
        }

        # to keep simple calculations on S^{-1},
        # we assume s1 - s0 = (s00, 0.0), s2 - s0 = (0.0, s11)
        # left-bottom triangle counterclockwise
        #   (left, bottom) -> (right, bottom) -> (left, top)
        list.push({
          'vertex' => [0, 1, 3].map {|i| v[i] },
          'texture' => [0, 1, 3].map {|i| t[i] },
        })
        # right-top triangle counterclockwise
        #   (right, top) -> (left, top) -> (right, bottom)
        list.push({
          'vertex' => [2, 3, 1].map {|i| v[i] },
          'texture' => [2, 3, 1].map {|i| t[i] },
        })
      end
      list
    end
  end
  module_function :create
end

class TextureMappingData
  include Observable

  SCALE_A = 50.0

  attr_reader :texture, :transform, :face_list
  def texture=(x)   @texture =   x; update; x end
  def transform=(x) @transform = x; update; x end
  def face_list=(x) @face_list = x; update; x end

  def initialize
    @texture = nil
    @transform = Matrix3d::identity
    @transform *= Matrix3d::rotate(+20.0, Vector[1.0, 0.0, 0.0, 1.0])
    @transform *= Matrix3d::rotate(+30.0, Vector[0.0, 1.0, 0.0, 1.0])
    @transform *= Matrix3d::rotate(+90.0, Vector[0.0, 0.0, 1.0, 1.0])
    @face_list = []
    @transform_begin = nil
  end

  def update
    changed
    notify_observers
    self
  end

  def begin_work
    @transform_begin = @transform
    self
  end

  def swing_step(dx, dy)
    a = Math::sqrt(dx * dx + dy * dy) * SCALE_A
    a > a * Float::EPSILON or return self
    self.transform = Matrix3d::rotate(a, Vector[dy, dx, 0.0, 1.0]) * @transform_begin
    self
  end

  def commit
    @transform_begin = nil
    self
  end
end

class Projector
  include Observable

  attr_accessor :widget
  attr_reader :controller

  def controller=(c)
    @controller = c
    @controller.add_observer(self)
    c
  end

  def initialize
    @widget = nil
    @invalid_drawing = true
  end

  def update
    @invalid_drawing = true
    self
  end

  def draw
    @invalid_drawing or return self
    drawing_area_context = @widget.window.create_cairo_context
    port = @widget.allocation
    fb = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, port.width, port.height)
    fb_context = Cairo::Context.new(fb)
    scene(fb_context, port)
    drawing_area_context.set_source(fb)
    drawing_area_context.paint
    @invalid_drawing = false
    self
  end

private

  def scene(context, port)
    context.set_source_rgb(0, 0, 0)
    context.paint
    w = port.width.to_f / 2
    h = port.height.to_f / 2
    projection = Matrix3d::perspective(50.0, w/h, 1.0, 100.0)
    projection *= Matrix3d::translate(Vector[0.0, 0.0, -5.0, 1.0])
    projection *= controller.content.transform
    texture = controller.content.texture
    controller.content.face_list.each do |face|
      vertex_list = face['vertex'].map{|r|
        v = projection * r
        Vector[w + v[0]/v[3] * w, h - v[1]/v[3] * h] # widget canvas coordinate
      }
      vertex10 = vertex_list[1] - vertex_list[0]
      vertex20 = vertex_list[2] - vertex_list[0]
      next if vertex10[0] * vertex20[1] - vertex10[1] * vertex20[0] > 0
      fill_triangle(context, texture, vertex_list, face['texture'])
    end
    self
  end

  # left-hand Gtk::DrawingArea coordinates
  def fill_triangle(context, texture, dst, src_uv)
    scale_x, scale_y = texture.width.to_f, texture.height.to_f
    src = src_uv.map {|v| Vector[scale_x * v[0], scale_y * v[1]] }
    # r_d = D S^-1 (r_s - r_s0) + r_d0
    # we assume S is a daigonal matrix.
    s00 = src[1][0] - src[0][0]
    s11 = src[2][1] - src[0][1]
    d0 = dst[1] - dst[0]
    d1 = dst[2] - dst[0]
    ds = Matrix[[d0[0]/s00, d1[0]/s11], [d0[1]/s00, d1[1]/s11]]
    ds0 = dst[0] - ds * src[0]
    context.save do
      context.set_antialias(Cairo::ANTIALIAS_NONE)
      context.transform(Cairo::Matrix.new(ds[0, 0], ds[1, 0], ds[0, 1], ds[1, 1], ds0[0], ds0[1]))
      texture.source_set(context)
      context.move_to(src[0][0], src[0][1])
      context.line_to(src[1][0], src[1][1])
      context.line_to(src[2][0], src[2][1])
      context.line_to(src[0][0], src[0][1])
      context.fill
    end
    self
  end
end

class SwingController
  include Observable

  attr_reader :content

  def initialize
    @content = nil
    @drag = false
    @ratio_x = 0.01
    @ratio_y = 0.01
    @start_x = 0
    @start_y = 0
  end

  def content=(x)
    @content = x
    @content.add_observer(self)
    x
  end

  def update
    changed
    notify_observers
    self
  end

  def region(allocation)
    @ratio_x = 1.0 / allocation.width.to_f
    @ratio_y = 1.0 / allocation.height.to_f
    self
  end

  def press(event)
    @drag = true
    @start_x, @start_y = event.x, event.y
    content.begin_work
    self
  end

  def motion(event)
    @drag or return self
    swing_to(event.x, event.y)
    self
  end

  def release(event)
    swing_to(event.x, event.y)
    content.commit
    @drag = false
    self
  end

private

  def swing_to(x, y)
    dx = (x - @start_x).to_f * @ratio_x
    dy = (y - @start_y).to_f * @ratio_y
    content.swing_step(dx, dy)
    self
  end
end

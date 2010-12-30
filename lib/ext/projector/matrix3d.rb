# Author:: MIZUTANI Tociyuki <tociyuki@gmail.com>
# Copyright: Copyright 2010 by MIZUTANI Tociyuki
# License:: GNU General Public License Version 2

require 'matrix'

module Matrix3d
  def identity() Matrix.identity(4) end

  def frustum(left, right, bottom, top, znear, zfar)
    x = 2.0 * znear / (right - left)
    y = 2.0 * znear / (top - bottom)
    a = (right + left) / (right - left)
    b = (top + bottom) / (top - bottom)
    c = -(zfar + znear) / (zfar - znear)
    d = -2.0 * zfar * znear / (zfar - znear)
    Matrix[
        [x,   0.0, a,    0.0],
        [0.0, y,   b,    0.0],
        [0.0, 0.0, c,    d],
        [0.0, 0.0, -1.0, 0.0]
    ]
  end

  def perspective(fov, aspect, znear, zfar)
    yhi = znear * Math.tan(fov * Math::PI / 360.0)
    ylo = -yhi
    xlo = ylo * aspect
    xhi = yhi * aspect
    frustum(xlo, xhi, ylo, yhi, znear, zfar)
  end

  def translate(v)
    v.size >= 3 or raise 'vector size >= 3.'
    Matrix[
      [1.0, 0.0, 0.0, v[0]],
      [0.0, 1.0, 0.0, v[1]],
      [0.0, 0.0, 1.0, v[2]],
      [0.0, 0.0, 0.0, 1.0]
    ]
  end

  def scale(v)
    v.size >= 3 or raise 'vector size >= 3.'
    Matrix[
      [v[0], 0.0, 0.0, 0.0],
      [0.0, v[1], 0.0, 0.0],
      [0.0, 0.0, v[2], 0.0],
      [0.0, 0.0, 0.0, 1.0]
    ]
  end

  def rotate(theta, axis)
    axis.size >= 3 or raise 'axis vector size >= 3.'
    theta = Math::PI / 180.0 * theta
    axis = Vector[axis[0], axis[1], axis[2]]
    axis_r = axis.r
    axis_r > axis_r * Float::EPSILON or raise 'r must not be zero vector.'
    x = axis[0] / axis_r
    y = axis[1] / axis_r
    z = axis[2] / axis_r
    s = Math.sin(theta)
    c = Math.cos(theta)
    cc = 1.0 - c
    Matrix[
      [cc * x * x + c,     cc * y * x - s * z, cc * z * x + s * y, 0.0],
      [cc * x * y + s * z, cc * y * y + c,     cc * z * y - s * x, 0.0],
      [cc * x * z - s * y, cc * y * z + s * x, cc * z * z + c,     0.0],
      [0.0, 0.0, 0.0, 1.0]
    ]
  end
  module_function :identity, :frustum, :perspective, :translate, :scale, :rotate
end

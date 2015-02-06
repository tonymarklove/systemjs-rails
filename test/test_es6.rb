require 'minitest/autorun'
require 'sprockets'
require 'sprockets/es6'

class TestES6 < MiniTest::Test
  def setup
    @env = Sprockets::Environment.new
    @env.append_path File.expand_path("../fixtures", __FILE__)
  end

#   def test_transform_arrow_function
#     assert asset = @env["math.js"]
#     assert_equal 'application/javascript', asset.content_type
#     assert_equal <<-JS.chomp, asset.to_s
# System.register("app/math", [], function (_export) {
#   "use strict";

#   var square;
#   return {
#     setters: [],
#     execute: function () {
#       square = function (n) {
#         return n * n;
#       };
#     }
#   };
# });
#     JS
#   end

#   def test_locate
#     # assert_equal 'yo', Sprockets::ES6.locate('test1')
#   end

  def test_dependencies
    assert asset = @env["test/dependencies.js"]
  end
end

require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @product = Product.new(name: "Test Product")
  end

  test "should be valid with valid attributes" do
    assert @product.valid?
  end

  test "should not be valid without name" do
    @product.name = nil
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  test "should save successfully with valid attributes" do
    assert_difference("Product.count") do
      @product.save
    end
  end

  test "should not save without name" do
    @product.name = nil
    assert_no_difference("Product.count") do
      @product.save
    end
  end

  test "should have timestamps after creation" do
    @product.save
    assert_not_nil @product.created_at
    assert_not_nil @product.updated_at
  end
end

require "test_helper"

class ProductCreationJobTest < ActiveJob::TestCase
  test "should create product with valid params" do
    params = { name: "Test Product" }

    assert_difference -> { Product.count } do
      ProductCreationJob.perform_now(params)
    end

    product = Product.last
    assert_equal "Test Product", product.name
  end

  test "should enqueue job" do
    params = { name: "Test Product" }

    assert_enqueued_with(job: ProductCreationJob) do
      ProductCreationJob.perform_later(params)
    end
  end

  test "should fail with invalid params" do
    params = { name: nil }

    assert_no_difference -> { Product.count } do
      assert_raises(ActiveRecord::RecordInvalid) do
        ProductCreationJob.perform_now(params)
      end
    end
  end

  test "should be in default queue" do
    assert_equal "default", ProductCreationJob.new.queue_name
  end
end

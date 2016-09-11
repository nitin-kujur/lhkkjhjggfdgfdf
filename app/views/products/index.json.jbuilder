json.array!(@products) do |product|
  json.extract! product, :id, :shopify_product_id, :min_quantity, :shop
  json.url product_url(product, format: :json)
end

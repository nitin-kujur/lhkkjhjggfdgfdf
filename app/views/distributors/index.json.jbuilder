json.array!(@distributors) do |distributor|
  json.extract! distributor, :id, :first_name, :last_name, :email, :verified_email
  json.url distributor_url(distributor, format: :json)
end

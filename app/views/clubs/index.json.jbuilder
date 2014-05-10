json.array!(@clubs) do |club|
  json.extract! club, :id, :name, :description, :website, :uni_registration_id, :is_confirmed
  json.url club_url(club, format: :json)
end

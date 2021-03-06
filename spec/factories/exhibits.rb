FactoryGirl.define do
  factory :exhibit, class: Spotlight::Exhibit do
    sequence(:title) { |n| "Exhibit Title #{n}" }
    after(:build) { |exhibit| exhibit.searches << FactoryGirl.build(:default_search) }
  end
end
  


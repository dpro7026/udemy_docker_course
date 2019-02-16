FactoryBot.define do
  factory :event do
    name { 'Jane\'s Public Event' }
    description { 'Jane is hosting a super fun event' }
    price { 0.00 }
    location { 'Jane\'s house' }
    date { 10.days.from_now }
    private_event { false }
    user { nil }
  end
  
  factory :another_event, class: Event do
    name { 'Tom\'s Public Event' }
    description { 'Tom is hosting a a party!' }
    price { 10.00 }
    location { 'Tom\'s house' }
    date { 10.days.from_now }
    private_event { false }
    user { nil }
  end
end
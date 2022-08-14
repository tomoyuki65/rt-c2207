FactoryBot.define do
  factory :user do
    name { "Example User" }
    email { "user@example.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    admin { true }
    activated { true }
    activated_at { Time.zone.now }
  end

  factory :other_user, class: User do
    name { "Example User2" }
    email { "user2@example.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    activated { true }
    activated_at { Time.zone.now }
  end

  factory :third_user, class: User do
    name { "Example User3" }
    email { "user3@example.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    activated { true }
    activated_at { Time.zone.now }
  end

  factory :unactivated_user, class: User do
    name { "Example User3" }
    email { "user3@example.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
  end
end

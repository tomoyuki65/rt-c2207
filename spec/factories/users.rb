FactoryBot.define do
  factory :user do
    name { "Example User" }
    email { "user@example.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
    admin { true }
  end

  factory :other_user, class: User do
    name { "Example User2" }
    email { "user2@example.com" }
    password { "foobar" }
    password_confirmation { "foobar" }
  end
end

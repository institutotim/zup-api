namespace :group_permissions do
  task add_chat_permissions_default: :environment do
    GroupPermission.update_all(manage_chat_rooms: false, chat_rooms_read: [])
  end
end

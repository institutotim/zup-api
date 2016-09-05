class AddEmailConstraintUser < ActiveRecord::Migration
  def change
    # First, let get all users with duplicated emails and change them
    puts 'Searching users with duplicated email'
    duplicated_emails = User.select('email').group('email').having('COUNT(email) > 1').count

    duplicated_emails.each do |email, dups_count|
      (dups_count - 1).times do |i|
        User.find_by(email: email)
            .update(email: "dup-#{i}-#{email}")
      end
    end

    add_index :users, :email, unique: true
  end
end

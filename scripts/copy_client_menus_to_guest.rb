source_user = User.find_by!(email: 'lemonandbasil.co@gmail.com')
guest_user  = User.find_by!(email: 'guest@lemonandbasil.co')

menus = source_user.client_menus

puts "Copying #{menus.count} menus from #{source_user.email} to #{guest_user.email}..."

menus.each do |menu|
  new_menu = menu.duplicate!(user_id: guest_user.id, client_id: nil)
  puts "  Copied: '#{menu.title}' (id=#{menu.id}) → new id=#{new_menu.id}, slug=#{new_menu.slug}"
end

puts "Done."

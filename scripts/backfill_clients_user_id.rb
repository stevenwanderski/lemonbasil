user = User.find_by(email: 'lemonandbasil.co@gmail.com')

ap Client.update_all(user_id: user.id)
ap ClientMenu.update_all(user_id: user.id)
ap Meal.update_all(user_id: user.id)
Page.find_or_create_by(slug: 'meal-prep') do |page|
  page.body = <<-HTML
    <h1>Simplified. Customized. Food.</h1>
    <p>What I do: Learn about your needs, menu plan, grocery shop, cook all meals in your kitchen, label and store food, deep clean, then leave you to enjoy!</p>
    <p>What you do: Decide on a weekly or monthly cook date & choose your menu items.</p>
    <p>Extras: We can talk about adding breakfast jars, healthy snacks & kid’s lunches to help you stay on track as much as possible throughout your busy week.</p>
    <p>My goal is to work together with you to help alleviate the stresses that planning and prepping and cooking can bring. Every family is different, so together we’ll customize a plan to fit your needs.</p>
    <p>My costs, like my menus, are approachable. I charge a grocery shop deposit + my hourly rate so you always know exactly where every dollar goes. If you have a budget, let me know what it is and I will work with you to make it happen the best I can.</p>
  HTML
end

Page.find_or_create_by(slug: 'parties') do |page|
  page.body = <<-HTML
    <h1>In-home cooking parties</h1>
    <p>Gather a small group of friends or family in your home to hang out and socialize while learning a new culinary skill together! We will work on the recipes together and then you and your guests are free to enjoy the fruits of your labor while I clean up.</p>
    <p>All classes are customizable with a focus on seasonal ingredients. Some themes include; kitchen basics, holiday appetizers, hand-made pasta, sauces, pizza, kid’s snacks, grazing boards, sandwiches and more! I can happily pair wine or cocktails to compliment the menu. </p>
    <p>For a seated cooking/dinner party option, we’ll make the majority of a recipe together, then I’ll plate, serve, and clean up while you and your guests eat and enjoy your collaborated meal around the table.</p>
    <p>You’ll leave these parties with new ideas, fresh perspectives on food combinations, and beautiful presentation skills.</p>

    <h1>Meal prep parties</h1>
    <p>These parties are great way to socialize with some friends while splitting a week’s worth of meal prep between one another. I will help guide your group through customizing a week’s menu that works for everyone. I’ll grab the groceries, prepare stations, and walk everyone through their prep work. After a couple hours everyone will go home with 5 meals ready to heat after a busy day. You will have learned some new things and meal-prepped your whole week all while enjoying the company of friends/family.</p>

    <h1>Catered Events</h1>
    <p>All of my menu items can be transformed into fun little party bites or family style dishes for intimate dinner parties and events up to 50 people.</p>
  HTML
end

Page.find_or_create_by(slug: 'about') do |page|
  page.body = <<-HTML
    <h1>The Lemons & Basils <br>of it all</h1>
    <p>My culinary career started with classical Italian education and restaurant work in Northern Italy. Upon returning to the States I had the valuable experience of cooking for recovering patients with special dietary needs, which is when I began to think about food as medicine and learned how to utilize healing properties of certain ingredients. After that I worked in a Chicago scratch kitchen where we prepared gourmet ready-to-heat meals every day. I later spent some time in Northern California cooking in a kitchen dedicated to making healthy, organic foods a quick and convenient option. My most recent gig as the personal chef for a Chicago start-up allowed me to create a fun, fresh, and seasonal menu for 30+ people each day. I catered to vegetarian, GF, and paleo diets and never repeated a meal unless requested!</p>
    <p>My cooking style combines these various experiences with the intention of serving original, comforting, fresh, and beautiful dishes. In addition to my passion for food professionally it's also my number one hobby. Cooking for other people brings me so much joy!</p>
  HTML
end

# The Oct 19–23 reference edition of the lemon drop (lemon-drop/index.html),
# as a Published Issue. Development and test only: some of the reference
# photos are third-party crops and two don't match their dish.
#
# Text is copied from the reference as written, mistakes included (the
# harissa chicken lists no chicken). Running it again leaves an existing
# Issue alone.

return if LemonDrop::Issue.exists?(slug: '2026-10-19')

# Images go in as uploads, the way a form hands them over. A raw IO doesn't
# work: the upload check's spoofing protection reads it to the end, and
# Active Storage then raises ActiveStorage::IntegrityError.
lemon_drop_image = lambda do |name|
  tempfile = Tempfile.new(name, binmode: true)
  IO.copy_stream(Rails.root.join('lemon-drop/images', name).to_s, tempfile)
  tempfile.rewind
  ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: name, type: Marcel::MimeType.for(name: name))
end

recipes = [
  {
    title: 'chickpea stew', category: 'soup', image: 'chickpea-stew.jpg',
    menu_title: 'Chickpea Stew',
    menu_blurb: 'chickpeas, spinach, turmeric, garlic, ginger, chili flakes, coconut milk, crispy chickpeas, ' \
                'fresh whole cilantro sprigs + greek yogurt & pita',
    prep_minutes: 15, cook_minutes: 30, serves: 5,
    ingredients: {
      'Produce' => [
        '4 garlic cloves, thinly sliced',
        '1 inch fresh ginger, grated',
        '3 big handfuls fresh baby spinach',
        'handful fresh cilantro, whole sprigs',
        '1 lemon, juiced'
      ],
      'Pantry' => [
        'good olive oil',
        '2 cans chickpeas (15 oz each), drained and rinsed',
        '1 can full fat coconut milk (14 oz)',
        'turmeric',
        'smoked paprika',
        'chili flakes',
        's&p',
        'warm pita for serving'
      ],
      'Dairy' => ['greek yogurt for serving']
    },
    steps: [
      'Set aside about 1/2 c of the chickpeas for crisping. Heat a generous pour of olive oil in a large heavy pot ' \
      'or dutch oven over medium-high. Add the 1/2c reserved chickpeas and cook without stirring 3-4 mins until ' \
      'deeply golden and crispy on one side. Toss and cook 2 more mins. Remove and set aside. These are our garnish.',
      'In the same pot reduce heat to medium. Add more evoo, garlic & ginger, cook low and slow 2-3 mins until very ' \
      'soft and fragrant but NOT browned.',
      'Add turmeric, smoked paprika, and chili flakes directly to the oil & let bloom 30-60 seconds.',
      'Add remaining chickpeas and crush about a third of them against the side of the pot with a wooden spoon.',
      'Pour in coconut milk, stir everything together and bring to a simmer. Cook uncovered 15-20 mins until ' \
      'thickened and deeply flavored. Season with lemon juice and s&p, and stir in spinach until just wilted.',
      'Sprinkle with crispy chickpeas, whole cilantro sprigs, a generous dollop of greek yogurt, and warm pita alongside.'
    ],
    tip: 'When you want something warming and nourishing that comes together in under an hour, this is the stew. ' \
         'Please please be sure to consume your cilantro leaves whole!'
  },
  {
    title: 'brown butter gnocchi', slug: 'gnocchi', category: 'entree', image: 'gnocchi.jpg',
    menu_title: 'Brown Butter Gnocchi',
    menu_blurb: 'gnocchi, brown butter, roasted delicata squash, toasted walnuts, crispy sage, shaved parm',
    prep_minutes: 10, cook_minutes: 20, serves: 5,
    ingredients: {
      'Produce' => [
        '1 large delicata squash, halved, seeded, and sliced into half moons',
        'a large handful fresh sage leaves',
        '1 lemon, juiced and zested'
      ],
      'Pantry' => [
        'good olive oil',
        'walnuts, roughly chopped and toasted',
        's&p',
        '2 packages store bought gnocchi (16 oz each)'
      ],
      'Dairy' => [
        '6 tbsp kerrygold butter',
        'imported parmesan, shaved, for serving'
      ]
    },
    steps: [
      'Preheat oven to 425°f. Toss delicata squash with olive oil and s&p. No need to peel, the skin is completely ' \
      'edible and tender once roasted. Spread on a parchment-lined sheet and roast 20-25 mins until golden and ' \
      'caramelized at the edges.',
      'Make the brown butter. Melt kerrygold in a large skillet over medium heat, swirling occasionally, until golden ' \
      'and nutty, 3-4 mins. Add sage leaves and fry 1 min until crisp. Watch the butter closely after the sage goes ' \
      'in. It can go from brown to burnt quickly.',
      'Cook gnocchi per package directions. They’re done when they float to the surface, usually 2-3 mins.',
      'Drain & add gnocchi to the brown butter in a single layer and cook without stirring 2-3 mins until lightly ' \
      'golden and slightly crispy on one side. Toss gently.',
      'Add roasted delicata squash and toasted walnuts. Squeeze in lemon juice & zest. Toss everything together gently.',
      'Serve with shaved parm & an extra pinch of s&p.'
    ],
    tip: 'Delicata squash is this month’s produce moment. It’s sweet, nutty & roasts into something almost jammy at ' \
         'the edges. Unlike most winter squash you don’t need to peel it. The skin is thin and completely tender ' \
         'once roasted which means less prep, more flavor & fiber.'
  },
  {
    title: 'harissa chicken', category: 'entree', image: 'harissa-chicken.jpg',
    menu_title: 'One Pan Harissa Chicken',
    menu_blurb: 'chicken thighs, harissa, roasted carrots & chickpeas, lemon, fresh herbs, over couscous',
    prep_minutes: 15, time_note: '+ marinating', cook_minutes: 40, total_label: '1hr', serves: 5,
    ingredients: {
      'Produce' => [
        '4 large carrots, peeled and cut into chunks',
        '1 can chickpeas (15 oz), drained, rinsed, and completely dried',
        '4 garlic cloves, minced',
        '1 lemon, juiced and zested',
        'a large handful fresh flat-leaf parsley, chopped',
        'a small handful fresh mint, torn'
      ],
      'Pantry' => [
        'harissa paste',
        'good olive oil',
        'smoked paprika',
        'cumin',
        '2c better than bouillon chicken base',
        's&p'
      ]
    },
    steps: [
      'Whisk together harissa, olive oil, garlic, lemon zest, smoked paprika, cumin, and s&p. Coat chicken thighs all ' \
      'over and marinate at least 4 hours, overnight is better.',
      'Preheat oven to 425°f. Toss carrots and dried chickpeas with olive oil, smoked paprika, s&p. Spread on a large ' \
      'sheet pan or in a roasting dish & nestle marinated chicken thighs skin side up among the vegetables.',
      'Roast 35-40 mins until skin is deeply golden and caramelized and internal temperature reaches 165°f. The ' \
      'chickpeas will crisp and the carrots will caramelize in the chicken fat as it renders.',
      'Make couscous per package directions using bouillon instead of water.',
      'Serve chicken and roasted vegetables over couscous with fresh parsley, mint, and a squeeze of lemon.'
    ],
    tip: 'A well-seasoned bouillon broth produces couscous that tastes more complex & intentional'
  },
  {
    title: 'beef & shroom ragú', slug: 'ragu', category: 'entree', image: 'ragu.jpg',
    menu_title: 'Beef & Mushroom Ragu',
    menu_blurb: 'ground beef, mixed mushrooms, white beans, red wine, tomato paste, pappardelle, imported parm, basil',
    prep_minutes: 20, cook_minutes: 60, serves: 5,
    ingredients: {
      'Produce' => [
        '1 large yellow onion, finely diced',
        '4 garlic cloves, minced',
        '1# mixed mushrooms, roughly chopped (cremini, shiitake, oyster, whatever looks best)',
        'a very large handful fresh basil, divided',
        '1 lemon, zested'
      ],
      'Pantry' => [
        'good olive oil',
        '1/2 c dry red wine',
        'tomato paste',
        '1c better than bouillon beef base',
        '1 can white beans (15 oz), drained and rinsed',
        '1 lb pappardelle',
        's&p'
      ],
      'Dairy' => [
        'imported parm, freshly grated for serving',
        '2 tbsp kerrygold butter'
      ],
      'Meat' => ['2# ground beef']
    },
    steps: [
      'Heat olive oil in a large heavy pot over medium. Add onion and cook low and slow 8-10 mins until very soft and ' \
      'golden. Add garlic and cook 1 min more.',
      'Add mushrooms & cook over medium-high heat without stirring 4-5 mins until deeply golden and all their ' \
      'moisture has cooked off. This step is important! Mushrooms that are stirred too soon steam instead of ' \
      'caramelize and the flavor is completely different.',
      'Add ground beef and cook, breaking it up, until browned, 6-8 mins. Season generously with s&p.',
      'Add tomato paste and let it bloom 30-60 seconds. Pour in red wine and scrape up any fond from the bottom of ' \
      'the pot. Let reduce by half.',
      'Add bouillon broth, white beans, and lemon zest. Stir in a large handful of torn basil. Bring to a simmer then ' \
      'reduce heat to low and cook uncovered 30-35 mins until the sauce has thickened and deepened. Taste & adjust ' \
      'seasoning.',
      'Cook pappardelle in very well-salted water until al dente. Before draining scoop out 1 c pasta water. Toss ' \
      'pasta with ragu and a knob of butter, adding pasta water as needed until silky and well coated.',
      'Serve with remaining fresh basil and a generous shower of imported parm.'
    ],
    tip: 'Mushrooms need high heat & patience. Add them to a hot pan and leave them alone for several minutes before ' \
         'stirring. They release a significant amount of moisture as they cook and that moisture needs to evaporate ' \
         'completely before any browning can happen. Once the pan is dry and the mushrooms are golden they develop a ' \
         'deep, almost meaty flavor that makes this ragu taste significantly more complex than a standard beef sauce.'
  },
  {
    title: 'stuffed acorn squash', slug: 'acorn-squash', category: 'entree', image: 'acorn-squash.jpg',
    menu_title: 'Stuffed Acorn Squash',
    menu_blurb: 'roasted acorn squash stuffed with ground italian sausage, wild rice, dried cranberry, toasted ' \
                'pepitas, fresh herbs, maple-balsamic drizzle',
    prep_minutes: 20, cook_minutes: 50, serves: 5,
    ingredients: {
      'Produce' => [
        '3 medium acorn squash, halved and seeded',
        '1 small yellow onion, finely diced',
        '3 garlic cloves, minced',
        'a small handful fresh flat-leaf parsley, chopped',
        'a small handful fresh thyme, leaves stripped',
        '1 lemon, juiced'
      ],
      'Pantry' => [
        'good olive oil',
        '1 c wild rice, cooked per package directions',
        '1/3 c dried cranberries',
        '1/3 c pepitas, toasted',
        'balsamic vinegar',
        'maple syrup',
        's&p'
      ],
      'Meat' => ['1# ground italian sausage']
    },
    steps: [
      'Preheat oven to 400°f. Brush acorn squash halves with olive oil and season with s&p. Place cut side down on a ' \
      'parchment-lined sheet and roast 30-35 mins until completely tender and caramelized on the cut side.',
      'While squash roasts cook wild rice per package directions. In a separate pan cook italian sausage over ' \
      'medium-high, breaking it up, until browned and cooked through, 6-8 mins. Add onion and garlic to the sausage ' \
      'and cook 3-4 mins until soft.',
      'Combine cooked wild rice, sausage mixture, dried cranberries, toasted pepitas, fresh thyme, parsley, and a ' \
      'squeeze of lemon. Season with s&p and toss to combine.',
      'Flip roasted squash halves cut side up. Fill each generously with the rice and sausage mixture, mounding it ' \
      'slightly over the top.',
      'Make the maple balsamic drizzle. Whisk together equal parts maple syrup and balsamic vinegar with a pinch of ' \
      's&p. Drizzle generously over the filled squash.',
      'Return to the oven for 10-12 mins until everything is warmed through and the drizzle has caramelized slightly.'
    ],
    tip: 'The squash as a vessel, baby. The cut side down method is key. The natural sugars caramelize directly ' \
         'against the hot parchment and give you a golden, jammy surface. So gorge.'
  },
  {
    # A non-breaking space keeps the & off the end of a line, as in the reference.
    title: "smoky turkey &\u00A0kale soup", slug: 'turkey-kale-soup', kicker: 'easy freeze', category: 'entree',
    image: 'turkey-meatballs.jpg',
    menu_title: 'Easy Freeze Smoky Turkey & Kale Soup',
    menu_blurb: 'ground turkey, white bean, lacinato kale, fresh herbs, crusty bread',
    prep_minutes: 15, cook_minutes: 35, serves: 5,
    ingredients: {
      'Produce' => [
        '1 large yellow onion, diced',
        '4 garlic cloves, minced',
        '1 bunch lacinato kale, stems removed & roughly chopped',
        'handful parsley, chopped',
        '1 lemon, juiced'
      ],
      'Pantry' => [
        'good olive oil',
        'tomato paste',
        '4c better than bouillon chicken base',
        '1 can white beans (15 oz), drained & rinsed',
        'smoked paprika',
        'chili flakes',
        's&p',
        'crusty bread for serving'
      ],
      'Meat' => ['2# ground turkey']
    },
    steps: [
      'Heat olive oil in a large pot over medium-high. Add ground turkey and cook, breaking it up, until browned, ' \
      '6-8 mins. Season with smoked paprika, chili flakes, s&p.',
      'Add onion and cook 4-5 mins until soft. Add garlic, cook 1 min. Add tomato paste, let bloom ~30 secs.',
      'Pour in broth and add white beans. Bring to a boil then reduce to a simmer and cook 15 mins until slightly ' \
      'thickened.',
      'Add kale and simmer 8-10 mins until tender. Finish with lemon juice and fresh parsley. Taste & adjust seasoning.',
      'To freeze: cool completely and portion into airtight containers. Freeze up to 3 months. Reheat on the stovetop ' \
      'with a splash of broth if needed.',
      'Serve with crusty bread.'
    ],
    tip: 'The leaves are flatter, more tender, and slightly less bitter than curly kale which means they hold up ' \
         'beautifully in a long simmer without turning army green or falling apart. Add it toward the end and give ' \
         'it just enough time to become silky and tender without losing its color.'
  },
  {
    title: 'pumpkin hummus', category: 'snack', image: 'pumpkin-hummus.jpg',
    menu_title: 'Pumpkin Hummus',
    menu_blurb: 'pumpkin, chickpeas, tahini, maple syrup, warm spices, served with apple slices & pita',
    prep_minutes: 10, cook_minutes: 20, serves: 5,
    ingredients: {
      'Pantry' => [
        '1 can pumpkin puree (15 oz)',
        '1 can chickpeas (15 oz), drained and rinsed, liquid reserved',
        'tahini',
        'maple syrup',
        'good olive oil',
        'cinnamon',
        'cumin',
        'smoked paprika',
        'a pinch of cayenne',
        's&p',
        'apple slices and warm pita'
      ]
    },
    steps: [
      'Spread canned pumpkin puree in a thin even layer on a parchment-lined sheet. Roast at 400°f for 15-18 mins ' \
      'until slightly darkened at the edges and caramelized. This drives off excess moisture and concentrates the ' \
      'flavor significantly. Let cool slightly.',
      'Add roasted pumpkin, chickpeas, tahini, maple syrup, cumin, cinnamon, smoked paprika, cayenne, and s&p to a ' \
      'food processor. Blend until smooth, 2-3 mins. Option to add a little water at a time until it reaches a ' \
      'smooth, creamy consistency. Taste & adjust maple and spices.',
      'Transfer to a bowl. Finish with a drizzle of good olive oil and a pinch of smoked paprika and top with any ' \
      'herbs you have on hand.',
      'Serve with apple slices and warm pita.'
    ],
    tip: 'If you want to go a step further, roasting a fresh sugar pumpkin is even better. Halve it, scoop the seeds, ' \
         'brush with olive oil, and roast cut side down at 400°f for 45-50 mins until completely tender. Scoop the ' \
         'flesh, blend until smooth, and use cup for cup in place of canned. Save the seeds, toss with olive oil and ' \
         'flaky salt, and roast alongside. Nothing goes to waste.'
  },
  {
    title: 'harvest egg bake', slug: 'egg-bake', category: 'breakfast', image: 'egg-bake.jpg',
    menu_title: 'Harvest Egg Bake',
    menu_blurb: 'eggs, roasted sweet potato, caramelized onion, goat cheese, fresh sage',
    prep_minutes: 15, cook_minutes: 35, serves: 5,
    ingredients: {
      'Produce' => [
        '1 sweet potato, peeled and small diced',
        '1 large yellow onion, thinly sliced',
        'a few fresh sage leaves, roughly chopped',
        'a small handful fresh flat-leaf parsley, chopped',
        '1 lemon, juiced'
      ],
      'Pantry' => [
        'good olive oil',
        'kerrygold butter',
        's&p'
      ],
      'Dairy' => [
        '10 large eggs',
        '1/4 c heavy cream or whole milk',
        '4 oz goat cheese, crumbled'
      ]
    },
    steps: [
      'Preheat oven to 400°f. Toss sweet potato with olive oil and s&p. Spread on a parchment-lined sheet and roast ' \
      '20-25 mins until golden and caramelized. Set aside.',
      'While sweet potato roasts caramelize the onion. Melt butter in an oven-safe skillet over medium-low. Add ' \
      'sliced onion and a pinch of salt. Cook low and slow, stirring occasionally, 20-25 mins until deeply golden ' \
      'and jammy. Add fresh sage in the last 2 mins.',
      'Add roasted sweet potato to the caramelized onion skillet and stir to combine.',
      'Whisk together eggs, heavy cream, parsley, and s&p until smooth. Pour over the vegetables in the skillet.',
      'Dot goat cheese generously across the surface.',
      'Bake 22-25 mins until the center is just set and the top is lightly golden. Rest 5 mins before slicing.',
      'Slice into portions and store in airtight containers in the fridge up to 5 days.'
    ],
    tip: 'One skillet, one oven, 50 mins, and breakfast is done for the week. The caramelized onion and roasted sweet ' \
         'potato do most of the heavy lifting here and both can be prepped simultaneously while the other cooks. By ' \
         'the time the eggs go in the whole thing comes together in under five minutes of active work.'
  }
]

grocery_groups = {
  'Produce' => [
    '1 large delicata squash', '3 medium acorn squash', '1 large sweet potato', '4 large carrots',
    '3 big handfuls fresh baby spinach', '1 large bunch lacinato kale', '1# mixed mushrooms', '3 large yellow onions',
    '1 small yellow onion', '4 heads of garlic', 'fresh ginger', '3 lemons', '1 lemon', 'apple slices for serving',
    'fresh flat-leaf parsley', 'fresh basil', 'fresh mint', 'fresh sage', 'fresh thyme', 'fresh cilantro'
  ],
  'Pantry' => [
    'good olive oil', 'harissa paste', 'tahini', 'tomato paste', 'maple syrup', 'balsamic vinegar',
    'better than bouillon chicken base', 'better than bouillon beef base', '3 cans chickpeas (15 oz each)',
    '1 can full fat coconut milk (14 oz)', '1 can crushed tomatoes (14 oz)', '2 cans white beans (15 oz each)',
    '1 can pumpkin puree (15 oz)', 'dry red wine', '1 lb pappardelle', '2 packages store bought gnocchi (16 oz each)',
    'couscous', '1 c wild rice', '1/3 c dried cranberries', 'walnuts', 'pepitas', 'smoked paprika', 'cumin',
    'turmeric', 'chili flakes', 's&p', 'flaky sea salt', 'warm pita', 'crusty bread'
  ],
  'Dairy/Eggs' => [
    'kerrygold butter', 'imported parmesan', '4 oz goat cheese', 'greek yogurt', '10 large eggs',
    '1/4 c heavy cream or whole milk'
  ],
  'Meat & Seafood' => [
    '8 bone-in skin-on chicken thighs', '2# ground beef', '2# ground turkey', '1# ground italian sausage'
  ]
}

swap_groups = {
  'Gluten-free swaps' => [
    ['pappardelle', 'gf pasta'],
    ['gnocchi', 'potato starch gnocchi'],
    ['crusty bread & pita', 'gf bread & pita']
  ],
  'Dairy-free swaps' => [
    ['parm', 'nutritional yeast'],
    ['butter', 'Miyoko’s vegan butter'],
    ['shredded mozz', 'cashew cream'],
    ['greek yogurt', 'coconut yogurt'],
    ['heavy cream', 'coconut yogurt or oat milk'],
    ['goat cheese', 'cashew cream']
  ]
}

swap_recipes = [
  {
    title: 'Cashew ricotta', yield_label: 'Makes ~1½ cups',
    ingredients: ['1c raw cashews', '2 tbsp lemon juice', '2 tbsp water', '¼ tsp sea salt', '1 clove garlic (optional)'],
    steps: [
      'Soak cashews in hot water for 30 mins (or cold water for 4 hours). Drain well.',
      'Add all ingredients to a blender/food processor.',
      'Blend until smooth and creamy, scraping down sides as needed. Add more water 1 tbsp at a time if too thick.',
      'Taste and adjust salt or lemon as needed.',
      'Store in fridge up to 5 days.'
    ]
  },
  {
    title: 'Cashew cream', yield_label: 'Makes ~1 cup',
    ingredients: ['1 c raw cashews', '½ c water', '1 tbsp lemon juice', 'Pinch of salt'],
    steps: [
      'Soak cashews in hot water for 30 mins. Drain well.',
      'Blend cashews with fresh water, lemon juice, and salt until silky smooth, about 2 mins.',
      'Use immediately or store in fridge up to 5 days.',
      'Thin with more water if needed for sauces.'
    ],
    use_for: 'Creamy pasta sauces, drizzling over bowls, stirring into soups'
  },
  {
    title: 'Cashew queso', yield_label: 'Makes ~1½ cups',
    ingredients: [
      '1 c raw cashews', '½ c water', '3 tbsp nutritional yeast', '1 tbsp lime juice',
      '1 small jalapeño, seeds removed', '½ tsp cumin', '½ tsp garlic powder', '¼ tsp sea salt'
    ],
    steps: [
      'Soak cashews in hot water for 30 mins. Drain well.',
      'Add all ingredients to blender. Blend until completely smooth, 2-3 mins.',
      'Taste and adjust lime, salt, or spice level.',
      'Warm gently in a small pot if you want it hot, stirring frequently.',
      'Store in fridge up to 5 days.'
    ],
    use_for: 'Enchilada bake topping, drizzling over bowls, dipping'
  },
  {
    title: 'Cashew parmesan', yield_label: 'Makes ~¾ cup',
    ingredients: ['½ c raw cashews', '3 tbsp nutritional yeast', '½ tsp garlic powder', '¼ tsp sea salt'],
    steps: [
      'Add all ingredients to a food processor.',
      'Pulse until it resembles grated parmesan (coarse crumbs, not powder).',
      'Store in an airtight jar in fridge up to 2 weeks.'
    ],
    use_for: 'Sprinkling on pasta, salads, roasted vegetables'
  }
]

LemonDrop::Issue.transaction do
  issue = LemonDrop::Issue.create!(title: 'oct 19–23', starts_on: Date.new(2026, 10, 19), ends_on: Date.new(2026, 10, 23))
  add_section = lambda do |sectionable, **attributes|
    issue.sections.create!(sectionable: sectionable, position: issue.sections.count + 1, **attributes)
  end

  add_section.call(LemonDrop::TitlePageSection.new(
    heading: 'the lemon drop', tagline: 'your weekly meal plan', cover_image: lemon_drop_image.call('chickpea-stew.jpg')
  ))

  add_section.call(LemonDrop::IntroSection.new(
    heading: 'hello!', signoff: 'xx beth', icon: lemon_drop_image.call('lemon-slice.png'),
    body_html: '<p>it’s mid october and i’m fully in it. there’s a specific quality of light this time of year that ' \
               'always does something to me, the way it hits a roasted delicata squash or a steamy bowl of golden ' \
               'chickpea stew and turns everything warm and amber and a little magical.</p>' \
               '<p>i find myself drawn to the colors before i even think about the flavors. the deep orange of sweet ' \
               'potato, the forest green of lacinato kale, the brownish-gold of caramelized onion. this week’s menu ' \
               'is built entirely around that feeling. cook it slowly, eat with intention, and let october do its ' \
               'thing.</p>'
  ))

  add_section.call(LemonDrop::TableOfContentsSection.new(heading: 'this week’s drop'))

  add_section.call(LemonDrop::HeroSection.new(
    heading: "let’s\ncook", background_image: lemon_drop_image.call('crispy-chickpeas.jpg'),
    overlay_image: lemon_drop_image.call('fork-knife.png')
  ))

  add_section.call(LemonDrop::MenuOverviewSection.new(heading: 'your menu', icon: lemon_drop_image.call('mortar.png')),
    anchor: 'menu', show_in_toc: true, toc_label: 'recipes')

  recipes_section = LemonDrop::RecipesSection.new
  add_section.call(recipes_section)
  recipes.each.with_index(1) do |attributes, position|
    attributes = attributes.dup
    ingredients = attributes.delete(:ingredients)
    steps = attributes.delete(:steps)
    recipe = recipes_section.recipes.build(position: position, hero_image: lemon_drop_image.call(attributes.delete(:image)),
      **attributes)
    ingredients.each.with_index(1) do |(name, lines), group_position|
      group = recipe.ingredient_groups.build(name: name, position: group_position)
      lines.each.with_index(1) { |text, line_position| group.ingredients.build(text: text, position: line_position) }
    end
    steps.each.with_index(1) { |body, step_position| recipe.steps.build(body: body, position: step_position) }
    recipe.save!
  end

  grocery_list = LemonDrop::GroceryListSection.new(heading: 'your grocery list', icon: lemon_drop_image.call('bowl.png'))
  grocery_groups.each.with_index(1) do |(name, items), position|
    group = grocery_list.grocery_groups.build(name: name, position: position)
    items.each.with_index(1) { |text, item_position| group.grocery_items.build(text: text, position: item_position) }
  end
  add_section.call(grocery_list, theme: 'sage', anchor: 'grocery', show_in_toc: true, toc_label: 'grocery list')

  allergen_swap = LemonDrop::AllergenSwapSection.new(heading: "allergen\nswaps",
    icon: lemon_drop_image.call('stacked-bowls.png'))
  swap_groups.each.with_index(1) do |(name, swaps), position|
    group = allergen_swap.swap_groups.build(name: name, position: position)
    swaps.each.with_index(1) do |(from_text, to_text), swap_position|
      group.swaps.build(from_text: from_text, to_text: to_text, position: swap_position)
    end
  end
  swap_recipes.each.with_index(1) do |attributes, position|
    allergen_swap.swap_recipes.build(position: position, **attributes,
      ingredients: attributes[:ingredients].join("\n"), steps: attributes[:steps].join("\n"))
  end
  add_section.call(allergen_swap, theme: 'sage', anchor: 'swaps', show_in_toc: true, toc_label: 'allergen swaps')

  add_section.call(LemonDrop::OutroSection.new(
    heading: "book your\nholiday party!",
    images: %w[party-1.jpg party-2.jpg party-3.jpg].map(&lemon_drop_image),
    body_html: '<p>our dinner party calendar is filling up and the good dates go fast. We’re currently booking ' \
               'passed apps, dinner parties, brunches, &amp; holiday gatherings into january, with some dates still ' \
               'avail. whether you’re envisioning an intimate plated dinner, a festive family style spread, a ' \
               'cocktail party with passed bites, or someone to handle all the prep before your guests arrive, ' \
               'we’ve got you.</p>' \
               '<p>reach out now to talk deets, dates &amp; pricing.</p>'
  ), anchor: 'party', show_in_toc: true, toc_label: 'let’s party!')

  issue.publish!
end

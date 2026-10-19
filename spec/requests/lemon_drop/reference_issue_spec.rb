require 'spec_helper'

RSpec.describe 'The lemon drop reference Issue', type: :request do
  def load_seed
    load Rails.root.join('db/seeds/lemon_drop.rb')
  end

  def page
    get lemon_drop_issue_path('2026-10-19')
    response.body
  end

  it 'publishes oct 19–23 with the nine Sections in the reference order' do
    load_seed

    expect(page.scan(/<div id="([^"]+)" class="theme-(\w+)">/)).to eq([
      %w[title-page cream], %w[intro cream], %w[table-of-contents cream], %w[hero cream], %w[menu cream],
      %w[recipes cream], %w[grocery sage], %w[swaps sage], %w[party cream]
    ])
    expect(response.body).to include('<title>the lemon drop · oct 19–23</title>')
  end

  it 'lists the four Table of Contents entries and the menu categories' do
    load_seed

    expect(page[%r{<section class="contents">.*?</section>}m].scan(%r{<a href="#([^"]+)">([^<]+)</a>})).to eq([
      %w[menu recipes], ['grocery', 'grocery list'], ['swaps', 'allergen swaps'], ['party', 'let’s party!']
    ])
    expect(response.body.scan(%r{<div class="menu-cat mono-caps">([^<]+)</div>}).flatten).to eq(%w[entrees soup snack breakfast])
  end

  it 'puts the grocery groups in the reference columns: Produce, Pantry, then Dairy/Eggs with Meat & Seafood' do
    load_seed

    columns = page[%r{<div class="grocery-grid">.*?</section>}m].split('<div class="grocery-col">').drop(1)
    expect(columns.map { |column| column.scan(%r{<h3>([^<]+)</h3>}).flatten }).to eq([
      ['Produce'], ['Pantry'], ['Dairy/Eggs', 'Meat &amp; Seafood']
    ])
  end

  it 'breaks the allergen swap and outro headings across lines, as the reference does' do
    load_seed

    expect(page).to include('<h2>allergen<br>swaps</h2>', '<h2>book your<br>holiday party!</h2>')
  end

  it 'leaves the Issue alone when run again' do
    load_seed
    LemonDrop::Issue.find_by!(slug: '2026-10-19').update!(title: 'edited in the admin')

    expect { load_seed }.not_to change(LemonDrop::Issue, :count)
    expect(LemonDrop::Issue.find_by!(slug: '2026-10-19').title).to eq('edited in the admin')
  end
end

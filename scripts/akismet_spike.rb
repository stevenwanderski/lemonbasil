Akismet.api_key = 'c53388e9bb4e'
Akismet.app_url = 'https://lemonandbsil.co'

is_spam, is_blatant = Akismet.check(
  '73.22.0.234',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
  text: 'Buy everything ... now!'
)

ap is_spam
ap is_blatant
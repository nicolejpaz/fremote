Sitemap::Generator.instance.load :host => "fremote.tv" do

  # Sample path:
  #   path :faq
  # The specified path must exist in your routes file (usually specified through :as).

  # Sample path with params:
  #   path :faq, :params => { :format => "html", :filter => "recent" }
  # Depending on the route, the resolved url could be http://mywebsite.com/frequent-questions.html?filter=recent.

  # Sample resource:
  #   resources :articles

  # Sample resource with custom objects:
  #   resources :articles, :objects => proc { Article.published }

  # Sample resource with search options:
  #   resources :articles, :priority => 0.8, :change_frequency => "monthly"

  # Sample resource with block options:
  #   resources :activities,
  #             :skip_index => true,
  #             :updated_at => proc { |activity| activity.published_at.strftime("%Y-%m-%d") }
  #             :params => { :subdomain => proc { |activity| activity.location } }
  path :root, :priority => 1
  path :new_user_registration, :priority => 0.8
  path :new_user_session, :priority => 0.8
  literal "/how-it-works", :priority => 0.5, :change_frequency => "weekly"
  literal "/terms-of-use", :priority => 0.5, :change_frequency => "monthly"
  literal "/privacy-policy", :priority => 0.5, :change_frequency => "monthly"
  literal "http://paradoxsector.blogspot.com"
end

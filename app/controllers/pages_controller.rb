class PagesController < ApplicationController
 
  def how_it_works
  end

  def privacy_policy
  end

  def terms_of_use
  end

  def sitemap
      respond_to do |format|
        format.xml { render 'pages/sitemap.xml', layout: false }
      end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FormsController do
  describe "#index" do
    integrate_views
    
    before do
      get :index
    end
    
    it "should assign the page title to nothing" do
      assigns[:page_title].should be_nil
    end
    
    it "should set the page title to 'Search.USA.gov Forms'" do
      response.should have_tag("title", :content => 'Search.USA.gov Forms')
    end
    
    it "should have meta tags for description and keywords" do
      response.should have_tag("meta[name=description]")
      response.should have_tag("meta[name=keywords]")
    end
  end
end

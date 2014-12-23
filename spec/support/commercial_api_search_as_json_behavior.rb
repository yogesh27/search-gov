shared_examples 'a commercial API search as_json' do
  let(:current_time) { DateTime.parse 'Wed, 17 Dec 2014 18:33:43 +0000' }
  let(:search_rash) { search_rash = Hashie::Rash.new(JSON.parse(search.to_json)) }

  context 'when recent video news are present' do
    fixtures :rss_feed_urls, :rss_feeds, :youtube_profiles

    before do
      youtube_profile = youtube_profiles(:whitehouse)
      search.affiliate.enable_video_govbox!

      rss_feed_url = youtube_profile.rss_feed.rss_feed_urls.first
      rss_feed_url.news_items.delete_all

      news_items = (1..2).map do |i|
        NewsItem.create!(rss_feed_url: rss_feed_url,
                         link: "http://www.youtube.com/watch?v=#{i}&feature=youtube_gdata",
                         title: "video #{i}",
                         description: 'already exist description',
                         published_at: current_time.advance(days: -i),
                         guid: "http://gdata.youtube.com/feeds/base/videos/#{i}",
                         updated_at: Time.current)
      end

      search.stub(:video_news_items) { mock(ElasticNewsItemResults, results: news_items) }
    end

    it 'includes recent_video_news' do
      recent_news_item = search_rash.recent_video_news.first.to_hash.symbolize_keys
      expect(recent_news_item).to eq(pub_date: '2014-12-16',
                                     source: 'YouTube',
                                     thumbnail_url: 'https://i.ytimg.com/vi/1/default.jpg',
                                     title: 'video 1',
                                     url: 'http://www.youtube.com/watch?v=1&feature=youtube_gdata')

      recent_news_item = search_rash.recent_video_news.last.to_hash.symbolize_keys
      expect(recent_news_item).to eq(pub_date: '2014-12-15',
                                     source: 'YouTube',
                                     thumbnail_url: 'https://i.ytimg.com/vi/2/default.jpg',
                                     title: 'video 2',
                                     url: 'http://www.youtube.com/watch?v=2&feature=youtube_gdata')
    end
  end

  context 'when recent news are present' do
    before do
      rss_feed = search.affiliate.rss_feeds.build(name: 'News')
      url = 'http://search.digitalgov.gov/all.atom'
      rss_feed_url = RssFeedUrl.rss_feed_owned_by_affiliate.build(url: url)
      rss_feed_url.save!(validate: false)
      rss_feed.rss_feed_urls = [rss_feed_url]
      rss_feed.save!

      news_items = (1..2).map do |i|
        attributes = {
          title: "recent news title-#{i}",
          link: "http://search.digitalgov.gov/news-#{i}",
          guid: "blog-#{i}",
          description: "v2 news description #{i}",
          published_at: current_time.advance(days: -i)
        }
        rss_feed_url.news_items.create! attributes
      end

      search.stub(:news_items) { mock(ElasticNewsItemResults, results: news_items) }
    end

    it 'includes recent_news' do
      recent_news_item = search_rash.recent_news.first.to_hash.symbolize_keys
      expect(recent_news_item).to eq(pub_date: '2014-12-16',
                                     source: 'News',
                                     title: 'recent news title-1',
                                     url: 'http://search.digitalgov.gov/news-1')

      recent_news_item = search_rash.recent_news.last.to_hash.symbolize_keys
      expect(recent_news_item).to eq(pub_date: '2014-12-15',
                                     source: 'News',
                                     title: 'recent news title-2',
                                     url: 'http://search.digitalgov.gov/news-2')
    end
  end
end

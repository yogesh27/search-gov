require 'spec/spec_helper'

describe MedTopic do
  before(:all) do
    MedTopic.destroy_all('LENGTH(medline_title) = 3')
    MedGroup.destroy_all
    MedSynonym.destroy_all
    MedTopicGroup.destroy_all
    MedTopicRelated.destroy_all

    @valid_attributes = {
        :medline_title => "Supreme Paranoia",
        :medline_url   => "#{MedTopic::MEDLINE_BASE_URL}spanish/huevos_rancheros.html",
        :locale        => "es",
        :medline_tid   => 42
    }

    @medline_subset_tiny_vocab_xml           = File.read(Rails.root.to_s + "/spec/fixtures/xml/medline_vocab_2011-04-23_tiny.xml")
    @medline_subset_sample_vocab_xml         = File.read(Rails.root.to_s + "/spec/fixtures/xml/medline_vocab_2011-04-23_sample.xml")
    @medline_subset_sample_vocab_xml_1       = File.read(Rails.root.to_s + "/spec/fixtures/xml/medline_vocab_2011-04-23_sample_1.xml")
    @medline_topic_ample_summaries_unlinted  = MedTopic.medline_batch_from_json_file(Rails.root.to_s + "/spec/fixtures/json/medline_topic_summaries.json")
    @medline_topic_sample_summaries_linted   = MedTopic.medline_batch_from_json_file(Rails.root.to_s + "/spec/fixtures/json/medline_topic_summaries_linted.json")
    @medline_topic_sample_summaries_unlinted = MedTopic.medline_batch_from_json_file(Rails.root.to_s + "/spec/fixtures/json/medline_topic_summaries.json")

    @empty_vocab = { :topics => { }, :groups => { } }

    @medline_subset_tiny_vocab = {
        :topics => {
            1867 => {
                :medline_title  => "Agua potable",
                :mesh_titles    => "",
                :synonyms       => ["Agua para beber"],
                :locale         => "es",
                :medline_url    => "http://www.nlm.nih.gov/medlineplus/spanish/drinkingwater.html",
                :summary_html   => "<p>Todas las criaturas vivas necesitan agua sana y potable...</p>",
                :related_groups => [26, 28],
                :related_topics => [],
                :lang_map       => 1435
            },
            1435 => {
                :medline_title  => "Drinking Water",
                :mesh_titles    => "Water",
                :synonyms       => [],
                :locale         => "en",
                :medline_url    => "http://www.nlm.nih.gov/medlineplus/drinkingwater.html",
                :summary_html   => "<p>Every living creature needs clean and safe drinking water...</p>",
                :related_groups => [26, 28],
                :related_topics => [218],
                :lang_map       => 1867
            },
            218  => {
                :medline_title  => "Drowning",
                :mesh_titles    => "Drowning",
                :synonyms       => [],
                :locale         => "en",
                :medline_url    => "http://www.nlm.nih.gov/medlineplus/drowning.html",
                :summary_html   => "<p>If you are under water long enough, your lungs fill with water...</p>",
                :related_groups => [19],
                :related_topics => [],
                :lang_map       => nil
            }
        },
        :groups => {
            19 => {
                "en" => {
                    :medline_title => "Injuries and Wounds",
                    :medline_url   => "http://www.nlm.nih.gov/medlineplus/injuriesandwounds.html"
                }
            },
            28 => {
                "en" => {
                    :medline_title => "Poisoning, Toxicology, Environmental Health",
                    :medline_url   => "http://www.nlm.nih.gov/medlineplus/poisoningtoxicologyenvironmentalhealth.html"
                },
                "es" => {
                    :medline_title => "Envenenamientos, toxicología y salud ambiental",
                    :medline_url   => "http://www.nlm.nih.gov/medlineplus/spanish/poisoningtoxicologyenvironmentalhealth.html"
                }
            },
            26 => {
                "en" => {
                    :medline_title => "Food and Nutrition",
                    :medline_url   => "http://www.nlm.nih.gov/medlineplus/foodandnutrition.html"
                },
                "es" => {
                    :medline_title => "Alimentos y nutrición",
                    :medline_url   => "http://www.nlm.nih.gov/medlineplus/spanish/foodandnutrition.html"
                }
            }
        }
    }

    @vocab_empty_to_tiny_delta = {
        :create_group => {
            { :medline_gid=>19, :locale=>"en" } => {
                :medline_title => "Injuries and Wounds",
                :medline_url   => "http://www.nlm.nih.gov/medlineplus/injuriesandwounds.html"
            },
            { :medline_gid=>28, :locale=>"es" } => {
                :medline_title => "Envenenamientos, toxicología y salud ambiental",
                :medline_url   => "http://www.nlm.nih.gov/medlineplus/spanish/poisoningtoxicologyenvironmentalhealth.html"
            },
            { :medline_gid=>28, :locale=>"en" } => {
                :medline_title => "Poisoning, Toxicology, Environmental Health",
                :medline_url   => "http://www.nlm.nih.gov/medlineplus/poisoningtoxicologyenvironmentalhealth.html"
            },
            { :medline_gid=>26, :locale=>"es" } => {
                :medline_title => "Alimentos y nutrición",
                :medline_url   => "http://www.nlm.nih.gov/medlineplus/spanish/foodandnutrition.html"
            },
            { :medline_gid=>26, :locale=>"en" } => {
                :medline_title => "Food and Nutrition",
                :medline_url   => "http://www.nlm.nih.gov/medlineplus/foodandnutrition.html"
            }
        },
        :create_topic => {
            { :medline_tid => 1867 } => {
                :medline_title  => "Agua potable",
                :medline_url    => "http://www.nlm.nih.gov/medlineplus/spanish/drinkingwater.html",
                :synonyms       => ["Agua para beber"],
                :related_groups => [26, 28],
                :related_topics => [],
                :summary_html   => "<p>Todas las criaturas vivas necesitan agua sana y potable...</p>",
                :locale         => "es",
                :mesh_titles    => "",
                :lang_map       => 1435
            },
            { :medline_tid => 218 }  => {
                :medline_title  => "Drowning",
                :medline_url    => "http://www.nlm.nih.gov/medlineplus/drowning.html",
                :synonyms       => [],
                :related_groups => [19],
                :related_topics => [],
                :summary_html   => "<p>If you are under water long enough, your lungs fill with water...</p>",
                :locale         => "en",
                :mesh_titles    => "Drowning",
                :lang_map       => nil
            },
            { :medline_tid => 1435 } => {
                :medline_title  => "Drinking Water",
                :medline_url    => "http://www.nlm.nih.gov/medlineplus/drinkingwater.html",
                :synonyms       => [],
                :related_groups => [26, 28],
                :related_topics => [218],
                :summary_html   => "<p>Every living creature needs clean and safe drinking water...</p>",
                :locale         => "en",
                :mesh_titles    => "Water",
                :lang_map       => 1867
            }
        }
    }

    @vocab_tiny_to_empty_delta = {
        :delete_topic => [
            { :medline_tid => 218 },
            { :medline_tid => 1435 },
            { :medline_tid => 1867 }
        ],
        :delete_group => [
            { :medline_gid => 19, :locale => "en" },
            { :medline_gid => 26, :locale => "en" },
            { :medline_gid => 26, :locale => "es" },
            { :medline_gid => 28, :locale => "en" },
            { :medline_gid => 28, :locale => "es" }
        ]
    }


    @small_sample_vocab = {

        :topics => {

            3  => { :medline_title  => "tea", :synonyms => ["tea1", "tea2", "tea3"],
                    :locale         => "en",
                    :lang_map       => 13,
                    :related_groups => [2, 3],
                    :related_topics => []
            },

            4  => { :medline_title  => "teb", :synonyms => ["teb1"],
                    :locale         => "en",
                    :lang_map       => 14,
                    :related_groups => [2, 3],
                    :related_topics => []
            },

            5  => { :medline_title  => "tec", :synonyms => [],
                    :locale         => "en",
                    :lang_map       => 15,
                    :related_groups => [2, 3],
                    :related_topics => []
            },

            7  => { :medline_title  => "tee", :synonyms => ["tee1", "tee2", "tee3"],
                    :locale         => "en",
                    :lang_map       => nil,
                    :related_groups => [2, 3],
                    :related_topics => []
            },

            8  => { :medline_title  => "txf", :synonyms => ["tef1", "tef2", "tef3"],
                    :locale         => "en",
                    :lang_map       => 18,
                    :related_groups => [2, 3, 4],
                    :related_topics => []
            },

            9  => { :medline_title  => "teg", :synonyms => ["teg1", "teg2", "teg3"],
                    :locale         => "en",
                    :lang_map       => 19,
                    :related_groups => [2, 3, 4, 5],
                    :related_topics => []
            },

            13 => { :medline_title  => "tsa", :synonyms => ["tsa1", "tsa2", "tsa3"],
                    :locale         => "es",
                    :lang_map       => 13,
                    :related_groups => [2, 3],
                    :related_topics => []
            },
            14 => { :medline_title  => "tsb", :synonyms => ["tsb1"],
                    :locale         => "es",
                    :lang_map       => 4,
                    :related_groups => [2, 3],
                    :related_topics => []
            },
            15 => { :medline_title  => "tsc", :synonyms => [],
                    :locale         => "es",
                    :lang_map       => 5,
                    :related_groups => [2, 3],
                    :related_topics => []
            },
            16 => { :medline_title  => "tsd", :synonyms => ["tsd1", "tsd2", "tsd3"],
                    :locale         => "es",
                    :lang_map       => nil,
                    :related_groups => [2, 3],
                    :related_topics => []
            },
            18 => { :medline_title  => "txf", :synonyms => ["tsf1", "tsf2"],
                    :locale         => "es",
                    :lang_map       => 8,
                    :related_groups => [2, 3, 4],
                    :related_topics => []
            },
            19 => { :medline_title  => "tsg", :synonyms => ["tsg1", "tsg2", "tsg3", "teg"],
                    :locale         => "es",
                    :lang_map       => 9,
                    :related_groups => [2, 3, 4, 5],
                    :related_topics => []
            }
        },

        :groups => {
            2 => { "en" => { :medline_title => "gea" }, "es" => { :medline_title => "gsa" } },
            3 => { "en" => { :medline_title => "geb" }, "es" => { :medline_title => "gsb" } },
            4 => { "en" => { :medline_title => "gec" }, "es" => { :medline_title => "gsc" } },
            5 => { "en" => { :medline_title => "ged" }, "es" => { :medline_title => "gsd" } },
        }

    }

    @medline_lint_xml = "<MedicalTopics><MedicalTopic ID=\"T1867\" langcode=\"Spanish\"><ID>1867</ID><MedicalTopicName>Agua potable</MedicalTopicName><URL>http://www.nlm.nih.gov/medlineplus/spanish/drinkingwater.html</URL><FullSummary>&lt;o&gt;&lt;p&gt;Todas las criaturas vivas necesitan agua sana y potable...&lt;/p&gt;&lt;/o&gt;</FullSummary></MedicalTopic></MedicalTopics>"
  end

  it { should validate_presence_of :medline_title }
  it { should validate_presence_of :locale }
  it { should validate_presence_of :medline_tid }

  it "should create a new instance given valid attributes" do
    MedTopic.create!(@valid_attributes)
  end

  it "should delete MedTopicSyns associated with a MedTopic on deleting that MedTopic" do
    t = MedTopic.new(@valid_attributes)
    t.save!
    t.synonyms.create({ :medline_title => 'rushoes rancheros' })
    t.destroy
    MedSynonym.find_by_medline_title('rushoes rancheros').should be_nil
  end

  describe "summary html linting" do
    it "should not explode the json test rig" do
      expected_result = [{ 1 => 2, :a => { 3 => "4" } }]
      MedTopic.ensym_string_keys([{ "1" => 2, "a" => { "3" => "4" } }]).should eql expected_result
    end

    it "should not complain about nil xhtml" do
      msgs = []
      MedTopic.lint_medline_topic_summary_html(nil) { |msg| msgs << msg }.should be_nil
      msgs.should eql []
    end

    it "should complain about empty xhtml" do
      msgs = []
      MedTopic.lint_medline_topic_summary_html("") { |msg| msgs << msg }.should be_nil
      msgs.should eql ["empty"]
    end

    it "should complain about something unexpected at root level" do
      msgs = []
      MedTopic.lint_medline_topic_summary_html("&amp;<p>x</p><author>NASA</author>") { |msg| msgs << msg }.should eql "<p>x</p>"
      msgs.should eql ["ignored root text outside p or li: &", "ignored all root tags but p or ul: author"]
    end

    it "should complain about really badly formed xml" do
      msgs = []
      Nokogiri::XML.stub!(:fragment).and_raise("oops")
      MedTopic.lint_medline_topic_summary_html("</reallybadxml>") { |msg| msgs << msg }.should be_nil
      msgs.should eql ["could not parse: oops"]
    end

    it "should patch somewhat badly formed xml" do
      msgs = []
      MedTopic.lint_medline_topic_summary_html("<p>x x x</li>") { |msg| msgs << msg }.should eql "<p>x x x</p>"
      msgs.should eql []
    end

    it "should complain about things that are not text but should be" do

      msgs = []
      MedTopic.lint_medline_topic_summary_html("<p><em><p>odd</p></em></p>") { |msg| msgs << msg }.should eql "<p><em></em></p>"
      msgs.should eql ["only text allowed here: <p>odd</p>"]

    end

    it "should complain about atts on <a> unless it is an href" do
      msgs = []
      MedTopic.lint_medline_topic_summary_html("<p><a style=\"highlyvisible\">a</a></p>") { |msg| msgs << msg }.should eql "<p>a</p>"
      msgs.should eql ["<a> should only contain href attribute"]
    end

    it "should complain about atts on <p> unless it is style" do
      msgs = []
      MedTopic.lint_medline_topic_summary_html("<p>a</p><p style=\"garish\">a</p><p class=\"uber_p\">c</p>") { |msg| msgs << msg }.should eql "<p>a</p>"
      msgs.should eql ["<p> should contain no attributes"]
    end

    it "should complain about text atts on <ul>, <li>, or <em>" do
      msgs = []
      MedTopic.lint_medline_topic_summary_html("<p>hello <em style=\"invisible\">em</em></p><ul class=\"yoyodyne\"><li>a</li><li style=\"garish\">b</style></li></ul>>") { |msg| msgs << msg }.should eql "<p>hello <em>em</em></p><ul><li>a</li><li>b</li></ul>"
      msgs.should eql ["<em> should contain no attributes", "<ul> should contain no attributes", "<li> should contain no attributes"]
    end

    it "should complain about text outside <li> or <p> (invalid xml)" do
      msgs = []
      MedTopic.lint_medline_topic_summary_html("a<p>x</p>b<ul><em>k</em>c<li>y</li>d</ul>e<p>z</p>f") { |msg| msgs << msg }.should eql "<p>x</p><ul><li>y</li></ul><p>z</p>"
      msgs.should eql ["ignored root text outside p or li: a", "ignored root text outside p or li: b", "ignored em under <ul>", "ignored under <ul>: c", "ignored under <ul>: d", "ignored root text outside p or li: e", "ignored root text outside p or li: f"]
    end

    it "should tell good summary urls from bad ones" do
      MedTopic.acceptable_summary_url?("http://www.nlm.nih.gov/medlineplus/spanish/sometopic.html").should be_true
      MedTopic.acceptable_summary_url?("http://www.xxxgirlz.com/racypics/").should be_false
      MedTopic.acceptable_summary_url?("file://localhost/SYSINIT.INI").should be_false
      MedTopic.acceptable_summary_url?("I am not a URL").should be_false
      MedTopic.acceptable_summary_url?(nil).should be_false
    end

    it "should complain about non-medline hrefs in summary text" do
      msgs = []
      MedTopic.lint_medline_topic_summary_html("<p>x</p><ul><li><a href=\"http://www.xxxgirlz.com/racypics/\">y</a></li></ul><p>z</p>") { |msg| msgs << msg }
      msgs.should eql ["non-medline href to http://www.xxxgirlz.com/racypics/"]
    end

    it "should not complain about decent summaries" do
      @medline_topic_sample_summaries_unlinted.each { |name, summary|
        msgs                    = []
        linted_summary          = MedTopic.lint_medline_topic_summary_html(summary) { |msg| msgs << msg }
        expected_linted_summary = @medline_topic_sample_summaries_linted[name]
        linted_summary.should eql expected_linted_summary
        msgs.should eql []
      }
    end

  end


  describe "constants" do

    it "should know the correct medline base url" do
      MedTopic::MEDLINE_BASE_URL.should eql "http://www.nlm.nih.gov/medlineplus/"
    end

    it "should know where to put tmp files" do
      tmp_dir_path = MedTopic.tmp_dir
      (File.exist? tmp_dir_path).should be_true
      (File.writable? tmp_dir_path).should be_true
      (File.directory? tmp_dir_path).should be_true
      MedTopic.cached_file_path("mplus_vocab_2011-04-23.xml").to_s.index(tmp_dir_path.to_s).should eql 0
    end

  end

  describe "xml_base_name_for_date" do
    it "should know the right medline vocab xml file name to fetch" do
      MedTopic.stub!(:saturday_on_or_before).and_return Date.parse("2011-04-16")
      MedTopic.xml_base_name_for_date(nil).should eql "mplus_vocab_2011-04-16"
    end

    it "should create a filename based on the date" do
      date = Date.parse("2011-04-21")
      MedTopic.xml_base_name_for_date(date).should eql "mplus_vocab_2011-04-21"
    end
  end

  describe "#saturday_on_or_before(date)" do
    context "when the date is a Saturday" do
      before do
        @date = Date.parse("2011-12-03")
      end

      it "should return that day" do
        MedTopic.saturday_on_or_before(@date).to_s.should == "2011-12-03"
      end
    end

    context "when the date is a Saturday" do
      before do
        @date = Date.parse("2011-12-07")
      end

      it "should return the previous Saturday" do
        MedTopic.saturday_on_or_before(@date).to_s.should == "2011-12-03"
      end
    end
  end

  describe "medline_xml_for_date" do
    before(:all) do
      @cached_file_path = MedTopic.cached_file_path("mplus_vocab_2011-04-23.xml")
      File.delete(@cached_file_path) if File.exist?(@cached_file_path)
    end

    context "when getting data from medline" do
      before do
        response = mock("response")
        Net::HTTP.stub!(:get_response).and_return(response)
        @mock_sample_xml_content = File.read(Rails.root.to_s + "/spec/fixtures/xml/medline_vocab_2011-04-23_sample.xml")
        response.stub!(:body).and_return(@mock_sample_xml_content)
      end

      it "should cache the xml" do
        starting_fetch_count = MedTopic.fetch_count
        File.exist?(@cached_file_path).should be false
        xml_a = MedTopic.medline_xml_for_date(Date.parse("2011-04-23"))
        xml_a.should eql @mock_sample_xml_content
        MedTopic.fetch_count.should eql(starting_fetch_count + 1)
        File.exist?(@cached_file_path).should be true
        xml_b = MedTopic.medline_xml_for_date(Date.parse("2011-04-23"))
        xml_b.should eql @mock_sample_xml_content
        MedTopic.fetch_count.should eql(starting_fetch_count + 1)
      end
    end
  end


  describe "#parse_medline_xml_vocab" do
    it "should parse an empty vocab" do
      v = MedTopic.parse_medline_xml_vocab("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE MedicalTopics PUBLIC \"-//NLM//DTD MedicalTopics //EN\" \"http://www.nlm.nih.gov/medlineplus/xml/vocabulary/mplus_vocab.dtd\">\n<MedicalTopics total=\"0\" totalEnglish=\"0\" totalSpanish=\"0\" dategenerated=\"04/23/2011 12:07:53\"></MedicalTopics>")
      v.should eql @empty_vocab
    end

    it "should parse a tiny vocab" do
      v = MedTopic.parse_medline_xml_vocab(@medline_subset_tiny_vocab_xml)
      v.should eql @medline_subset_tiny_vocab
    end
  end


  describe "#delta_medline_vocab" do

    it "should be able to diff two empty vocabs" do
      expected_delta = { }
      MedTopic.delta_medline_vocab(@empty_vocab, @empty_vocab).should eql expected_delta
    end

    it "should be able to diff from empty to tiny vocab" do
      MedTopic.delta_medline_vocab(@empty_vocab, @medline_subset_tiny_vocab).should eql @vocab_empty_to_tiny_delta
    end

    it "should be able to diff two tiny vocab" do
      expected_delta = { }
      MedTopic.delta_medline_vocab(@medline_subset_tiny_vocab, @medline_subset_tiny_vocab).should eql expected_delta
    end

    it "should be able to diff from tiny to empty vocab" do
      MedTopic.delta_medline_vocab(@medline_subset_tiny_vocab, @empty_vocab).should eql @vocab_tiny_to_empty_delta
    end

  end

  describe "#dump_db_vocab" do
    it "should return topics matching the actual number of topics" do
      MedTopic.dump_db_vocab[:topics].size.should == MedTopic.count
    end

    it "should return groups matching the actual number of groups" do
      MedTopic.dump_db_vocab[:groups].size.should == MedGroup.count
    end
  end

  describe "#lint_medline_xml_for_date" do
    it "should produce the right diagnostics" do
      @msgs = []
      MedTopic.stub!(:medline_xml_for_date).and_return @medline_lint_xml
      MedTopic.lint_medline_xml_for_date(nil) { |msg| @msgs << msg }
      @msgs.should eql ["1867: ignored all root tags but p or ul: o", "found 1 topics / 0 groups", "1 topics without groups:", "  1867: Agua potable", "single-locale topics:", "  1867: Agua potable"]
    end
  end

  describe "#apply_vocab_delta" do
    it "should be able to apply an empty vocab delta to an existing db" do
      db_vocab = MedTopic.dump_db_vocab
      MedTopic.apply_vocab_delta({ })
      MedTopic.dump_db_vocab.should eql db_vocab
    end

    it "should be able to apply and unapply a tiny delta to the db" do
      db_vocab = MedTopic.dump_db_vocab
      MedTopic.apply_vocab_delta(@vocab_empty_to_tiny_delta)
      MedTopic.apply_vocab_delta(@vocab_tiny_to_empty_delta)
      MedTopic.dump_db_vocab.should eql db_vocab
    end

    it "should apply vocab deltas properly to the db" do
      vocab          = MedTopic.parse_medline_xml_vocab(@medline_subset_sample_vocab_xml)
      @current_state = MedTopic.dump_db_vocab
      delta          = MedTopic.delta_medline_vocab(@current_state, vocab)
      delta[:create_topic].keys.collect { |topic_key| topic_key[:medline_tid] }.sort.should eql [
                                                                                                    218, 364, 422, 485, 500, 1330, 1435, 1456, 1539, 1569, 1656, 1756, 1758, 1793, 1867,
                                                                                                    1868, 2055, 2070, 2095, 2131, 2175, 2258, 4361, 4606, 4607, 5559, 5560
                                                                                                ]
      delta[:create_group].keys.collect { |topic_key| topic_key[:medline_gid] }.sort.should eql [
                                                                                                    5, 5, 12, 12, 14, 14, 15, 15, 16, 16, 19, 19, 21, 26, 26, 28, 28, 29, 29, 44, 44
                                                                                                ]
      MedTopic.apply_vocab_delta(delta)
      MedTopic.dump_db_vocab.should eql vocab

      delta[:create_topic].keys.sort_by { |topic_key| topic_key[:medline_tid]}.collect { |topic_key| [topic_key[:medline_tid],delta[:create_topic][topic_key][:mesh_titles]] }.should eql [
          [218, "Drowning"],
          [364, "Poisoning"],
          [422, "Stress, Psychological"],
          [485, "Safety"],
          [500, "Noise"],
          [1330, "Asbestos:Asbestosis"],
          [1435, "Water"],
          [1456, "Caffeine"],
          [1539, "Ozone"],
          [1569, "Arsenic:Arsenic Poisoning"],
          [1656, "Plague"],
          [1756, ""],
          [1758, ""],
          [1793, ""],
          [1867, ""],
          [1868, ""],
          [2055, ""],
          [2070, ""],
          [2095, ""],
          [2131, ""],
          [2175, ""],
          [2258, ""],
          [4361, "von Hippel-Lindau Disease"],
          [4606, "Tsunamis"],
          [4607, ""],
          [5559, "Coma:Persistent Vegetative State"],
          [5560, ""]
      ]

      msgs = []

      vocab1 = MedTopic.parse_medline_xml_vocab(@medline_subset_sample_vocab_xml_1) { |tid, msg|
        msgs << "#{tid}: #{msg}"
      }

      msgs.should eql ["1330: ignored root text outside p or li: oops.\n"]

      delta1 = MedTopic.delta_medline_vocab(MedTopic.dump_db_vocab, vocab1)

      expected_delta = {
          :delete_group => [
              { :medline_gid => 26, :locale => "es" }
          ],
          :update_topic => {
              { :medline_tid => 1330 } => { :medline_title => "Asbestosis", :summary_html=>"<p>Asbestos is the name of a group of minerals with long, thin fibers.</p>", :related_groups=>[15] },
              { :medline_tid => 1569 } => { :related_topics => [1435, 1758], :summary_html => nil, :lang_map => nil },
              { :medline_tid => 1758 } => { :synonyms => ["Amianto", "Amiantorillo"] },
              { :medline_tid => 1793 } => { :related_groups => [] },
              { :medline_tid => 1867 } => { :related_groups => [28] },
              { :medline_tid => 2055 } => { :mesh_titles => "Noise, Random:Noise, Pink:Noise, Purplish" },
          },
          :update_group => {
              { :medline_gid => 28, :locale => "en" } => { :medline_url => "http://www.nlm.nih.gov/medlineplus/poisoningandsuch.html" }
          }
      }

      delta1.should eql expected_delta
      MedTopic.apply_vocab_delta(delta1)

      arsenic_en = MedTopic.search_for("arsenic", "en")
      arsenic_en.related_topics.collect { |related_topics| related_topics.medline_tid }.sort.should eql [1435, 1758]

      arsenic_en.has_mesh_titles?.should be_true
      arsenic_en.mesh_title_list.should == ["Arsenic", "Arsenic Poisoning"]

      negating_delta = MedTopic.delta_medline_vocab(vocab1, @empty_vocab)
      negating_delta.should_not eql []
      MedTopic.apply_vocab_delta(negating_delta)
      MedTopic.dump_db_vocab.should eql @empty_vocab
    end

  end


  describe "#parse_medline_xml_meshheads" do
    before(:all) do
      @mesh_title_xml = Nokogiri::XML(File.read(Rails.root.to_s + "/spec/fixtures/xml/medline_meshtitles.xml"))
    end

    it "should deal with empty xml" do
      MedTopic.parse_medline_xml_meshheads(nil).should eql []
    end

    it "should parse meshheading correctly" do
      tests_run = 0
      @mesh_title_xml.xpath("tests/test").each do |test_data|
        test_stimulus = test_data.at_xpath("stimulus")
        test_response = test_data.at_xpath("response").text.split(":")
        MedTopic.parse_medline_xml_meshheads(test_stimulus).should eql test_response
        tests_run += 1
      end
      tests_run.should == 2
    end
  end


  describe "#search_for" do
    before(:all) do
      MedGroup.destroy_all
      delta = MedTopic.delta_medline_vocab(nil, @small_sample_vocab)
      MedTopic.apply_vocab_delta(delta)
    end

    it "should return nil unless there is a match" do
      MedTopic.search_for("nothing").should be_nil
    end

    it "should assume en locale unless otherwise specified" do
      topic = MedTopic.search_for("txf")
      topic.should_not be_nil
      topic.medline_tid.should >= 8
    end

    it "should find right topic depending on locale when there are matches in multiple locales" do
      ["en", "es"].each { |locale|
        found_topics = MedTopic.search_for("txf", locale)
        found_topics.should_not be_nil
        found_topics.locale.should eql locale
      }
    end

    it "should find right topic with the matching locale" do
      ["a", "b", "c", "g"].each do |l|
        en_match = MedTopic.search_for("te#{l}", "en")
        en_match.medline_title.should eql "te#{l}"
        en_match.locale.should eql "en"

        en_no_match = MedTopic.search_for("ts#{l}", "en")
        en_no_match.should be_blank

        es_match = MedTopic.search_for("ts#{l}", "es")
        es_match.medline_title.should eql "ts#{l}"
        es_match.locale.should eql "es"
      end
    end

    it "should give you the right groups and synonyms" do
      tee = MedTopic.search_for("tee")
      tee.medline_title.should eql "tee"
      tee.locale.should eql "en"
      tee.related_groups.collect { |group| group.medline_gid }.sort.should eql [2, 3]
      tee.synonyms.collect { |synonym| synonym.medline_title }.sort.should eql ["tee1", "tee2", "tee3"]
    end

    it "should give you the right topic by synonyms" do
      @small_sample_vocab[:topics].each { |medline_tid, topic_atts|
        topic_atts[:synonyms].each { |syn|
          topic = MedTopic.search_for(syn, topic_atts[:locale])
          topic.should_not be_nil
          unless syn == "teg"
            topic.medline_tid.should eql medline_tid
          end
        }
      }
    end

    it "should not find invisible topics" do
      MedTopic.apply_vocab_delta( {
            :create_topic => {
              { :medline_tid => 12345 } => {
                :medline_title  => "Armageddon",
                :medline_url    => "http://www.nlm.nih.gov/medlineplus/armageddon.html",
                :synonyms       => ["Apocolypse"],
                :related_groups => [26, 28],
                :related_topics => [],
                :summary_html   => "<p>Coming any day now.</p>",
                :locale         => "en",
                :mesh_titles    => "riders",
                :lang_map       => nil
              },
              { :medline_tid => 12346 } => {
                :medline_title  => "Armageddon",
                :medline_url    => "http://www.nlm.nih.gov/medlineplus/spanish/armageddon.html",
                :synonyms       => ["Apocolypse", "los cuatro jinetes"],
                :related_groups => [26, 28],
                :related_topics => [],
                :summary_html   => "<p>viniendo cualquie día ahora.</p>",
                :locale         => "es",
                :mesh_titles    => "riders",
                :lang_map       => nil
              }
            }
      })

      en_armageddon = MedTopic.search_for("Armageddon")
      en_armageddon.medline_title.should == 'Armageddon'
      en_apocolypse = MedTopic.search_for("Apocolypse")
      en_apocolypse.should eql en_armageddon
      MedTopic.search_for("los cuatro jinetes").should_not eql en_armageddon
      en_armageddon.should_not be_nil
      en_armageddon.locale.should == "en"
      en_armageddon.visible = false
      en_armageddon.save!

      es_armageddon = MedTopic.search_for("Armageddon", "es")
      es_armageddon.should_not be_nil
      es_apocolypse = MedTopic.search_for("Apocolypse", "es")
      es_apocolypse.should eql es_armageddon
      MedTopic.search_for("los cuatro jinetes", "es").should eql es_armageddon
      es_armageddon.should_not be_nil
      es_armageddon.locale.should == "es"
      es_armageddon.visible = false
      es_armageddon.save!

      MedTopic.search_for("Armageddon").should be_nil
    end
  end
end


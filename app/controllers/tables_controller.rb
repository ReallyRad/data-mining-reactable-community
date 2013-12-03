  class TablesController < ApplicationController

  def to_csv
    respond_to do |format|
      format.csv {render text: tables_to_csv}
    end
  end

  def compute_creativity
    Table.all.each do |t|
      #creativity = ((1 - defaults_ratio) + ((max unoriginality - unoriginality)*100/(max unoriginality - min unoriginality))/2
      begin
      t.update_attribute :creativity, (((1-t.defaults_ratio)*100) + ((10849 - t.originality)*100/10701))/2
      rescue
        end
    end
  end

  def tables_to_csv
    columns = ["id", "author", "downloads", "likes", "num_performances", "reuse_count", "originality", "defaults_ratio", "sample_influence", "featured_rank", "ten_original_tables"]
    @tables = Table.all
    CSV.generate do |csv|
      csv << columns + ["timestamp"]
      @tables.each do |table|
        csv << table.attributes.values_at(*columns)+[table.timestamp.to_s.split(' ').first]+[table.competition_entry.to_s]
      end
    end
  end

  def comments_to_csv
    columns = ['id', 'author']
    @comments = Comment.all
    CSV.generate do |csv|
      csv << columns + ["timestamp"]
      @comments.each do |comment|
        csv << comment.attributes.values_at(*columns)+[comment.timestamp.to_s.split(' ').first]
      end
    end
  end

  def set_comments_count
    AuthUser.all.each do |u|
      u.update_attributes :received_comments => u.received_comments, :sent_comments => u.sent_comments
    end
  end

  def tables_by_file_or_title
    not_found = 0
    nokogiri_error = 0
    uploads_path = "/home/polpo/reactable/June11db/uploads/"
    files = p Dir.entries(uploads_path)
    files.each  do |f|
      if f.split(".").last == "rtz"
        zip_file = nil
        table = Table.find_by_reactable_file(f)
        if table
          table.update_attribute :found_by_zip_file, true
          begin
            zip_file = Zip::ZipFile.open uploads_path + f #open it
            (zip_file.nil?)?(table.update_attribute :zip_error, false):(table.update_attribute :zip_error, true) #if successfully opened, set zip_error to false
          rescue #if zip error using file name, remove the "._"
            begin
              zip_file = Zip::ZipFile.open uploads_path + f.split("._").second #open it
              (zip_file.nil?)?(table.update_attribute :zip_error, false):(table.update_attribute :zip_error, true) #if successfully opened, set zip_error to false
            rescue
              table.update_attribute :zip_error, true # if error unzipping, set zip_error to true
            end
          end
        end
        if zip_file
          zip_file.each_entry do |e|
            if e.name.split('.').last == "rtp" #look for rtp file
              begin
                xml = Nokogiri::XML(e.get_input_stream.read) #returns a nokogiri-parsable stream
                Table.find_by_title(xml.xpath("//title").inner_html).update_attribute :found_by_title, true
                Table.find_by_title_and_author((xml.xpath("//title").inner_html), AuthUser.find_by_display_name(xml.xpath("//author").first.inner_html)).update_attribute :found_by_title_and_author, true
              rescue
                nokogiri_error += 1
              end
            end
          end
        end
      end
    end
    dodo="adad"
  end


  def table_descent
    uploads_path = "/home/polpo/reactable/June11db/uploads/"
    not_found = 0
    unzip_errors = 0
    files = p Dir.entries(uploads_path).sort!.map{|f| (f.split("._").second.nil?)?f:f.split('._').second}
    files.each do |f|
      table=nil
      zip_file=nil
      if f.split(".").last == "rtz"
        table = Table.find_by_reactable_file f
        if table
          begin
            zip_file = Zip::ZipFile.open uploads_path + f #open it
            zip_file.each_entry do |e|
              if e.name.split('.').last == "rtp" #look for rtp file
                xml = Nokogiri::XML(e.get_input_stream.read) #returns a nokogiri-parsable stream
                count = 0
                xml.xpath("//author").each do |n|
                  if !(n.inner_html.empty?)
                    count += 1
                  end
                end
                table.update_attribute :reuse_count, count
                #table.update_attribute :authors, xml.xpath("//author").count
              end
            end
          rescue
            unzip_errors += 1 #some error ocurred unzipping a file
          end
        else
          not_found += 1
        end
      end
    end
    table = "oto"
  end

  def table_sample_influence
    defaults = ["chord maya.wav", "kick and clic.wav", "kick and tom.wav", "loop maya 1.wav", "loop maya 2.wav", "phase hats.wav", "rim piks.wav", "synth maya.wav", "quentedrum1.wav", "quentedrum2.wav", "quentelead1.wav", "quentelead2.wav", "A Drums blues 1.wav", "A Drums blues 2.wav", "C Piano blues 1.wav", "C Piano blues 2.wav", "B Bass blues 1.wav", "B Bass blues 2.wav", "D Melo blues 1.wav", "D Melo blues 2.wav"]
    @count = Hash.new
    #initialize the values in the hash
    Table.all.each do |t|
      @count[t.id.to_s.to_sym] = 0
    end

    Table.all.each do |t| #for each table in the database
      t.samples.each do |s| #go through each sample in that table
        unless defaults.include? s.filename
          int = Sample.find_all_by_filename(s.filename) #find all identical samples to this sample
          if int.sort_by{|p| p.table.timestamp}.first == s #if the current sample is the first to be uploaded
            @count[t.id.to_s.to_sym] += int.count - 1 #sample influence of that table gets added the number of times this particular sample was uploaded
          end
        end
      end
    end

    @count.each do |c|
      t = Table.find(c[0])
      t.update_attribute(:sample_influence, c[1])
    end
  end

  def single_table_ascent
    @count = Hash.new
    defaults = ["chord maya.wav", "kick and clic.wav", "kick and tom.wav", "loop maya 1.wav", "loop maya 2.wav", "phase hats.wav", "rim piks.wav", "synth maya.wav", "quentedrum1.wav", "quentedrum2.wav", "quentelead1.wav", "quentelead2.wav", "A Drums blues 1.wav", "A Drums blues 2.wav", "C Piano blues 1.wav", "C Piano blues 2.wav", "B Bass blues 1.wav", "B Bass blues 2.wav", "D Melo blues 1.wav", "D Melo blues 2.wav"]
    #initialize the values in the hash
    Table.all.each do |t|
      @count[t.id.to_s.to_sym] = 0
    end

    Table.all.each do |t| #for each table in the database
      t.samples.each do |s| #go through each sample in that table
          int = Sample.find_all_by_filename(s.filename) #find all identical samples to this sample
          if !(int.sort_by{|p| p.table.timestamp}.first == s) #unless that sample is the first of its kind
            t.update_attribute(:ascent, 1)
          else
            t.update_attribute(:ascent, 0)
          end
        end
    end
  end

  def uploads_per_user
    AuthUser.all.each do |u|
      u.uploads = u.tables.count
      u.save
    end
  end

  def compute_defaults_ratio
    default_settings={:Volume=>6,
                      :Tempo=>3,
                      :Accelerometer=>4,
                      :LFO=>3,
                      :Sequencer=>5,
                      :Delay=>4,
                      :Modulator=>6,
                      :WaveShaper=>3,
                      :Oscillator=>13,
                      :Filter=>1,
                      :Loop=>1,
                      :Input=>1
    }
                      #no sampleplay, no tonalizer, which means

    Table.all.each do |t|
      defaults=0
      params=0
        t.tangibles.each do |ta|
          if !(default_settings[ta.tangible_type.to_s.to_sym]).nil? #if the tangible is part of those studied
            params+=default_settings[ta.tangible_type.to_s.to_sym] #count how many parameters could have been tweaked
            defaults+=ta.defaults #count how many parameters were tweaked
          end
        end

      if params != 0
        t.update_attribute(:defaults_ratio,defaults.to_f/params.to_f)
      end

    end
  end

  def change_tweaked
    default_settings={:Volume=>6,
                      :Tempo=>3,
                      :Accelerometer=>4,
                      :LFO=>3,
                      :Sequencer=>5,
                      :Delay=>4,
                      :Modulator=>6,
                      :WaveShaper=>3,
                      :Oscillator=>13,
                      :Filter=>1,
                      :Loop=>1,
                      :Input=>1
    }

    Tangible.all.each do |t|
      t.update_attribute :tweaked, default_settings[t.tangible_type.to_sym]-t.defaults
    end

  end


  def originality #computes originality


        type_subtype_probability = {
        :Volume_compressor=>34,
        :Volume_reverb=>46,
        :LFO_square=>72,
        :LFO_saw=>73,
        :Input_input=>103,
        :LFO_noise=>125,
        :WaveShaper_resample=>132,
        :Modulator_chorus=>196,
        :Loop_oneshot=>224,
        :Modulator_flanger=>265,
        :Filter_hipass=>280,
        :Delay_reverb=>284,
        :Accelerometer_accelerometer=>288,
        :Filter_bandpass=>329,
        :WaveShaper_compress=>334,
        :Sequencer_random=>360,
        :Tonalizer_tonalizer=>442,
        :Volume_volume=>447,
        :LFO_sine=>565,
        :Delay_pingpong=>588,
        :Modulator_ringmod=>613,
        :WaveShaper_distort=>873,
        :Tempo_tempo=>882,
        :Sampleplay_drum=>987,
        :Sampleplay_synth=>1356,
        :Oscillator_oscillator=>1358,
        :Sequencer_sequencer=>1628,
        :Filter_lowpass=>1673,
        :Sequencer_tenori=>1830,
        :Delay_feedback=>2065,
        :Loop_loop=>10849
    }

=begin
    probability of tenori = 1362 / 21270
    probability of loop = 7996/21270

    overall originality = 1 - probability of tenori + 1 - probability of loop
    = t.tangibles.count*(1-(type_probability[tenori]+type_probability[loop])/21270)
=end

  #total = 21270
    Table.all.each do |t|
      probability = 0.0
      tangibles_count = 0
      t.tangibles.each do |ta|
        if ta.tangible_type == "Oscillator"
          probability += 1358
          tangibles_count +=1
        else
          probability += type_subtype_probability[[ta.tangible_type, ta.subtype].join("_").to_sym]
          tangibles_count +=1
        end
      end
      if probability > 0
        t.update_attribute(:originality, probability/tangibles_count)
      end
    end
  end

  def compute_days_since_upload
    Table.all.each do |t|
      t.update_attribute(:days_since_upload,(t.timestamp.to_date..Date.parse('2013-07-11')).count)
    end
  end

end

  type_probability = {:compressor => 24,
                      :input => 93,
                      :resample => 102,
                      :chorus => 134,
                      :square => 155,
                      :oneshot => 159,
                      :flanger => 186,
                      :noise => 200,
                      :hipass => 207,
                      :accelerometer => 217,
                      :reverb => 248,
                      :compress => 255,
                      :bandpass => 257,
                      :random => 262,
                      :volume => 340,
                      :saw => 374,
                      :pingpong => 453,
                      :ringmod => 455,
                      :distort => 639,
                      :tempo => 660,
                      :drum => 691,
                      :sine => 861,
                      :synth => 967,
                      :sequencer => 1173,
                      :lowpass => 1272,
                      :tenori => 1362,
                      :feedback => 1528,
                      :loop => 7996}

  type_probability = {
      :Input=>103,
      :Accelerometer=>288,
      :Tonalizer=>442,
      :Volume=>527,
      :LFO=>835,
      :Tempo=>882,
      :Modulator=>1074,
      :WaveShaper=>1339,
      :Oscillator=>1358,
      :Filter=>2282,
      :Sampleplay=>2343,
      :Delay=>2937,
      :Sequencer=>3818,
      :Loop=>11073
  }
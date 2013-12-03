require 'tilt/nokogiri'

class SamplesController < ApplicationController

  def remove_duplicates
    Tangible.all.each do |t|
      ta = Tangible.find_all_by_local_and_table_id(t.local, t.table_id)
      if ta.count > 1
        ta.second.destroy
      end
    end
  end

  def original_table #inefficient
    Sample.all.each do |s|
      s.update_attribute(:original_table,Sample.find_all_by_filename(s.filename).sort_by{|p| p.table.timestamp}.first.table)
    end
  end

  def get_samples #stores info on all samples of all tables
    unzip_errors = 0
    uploads_path = "/home/polpo/reactable/ReactableUploads/uploads/"
    files = p Dir.entries(uploads_path).sort!.map{|f| (f.split("._").second.nil?)?f:f.split('._').second}
    files.each do |f|
      if f.split(".").last == "rtz"
        table = nil
        zip_file = nil
        begin
          zip_file = Zip::ZipFile.open uploads_path + f #open it
          table = Table.find_by_reactable_file f
        rescue
        end
        if zip_file && table
          zip_file.each_entry do |e|
            if e.name.split('.').last == "wav" # if entry is wav file
              Sample.create(:filename => e.name.to_s.split('/').last, :md5_hash => e.crc, :table_id => table.id)  #create new sample
            end
          end
        end
      end
    end
    check = "cho"
  end

  def get_tangibles
    uploads_path = "/home/polpo/reactable/June11db/uploads/"
    files = p Dir.entries(uploads_path).sort!.map{|f| (f.split("._").second.nil?)?f:f.split('._').second}
    files.each do |f|
      table = nil
      zip_file = nil
      if f.split(".").last == "rtz"
        begin
          zip_file = Zip::ZipFile.open uploads_path + f #open it
          table = Table.find_by_reactable_file f
        rescue
        end
        if zip_file && table
          zip_file.each_entry do |e|
            if e.name.split('.').last == "rtp" #look for rtp file
              begin
                xml = Nokogiri::XML(e.get_input_stream.read) #returns a nokogiri-parsable stream
                result = xml.xpath("//tangible") #get tangible nodes
                create_tangibles result, table
                break
              rescue
              end
            end
          end
        end
      end
    end
  end

  def create_tangibles (result, table)
    default_settings={:Volume=>{:compression_level=>"0", :reverb_level=>"0", :reverb_input=>"0", :reverb_on=>"0", :delay_fb=>"0", :delay_time=>"0.7"},
                      :Tempo=>{:tempo=>"128", :meter=>"4", :swing=>"0"},
                      :Accelerometer=>{:amp_mult=>"1", :freq_mult=>"1", :freq=>"12", :duration=> "0.75"},
                      :LFO=>{:freq=>"5", :mult=>"0", :samplehold=>"1"},
                      :Sequencer=>{:autoseq_on=>"0", :noteedit_on=>"0", :duration=>"0.75", :num_tracks=>"6", :offset=>"0"},
                      :Delay=>{:delay=>"0.66", :fb=>"0.5", :sweep=>"0"},
                      :Modulator=>{:effect=>"0.5", :drywet=>"0.5", :depth=>"0.5", :min=>"0.5", :fb=>"0.5"},
                      :WaveShaper=>{:effect=>"0.5", :drywet=>"0.5"},
                      :Input=>{:amp=>"0"},
                      :Oscillator=>{:sweep=>"0", :current_osc=>"0", :second_tonalize=>"0", :second_amp1=>"0", :offset1=>"0", :detune1=>"0", :wave1=>"0", :second_amp2=>"0", :offset2=>"0", :detune2=>"0", :wave2=>"0", :bite=>"0"},
    }

    result.each do |r| #for each tangible node, create tangibles and store hardlinks
      node_type = r.xpath('@type').to_s
      locals = String.new
      #hardlinks = Array.new
      if node_type != "Output" && r.xpath('@docked').to_s != '1' #if not an output and not docked
        defaults = 0
        if default_settings.has_key? node_type.to_sym
          default_settings[node_type.to_sym].each do |s|
            if (r.xpath("@"+s[0].to_s).to_s == s[1]) #test whether s corresponds to a default value
              defaults+=1
            end
          end
        end
        defaults = default_envelope r, defaults
        if (Tangible.find_by_local_and_table_id  r.xpath('@id').to_s, table.id).nil?
          t=Tangible.create(:tangible_type => node_type, :subtype => r.xpath('@subtype').to_s, :table_id => table.id, :defaults => defaults, :local => r.xpath('@id').to_s)
        end
        r.xpath("//tangible[@id="+t.local.to_s+"]/*[@to>-1]").each do |h|
          locals+=h.xpath("@to").to_s+","
        end
       # hardlinks[t.id.to_s.to_sym] = locals[0..locals.length-2] unless locals.empty? #gives association between tangible id and locals hardlinked to
        locals.clear
      end
    end
=begin    if !hardlinks.empty?
      hardlinks.each do |h| #find by
        Tangible.find(h[0]).update_attribute :hardlink_to, h[1].split(",").map{|l| Tangible.find_by_local_and_table_id(l, table.id).id}.join(",")
      end
      hardlinks.clear  #clear values for current rtp
    end
=end
  end

  def default_envelope (r, defaults)

    default_envelopes = {
      :default => {:attack=>"0", :decay=>"0", :duration=>"25", :points_x=>"0,0,0,0.2,1", :points_y=>"0,1,1,1,0", :release=>"20"},
      :filter_8 => {:attack=>"0", :decay=>"0", :duration=>"0", :points_x=>"0,0,0,1,1", :points_y=>"0,1,0.5,0.5,0", :release=>"0"},
      :filter_9 => {:attack=>"484.877", :decay=>"469.944",:duration=>"1193", :points_x=>"0,0.406256,0.8,1,1", :points_y=>"0,1,0.5,0.5,0", :release=>"0"},
      :oscillator_47 => {:attack=>"0", :decay=>"500", :duration=>"600", :points_x=>"0,0,0.8,1,1", :points_y=>"0,1,0,0,0", :release=>"0"}
    }

    if ["10", "11", "12", "14", "20", "24", "29", "34", "39", "46"].include? r.xpath("@id").to_s
      default_envelopes[:default].each do |e|
        if (r.xpath("//tangible[@id =" + r.xpath("@id").to_s  + "]/envelope")).xpath("@"+e[0].to_s).to_s != e[1]
          return defaults #if found a value different from defaults, return defaults count unchanged
        end
      end
      return defaults + 1 #if all values are default, increment defaults count by one
    elsif (r.xpath '@id').to_s == "8"
      default_envelopes[:filter_8].each do |e|
        if (r.xpath("//tangible[@id =" + r.xpath("@id").to_s  + "]/envelope")).xpath("@"+e[0].to_s).to_s != e[1]
          return defaults
        end
      end
      return defaults + 1 #if all values are default, increment defaults count by one
    elsif (r.xpath '@id').to_s == "9"
      default_envelopes[:filter_9].each do |e|
        if (r.xpath("//tangible[@id =" + r.xpath("@id").to_s  + "]/envelope")).xpath("@"+e[0].to_s).to_s != e[1]
          return defaults
        end
      end
      return defaults + 1 #if all values are default, increment defaults count by one
    elsif (r.xpath '@id').to_s == "47"
      default_envelopes[:oscillator_47].each do |e|
        if (r.xpath("//tangible[@id =" + r.xpath("@id").to_s  + "]/envelope")).xpath("@"+e[0].to_s).to_s != e[1]
          return defaults
        end
      end
    return defaults + 1 #if all values are default, increment defaults count by one
    else #if object none of those with envelope settings, return defaults count as is
      return defaults
    end
  end

  def multiple_hardlinks
    Table.all.each do |t|
      t.tangibles.each do |ta|
        if ta.hardlink_to
          (ta.hardlink_to.split(",").count > 1)?(t.update_attribute :multiple_hardlinks, true):(t.update_attribute :multiple_hardlinks, false)
        end
      end
    end
  end

  def compute_connection_types
    processors = %w(Delay Filter Modulator WaveShaper)
    Tangible.all.each do |t|
      if t.hardlink_to
        t.hardlink_to.split(",").each do |id|
          l=Link.create(:link_from => t.tangible_type+"-"+t.subtype, :link_to => Tangible.find(id.to_i).tangible_type+"-"+Tangible.find(id.to_i).subtype, :table_id => t.table_id)
          if (processors.include? l.link_from) && (processors.include? l.link_to) && (processors.index(l.link_from) > processors.index(l.link_to)) #if objects linked are processors, and not connected in alphabetic order
            l.update_attributes :link_from => l.link_to, :link_to => l.link_from
          end
        end

      end
    end
  end

  def set_original_connections
    original_connections = {:Sequencer => ["Modulator", "Input"], :LFO => ["SamplePlay", "Modulator", "WaveShaper"], :Oscillator => ["WaveShaper", "Modulator"], :Filter => ["Modulator", "Filter"], :Modulator => ["WaveShaper"], :Accelerometer => ["Loop", "Sampleplay", "Delay", "Oscillator", "Filter", "WaveShaper"], :Delay => ["Delay"], :Input => ["WaveShaper", "Modulator", "Filter"]}
    Table.all.each do |t|
      t.links.each do |l|
        if (original_connections[l.link_from.to_sym]) && (original_connections[l.link_from.to_sym].include? l.link_to)
          Table.find(l.table_id).update_attribute :twenty_original_connections, true
        else
          Table.find(l.table_id).update_attribute :twenty_original_connections, false
        end
      end
    end
  end

  def ten_original_objects
    Tangible.all.each do |t|
      if ["Volume_compressor","Volume_reverb","LFO_square=","LFO_saw","Input_input","LFO_noise","WaveShaper_resample",'Modulator_chorus','Loop_oneshot','Modulator_flanger'].include? [t.tangible_type,t.subtype].join("_")
       t.table.update_attribute :ten_original_objects, true
      end
    end
  end

  def non_original
    Tangible.all.each do |t|
      if !([:WaveShaper_distort, :Tempo_tempo, :Sampleplay_drum, :Sampleplay_synth, :Oscillator_oscillator, :Sequencer_sequencer, :Filter_lowpass, :Sequencer_tenori, :Delay_feedback, :Loop_loop].include? [t.tangible_type,t.subtype].join("_").to_sym ) #if object not one of the 10 least originals,
        t.table.update_attribute :non_original, false
      end
    end
  end

  #those that have nothing outside the ten most common, and those that have at least 1 of the 10 most originals

=begin
| Sequencer     | Modulator  |       37 |          /
| LFO           | Sampleplay |       36 |          /
| LFO           | Modulator  |       34 |          /
| Filter        | Modulator  |       32 |           /
| Modulator     | WaveShaper |       30 |         /
| LFO           | WaveShaper |       27 |          /
| Oscillator    | WaveShaper |       23 |          /
| Accelerometer | Loop       |       21 |         /
| Oscillator    | Modulator  |       20 |         /
| Accelerometer | Sampleplay |       17 |       /
| Accelerometer | Delay      |       16 |        /
| Delay         | Delay      |       15 |         /
| Accelerometer | Oscillator |       15 |       /
| Accelerometer | Filter     |        6 |        /
| Filter        | Filter     |        4 |            /
| Accelerometer | WaveShaper |        3 |          /
| Input         | Modulator  |        2 |
| Input         | WaveShaper |        2 |
| Sequencer     | Input      |        2 |            /
| Input         | Filter     |        1 |           /
+---------------+------------+----------+
=end

#connections between processors can be inverted, so will always be put in alphabetic order

=begin
generators  = %w(Oscillator, Input, SamplePlay, Loop)
controllers =  %w(LFO, Accelerometer, Sequencer)
processors = %w(Filter, Delay, WaveShaper, Modulator)
standalone = %w(Tonalizer, Tempo)
=end

#filter 8
#<envelope attack="0" decay="0" duration="0" points_x="0,0,0,1,1" points_y="0,1,0.5,0.5,0" release="0" />
#filter 9
#<envelope attack="484.877" decay="469.944" duration="1193" points_x="0,0.406256,0.8,1,1" points_y="0,1,0.5,0.5,0" release="0"
#Delay, Modulator, WaveShaper, input, loop, oscillator 46
#10 11 12 14 20 24 29 34 39 46
#<envelope attack="0" decay="0" duration="25" points_x="0,0,0,0.2,1" points_y="0,1,1,1,0" release="20" />
#oscillator 47
#<envelope attack="0" decay="500" duration="600" points_x="0,0,0.8,1,1" points_y="0,1,0,0,0" release="0" />

=begin
  def get_tangibles

    default_settings={:Volume=>{:compression_level=>"0", :reverb_level=>"0", :reverb_input=>"0", :reverb_on=>"0", :delay_fb=>"0", :delay_time=>"0.7"},
                      :Tempo=>{:tempo=>"128", :meter=>"4", :swing=>"0"},
                      :Accelerometer=>{:amp_mult=>"1", :freq_mult=>"1", :freq=>"12", :duration=> "0.75"},
                      :LFO=>{:freq=>"5", :mult=>"0", :samplehold=>"1"},
                      :Sequencer=>{:autoseq_on=>"0", :noteedit_on=>"0", :duration=>"0.75", :num_tracks=>"6", :offset=>"0"},
                      :Delay=>{:delay=>"0.66", :fb=>"0.5", :sweep=>"0"},
                      :Modulator=>{:effect=>"0.5", :drywet=>"0.5", :depth=>"0.5", :min=>"0.5", :fb=>"0.5"},
                      :WaveShaper=>{:effect=>"0.5", :drywet=>"0.5"},
                      :Input=>{:amp=>"0"},
                      :Oscillator=>{:sweep=>"0", :current_osc=>"0", :second_tonalize=>"0", :second_amp1=>"0", :offset1=>"0", :detune1=>"0", :wave1=>"0", :second_amp2=>"0", :offset2=>"0", :detune2=>"0", :wave2=>"0", :bite=>"0"},
    }

    table = Table.new
    locals = String.new
    hardlinks = Hash.new

    uploads_path = "/home/polpo/reactable/June11db/uploads/"
    files = p Dir.entries(uploads_path).sort!.map{|f| (f.split("._").second.nil?)?f:f.split('._').second}
    files.each do |f|
      if f.split(".").last == "rtz"
        begin
          zip_file = Zip::ZipFile.open uploads_path + f #open it
          table = Table.find_by_reactable_file f
        rescue #if zip error using file name, remove the "._"

        end
        if zip_file && table
          zip_file.each_entry do |e|
            if e.name.split('.').last == "rtp" #look for rtp file
              begin
                xml = Nokogiri::XML(e.get_input_stream.read) #returns a nokogiri-parsable stream
                result = xml.xpath("//tangible") #get tangible nodes

                result.each do |r| #for each tangible node, create tangibles and store hardlinks

                  node_type = r.xpath('@type').to_s
                  if node_type != "Output" && r.xpath('@docked').to_s != '1' #if not an output and not docked
                    defaults = 0
                    if default_settings.has_key? node_type.to_sym
                      default_settings[node_type.to_sym].each do |s|
                        if (r.xpath("@"+s[0].to_s).to_s == s[1]) #test whether s corresponds to a default value
                          defaults+=1
                        end
                      end
                    end
                    defaults = default_envelope r, defaults
                    t=Tangible.create(:tangible_type => node_type, :subtype => r.xpath('@subtype').to_s, :table_id => table.id, :defaults => defaults, :local => r.xpath('@id').to_s)
                    r.xpath("//tangible[@id="+t.local.to_s+"]/*[@to>-1]").each do |h|
                      locals+=h.xpath("@to").to_s+","
                    end
                    hardlinks[t.id.to_s.to_sym] = locals[0..locals.length-2] unless locals.empty? #gives association between tangible id and locals hardlinked to
                    locals.clear
                  end
                end
                if !hardlinks.empty?
                  hardlinks.each do |h| #find by
                    Tangible.find(h[0]).update_attribute :hardlink_to, h[1].split(",").map{|l| Tangible.find_by_local_and_table_id(l, table.id).id}.join(",")
                  end
                  hardlinks.clear  #clear values for current rtp
                end
              rescue
              end
            end
            zip_file = nil
            table = nil
          end
        else
          aha= "ohoh"
        end
      end
    end
    dodo="dkal"
  end
=end
end

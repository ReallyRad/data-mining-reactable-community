Reactable::Application.routes.draw do

  match "/get_samples" => 'samples#get_samples'
  match "/get_tangibles" => 'samples#get_tangibles'
  match "/set_table_sample_influence" => 'tables#table_sample_influence'
  match "/tables_statistics" => 'tables#to_csv'
  match "/comments_statistics" => 'tables#to_csv'
  match "/count_table_descent" => 'tables#table_descent'
  match "/found_tables" => 'tables#tables_by_file_or_title'

  match "/table_originality" => 'tables#originality' #computes originality
  match "/days_since_upload" => 'tables#compute_days_since_upload'
  match "/tables_defaults" => 'tables#compute_defaults_ratio'
  match "/original_table" => 'samples#original_table'
  match "/single_descendence" => 'tables#single_table_descendence'
  match "/creative_tables" => 'tables#most_creative'
  match "/user_uploads" => "tables#uploads_per_user"
  match "/comments_count" => "tables#set_comments_count"
  match "/single_table_ascent" => "tables#single_table_ascent"

  match "/count_hardlinks" => "samples#multiple_hardlinks"
  match "/compute_connection_types" => "samples#compute_connection_types"
  match "/set_original_connections" => "samples#set_original_connections"

  match "/ten_original_objects" => "samples#ten_original_objects"
  match "/non_original" => "samples#non_original"
  match "/remove_duplicates" => "samples#remove_duplicates"

  match "/creativity" => "tables#compute_creativity"
end

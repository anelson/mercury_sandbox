require 'set'
require 'app\helpers\normalizer'
require 'app\helpers\match_scorer'
require 'app\helpers\score_aggregator'

require 'rubygems'
require_gem 'sqlite3-ruby'

class CatalogItem
  attr_reader :title, :id, :path, :normalized_title, :rank, :scores
  attr_writer :rank, :scores

  def initialize(row)
    @title = row[1]
    @id = row[0]
    @path = row[2]
    @normalized_title = Normalizer.normalize(@title)
    @rank = 0
    @scores = []
  end
end

def get_all_rows(db)
  #Build a regex from the cannonicalized search
  all_rows = db.execute("select id,title,path from items")

  db_objects = []

  all_rows.each do |row|
    o = CatalogItem.new(row)
    db_objects << o
  end

  return db_objects
end

$re = nil

def search_all_rows(all_rows, search)
  #Build a regex from the cannonicalized search

  regex = ""
  search.scan(/./) do |char|
    regex << char << ".*"
  end

  regex.chomp!(".*")

  $re = Regexp.compile(regex)

  matches = []

  all_rows.each do |row|
    if $re.match(row.normalized_title) != nil
      matches << row
    end
  end
  
  return matches
end

def score_and_sort_rows(rows, search)
  row_scores = []
  row_score = []
  rows.each do |row|
    row_scores << MatchScorer.score(search, row.normalized_title)
  end

  row_ranks = Ranker.rank_by_score(row_scores)

  rows.each_with_index do |row, index|
    row.scores = [row_scores[index]]
    row.rank = row_ranks[index]
  end

  # Sort ascending by rank (
  rows.sort! do |row1, row2|
    row1.rank <=> row2.rank
  end
end

db = SQLite3::Database.new("catalog.db")

#db.trace() { |data, sql| 
#    puts "/* sql run at #{Time.now} */"
#    puts sql
#    puts
#}

db.execute("pragma temp_store = memory;")

puts "Fetching all database rows..."

all_rows = get_all_rows(db)

while true
    print "Search Term> "
    search = gets

    break if search =~ /^$/

    puts "Searching with regex on all rows"
    startTime = Time.now
    matching_rows = search_all_rows(all_rows, Normalizer.normalize(search))
    endTime = Time.now

    totalTime = endTime.to_f - startTime.to_f;

    printf "#{matching_rows.length} item(s) matched in %.2f seconds\n", totalTime

    puts "Scoring matched records"
    startTime = Time.now
    score_and_sort_rows(matching_rows, Normalizer.normalize(search))
    endTime = Time.now

    totalTime = endTime.to_f - startTime.to_f;

    matching_rows[0,100].each do |row|
      #printf "#{row.title} (Score: %.2f)\n", row.score
      print "#{row.title} (Rank: #{row.rank}, "
      print "Scores: #{row.scores.join(',')}"
      puts ")"      
    end

    printf "#{matching_rows.length} item(s) scored in %.2f seconds\n", totalTime
end



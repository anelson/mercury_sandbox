require 'set'
require 'app\helpers\normalizer'
require 'app\helpers\match_scorer'
require 'app\helpers\score_aggregator'

require 'rubygems'
require_gem 'sqlite3-ruby'
require_gem 'neuro'

NUM_SCORING_ALGORITHMS = 3

class CatalogItem
  attr_reader :title, :id, :path, :normalized_title, :rank, :scores, :score
  attr_writer :rank, :scores, :score

  def initialize(row)
    @title = row[1]
    @id = row[0]
    @path = row[2]
    @normalized_title = Normalizer.normalize(@title)
    @rank = 0
    @score = 0
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

def score_and_sort_rows(rows, search, ann)
  row_scores = []
  row_score = []
  rows.each do |row|
    row_scores << MatchScorer.score(search, row.normalized_title)
    row_score << ann.decide(MatchScorer.score(search, row.normalized_title))[0]
  end

  #row_ranks = ScoreAggregator.rank_and_order_by_aggregate_score(row_scores)
  row_ranks = Ranker.rank_by_score(row_score)

  rows.each_with_index do |row, index|
    row.scores = row_scores[index]
    row.rank = row_ranks[index]
    row.score = row_score[index]
  end

  #puts "Ranks: #{row_ranks.join(',')}"
  #puts "Scores: #{row_scores.join(',')}"

  # Sort ascending by rank (
  rows.sort! do |row1, row2|
    row1.rank <=> row2.rank
  end
end

def train_ann(ann, rows)
  training_data = {
    "nic" => "neoIndustrial Corporation",
    "test" => "test",
    "nullp" => "NullPointer",
    "favs" => "Favorites",
    "i7000vid" => "Dell Inspiron 7000 Video Driver vM6.00.4-T01",
    "mmjb" => "MusicMatch Jukebox 4",
    "acroread" => "Acrobat Reader 4.0",
    "jk" => "Jedi Knight",
    "tl" => "TerrainLab",
    "dbcg" => "DBCodeGen"
  }

  errors = 1

  while errors > 0
    errors = 0
    training_data.each_key do |search|
      norm_search = Normalizer.normalize(search)
      norm_title = Normalizer.normalize(training_data[search])

      puts "Training #{norm_search} = #{norm_title}"

      matching_rows = search_all_rows(rows, norm_search)
      score_and_sort_rows(matching_rows, norm_search, ann)

      idx = 0
      while idx < matching_rows.length && matching_rows[idx].normalized_title != norm_title
        puts "Training on #{matching_rows[idx].normalized_title}"
        ann.learn(matching_rows[idx].scores, [0.0], 0.1, 0.3)
        idx += 1
        errors += 1
      end

      if idx >= matching_rows.length
        raise
      end

      if idx > 0
        ann.learn(matching_rows[idx].scores, [1], 0.1, 0.3)
      end
    end
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

puts "Training the neural network..."

ann = Neuro::Network.new(NUM_SCORING_ALGORITHMS, 2, 1)
train_ann(ann, all_rows)

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
    score_and_sort_rows(matching_rows, Normalizer.normalize(search), ann)
    endTime = Time.now

    totalTime = endTime.to_f - startTime.to_f;

    matching_rows[0,100].each do |row|
      #printf "#{row.title} (Score: %.2f)\n", row.score
      print "#{row.title} (Rank: #{row.rank}, "
      print "Scores: #{row.scores.join(',')}"
      print ", ANN score: #{row.score}"
      puts ")"      
    end

    printf "#{matching_rows.length} item(s) scored in %.2f seconds\n", totalTime
end



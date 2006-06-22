require 'rubygems'
require_gem 'sqlite3-ruby'

def search_catalog(db, search)
    canon_search = canonicalize_search(search)

    level = -1
    item_rows = nil

    db.transaction do |db|
        canon_search.scan(/./) do |char|
            level += 1
            execute_search_level(db, level, char)
        end
    
        item_rows = find_matching_items(db, level)
    end
    
    return item_rows
end

def execute_search_level(db, level, char)
    db.execute("create temp table search#{level} (title_char_id integer primary key not null)")

    search_sql = "insert into search#{level} (title_char_id) "

    if level == 0
        # Populate where ancestor id is null
        search_sql << "
            select distinct tc.id 
            from 
                title_char_ancestors tca 
                inner join
                title_chars tc
                on
                    tc.id = tca.title_char_node_id 
            where 
                tca.ancestor_title_char_node_id is null
                and
                tc.character = :char
            "
    else 
        #Populate where the ancestor is in the previous search table
        search_sql << "
            select distinct tc.id 
            from 
                search#{level-1} s
                
                inner join
                title_char_ancestors tca
                on
                    tca.ancestor_title_char_node_id = s.title_char_id

                inner join
                title_chars tc
                on
                    tc.id = tca.title_char_node_id
            where 
                tc.character = :char
            "
    end

    db.execute(search_sql, 
        ":char" => char)
end

def find_matching_items(db, level)
    sql = "select distinct i.id, i.title, i.path 
        from
            search#{level} s#{level}
            inner join
            item_title_chars itc
            on
                s#{level}.title_char_id = itc.title_char_id
            
            inner join
            items i
            on
                itc.item_id = i.id
            "

    rows = db.execute(sql)

    # clean up the temp tables
    level.step(0, -1) do |i|
        db.execute("drop table search#{i}")
    end

    return rows
end

def canonicalize_search(search)
    return search.downcase
end


db = SQLite3::Database.new("catalog.db")

#
db.trace() { |data, sql| 
    puts "/* sql run at #{Time.now} */"
    puts sql
    puts
}

db.execute("pragma temp_store = memory;")

while true
    print "Search Term> "
    search = gets

    break if search =~ /^$/
    
    matching_rows = search_catalog(db, search)

    matching_rows.each do |row| 
        # puts "#{row[1]} (#{row[0]}) at #{row[2]}"
    end

    puts "#{matching_rows.length} item(s) matched"
end

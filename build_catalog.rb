require 'rubygems'
require_gem 'sqlite3-ruby'


def process_dir(db, path, parent_id) 
    dir_id = create_entry(db, path, parent_id);
    
    puts "#{path} (#{dir_id})"

    #db.transaction do |db|
        Dir.foreach(path) do |name| 
            full_path = File.join(path, name)
            
            next if File.directory?(full_path)
            
            create_entry(db, full_path, dir_id)
        end
    #end

    Dir.foreach(path) do |name| 
        full_path = File.join(path, name)
        
        next unless File.directory?(full_path) && name != "." && name != ".."
        
        process_dir(db, full_path, dir_id)
    end
    
end


def create_entry(db, path, parent_id)
    title = File.basename(path, ".*")

    db.execute("insert into items (parent_item_id, path, title) values (:parent, :path, :title)",
                ":parent" => parent_id,
                ":path" => path,
                ":title" => title)

    id = db.last_insert_row_id

    canon_title = canonicalize_title(title)

    build_char_nodes(db, id, canon_title)

    return id
end

def canonicalize_title(title)
    return title.downcase
end

def build_char_nodes(db, item_id, canon_title)
    ancestor_stack = Array.new()

    ancestor_stack << nil
    
    canon_title.scan(/./) do |char|
        title_char_id = create_title_char(db, char, ancestor_stack.last)
        
        ancestor_stack.each do |ancestor_char_id|
            create_title_char_ancestor(db, title_char_id, ancestor_char_id)
        end

        ancestor_stack << title_char_id

        associate_title_char_with_item(db, title_char_id, item_id)
    end
end

$title_char_cache = {}

def create_title_char(db, char, parent_title_char_id)
    id = nil

    id = $title_char_cache[parent_title_char_id.to_s + char.to_s]

    if id == nil
        if parent_title_char_id != nil
            id = db.get_first_value("select id from title_chars where parent_title_char_id = :parent and character = :char",
                    ":char" => char,
                    ":parent" => parent_title_char_id)
        else
            id = db.get_first_value("select id from title_chars where parent_title_char_id is null and character = :char",
                    ":char" => char)
        end

        $title_char_cache[parent_title_char_id.to_s + char.to_s] = id
        
        if id == nil
            db.execute("insert into title_chars(character, parent_title_char_id) values (:char, :parent)",
                ":char" => char,
                ":parent" => parent_title_char_id)

            id = db.last_insert_row_id

            $title_char_cache[parent_title_char_id.to_s + char.to_s] = id
        end
    end

    return id
end

def create_title_char_ancestor(db, title_char_id, ancestor_title_char_id)
    db.execute("insert or replace into title_char_ancestors(title_char_node_id, ancestor_title_char_node_id) values (:id, :ancestor_id)",
        ":id" => title_char_id,
        ":ancestor_id" => ancestor_title_char_id)
end

def associate_title_char_with_item(db, title_char_id, item_id)
    db.execute("insert into item_title_chars(item_id, title_char_id) values (:id, :char_id)",
        ":id" => item_id,
        ":char_id" => title_char_id)
end

File.delete("catalog.db") if File.exist?("catalog.db")
db = SQLite3::Database.new("catalog.db")
db.execute_batch(IO.read("schema.sql"))

catalog_path = "g:\\docs\\archive\\files from aragorn"

db.transaction do |db|
    process_dir(db, catalog_path, nil)
end



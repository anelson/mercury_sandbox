class CreateTitleCharAncestors < ActiveRecord::Migration
  def self.up

    say_with_time "Creating title_char_ancestors table..." do 
      execute %{
        create table title_char_ancestors (
          title_char_id integer not null,
      
          /* for performance reasons, the character of title_char_id is also stored here */
          title_char_character string not null,
      
          ancestor_title_char_id integer null/* ,

          moved compound primary key to explicit unique index to deal with rails limitation
          primary key (ancestor_title_char_id, title_char_character, title_char_id) */
        );

        /* for performance reasons, the ancestor id is first and the character of the
        title char is included in the pkey */
        create unique index idx_title_char_ancestors on title_char_ancestors(ancestor_title_char_id, title_char_character, title_char_id);
      }
    end

    say_with_time "Creating index on title_char_ancestors..." do 
      execute %{
        /* an index to support the insert trigger above that automatically populates the ancestors table */
        create index idx_title_char_ancestors_tci on title_char_ancestors(title_char_id)
      }
    end

    say_with_time "Creating triggers to populate title_char_ancestors..." do
      execute %{
        /* trigger to populate the title_char_ancestors table on changes to title_chars */
        create trigger trg_title_chars_ai after insert on title_chars
        begin
          /* Insert a record for the character's immediate parent */
          insert into title_char_ancestors(
            title_char_id, 
            title_char_character,
            ancestor_title_char_id)
          values (
            NEW.id,
            NEW.character,
            NEW.parent_title_char_id);
  
          /* and copy the immediate parent's ancestors over as well */
          insert into title_char_ancestors(
            title_char_id, 
            title_char_character,
            ancestor_title_char_id)
          select
            NEW.id,
            NEW.character,
            tca.ancestor_title_char_id
          from
            title_char_ancestors tca
            where
            tca.title_char_id = NEW.parent_title_char_id;
        end;
  
        /*
        create trigger trg_title_chars_au after update on title_chars
        begin
          RAISE(ABORT, 'Title char ancestors maintenance triggers do not support updates yet');
        end;
        */
  
        create trigger trg_title_chars_ad after delete on title_chars
        begin
          delete from title_char_ancestors where ancestor_title_char_id = OLD.title_char_id;
        end;
      }
    end
  end

  def self.down
    drop_table :title_char_ancestors
    execute %{drop trigger trg_title_chars_ai}
    execute %{drop trigger trg_title_chars_ad}
  end
end


/* test db schema */
pragma default_cache_size = 10000;
pragma synchronous = normal;

create table items (
	id integer primary key autoincrement not null,
	parent_item_id integer null,
	path string not null,
	title string not null
);

create table title_chars (
	id integer primary key autoincrement not null,
	character string not null,
	parent_title_char_id integer null,

	/* for performance reasons, the parent ID is first */
	unique (parent_title_char_id, character)
);

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

create table title_char_ancestors (
	title_char_id integer not null,

	/* for performance reasons, the character of title_char_id is also stored here */
	title_char_character string not null,
	
	ancestor_title_char_id integer null,

	/* for performance reasons, the ancestor id is first and the character of the
	title char is included in the pkey */
	primary key (ancestor_title_char_id, title_char_character, title_char_id)
);

/* an index to support the insert trigger above that automatically populates the ancestors table */
create index idx_title_char_ancestors_tci on title_char_ancestors(title_char_id);

create table item_title_chars (
	item_id integer not null,
	title_char_id integer not null,
	primary key (title_char_id, item_id)
);


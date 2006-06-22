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
	unique (parent_title_char_id, character)
);

create table title_char_ancestors (
	title_char_node_id integer not null,
	ancestor_title_char_node_id integer null,
	/* primary key (title_char_node_id, ancestor_title_char_node_id) */
	primary key (ancestor_title_char_node_id, title_char_node_id)
);

create table item_title_chars (
	item_id integer not null,
	title_char_id integer not null,
	/*primary key (title_char_id, item_id)*/
	primary key (title_char_id, item_id)
);


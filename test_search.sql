/* sql */
pragma temp_store = memory;

/* sql */
begin deferred transaction

/* sql */
create temp table search0 (title_char_id integer primary key not null)

/* sql */
insert into search0 (title_char_id)
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
                tc.character = 't'


/* sql */
create temp table search1 (title_char_id integer primary key not null)

/* sql */
insert into search1 (title_char_id)
            select distinct tc.id
            from
                search0 s

                inner join
                title_char_ancestors tca
                on
                    tca.ancestor_title_char_node_id = s.title_char_id

                inner join
                title_chars tc
                on
                    tc.id = tca.title_char_node_id
            where
                tc.character = 'e'




# frozen_string_literal: true

require 'pg'

# Output a table of current connections to the DB
conn = PG.connect( dbname: 'sinatra' )
# conn.exec( "SELECT * FROM todos" ) do |result|
#   result.each do |tuple|
#     puts tuple['id']
#     puts tuple['title']
#   end
# end

# conn.exec("insert into todos values (NULL, 'insert_test2', 'piyo');")
conn.exec("insert into todos (title, body) values ('Kudou', 'Kyoto');")

# conn.exec("delete from todos where title='Kudou';")

conn.exec("UPDATE todos SET title = 'update_title', body = 'update_body' WHERE id = 1;")

conn.exec( "SELECT * FROM todos" ) do |result|
  result.each do |tuple|
    puts tuple['id']
    puts tuple['title']
  end
end

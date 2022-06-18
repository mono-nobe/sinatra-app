# frozen_string_literal: true

require 'json'
require 'pg'
require 'sinatra'
require 'sinatra/reloader'

get '/todos' do
  connection = connect_db
  todos = select_all_records(connection)

  todos.map do |todo|
    todo['title'] = escape_html(todo['title']).force_encoding('UTF-8')
    todo['body'] = escape_html(todo['body']).force_encoding('UTF-8')
  end

  @todos = todos
  erb :todos
end

get '/todos/creator' do
  erb :create
end

post '/todos' do
  connection = connect_db

  todo = {
    'title' => params[:title],
    'body' => params[:body]
  }
  create_record(connection, todo)

  redirect to('/todos')
end

get '/todos/:id' do
  connection = connect_db
  todo = select_record(connection, params['id'])

  todo['title'] = escape_html(todo['title']).force_encoding('UTF-8')
  todo['body'] = escape_html(todo['body']).force_encoding('UTF-8')

  @todo = todo
  erb :detail
end

get '/todos/:id/editor' do
  connection = connect_db
  todo = select_record(connection, params['id'])
  todo['title'] = escape_html(todo['title']).force_encoding('UTF-8')
  todo['body'] = escape_html(todo['body']).force_encoding('UTF-8')

  @todo = todo
  erb :edit
end

patch '/todos/:id' do
  connection = connect_db

  todo = {
    'id' => params['id'],
    'title' => params[:title],
    'body' => params[:body]
  }
  update_record(connection, todo)

  redirect to('/todos')
end

delete '/todos/:id' do
  connection = connect_db
  delete_record(connection, params['id'])

  redirect to('/todos')
end

def escape_html(text)
  Rack::Utils.escape_html(text)
end

def connect_db
  PG.connect(dbname: 'sinatra')
end

def select_all_records(connection)
  results = []

  connection.exec('SELECT * FROM todos;') do |records|
    results = records.to_a
  end

  results
end

def select_record(connection, id)
  result = {}

  connection.exec('SELECT * FROM todos WHERE id = $1;', [id]) do |records|
    result = records.to_a[0]
  end

  result
end

def create_record(connection, todo)
  connection.exec(
    'INSERT INTO todos (title, body) VALUES ($1, $2);',
    [
      todo['title'],
      todo['body']
    ]
  )
end

def update_record(connection, todo)
  connection.exec(
    'UPDATE todos SET title = $1, body = $2 WHERE id = $3;',
    [
      todo['title'],
      todo['body'],
      todo['id']
    ]
  )
end

def delete_record(connection, id)
  connection.exec('DELETE FROM todos WHERE id=$1;', [id])
end

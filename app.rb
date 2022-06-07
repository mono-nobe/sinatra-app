# frozen_string_literal: true

require 'json'
require 'pg'
require 'sinatra'
require 'sinatra/reloader'

get '/todos' do
  connect = connect_db
  todos = select_all_record(connect)

  todos.map do |todo|
    todo['title'] = escape_html(todo['title'])
    todo['body'] = escape_html(todo['body'])
  end

  @todos = JSON.parse(todos.to_json)
  erb :todos
end

get '/todos/creator' do
  erb :create
end

post '/todos' do
  connect = connect_db

  todo = {
    'title' => params[:title],
    'body' => params[:body]
  }
  create_record(connect, todo)

  redirect to('/todos')
end

get '/todos/:id' do
  connect = connect_db
  selected_todo = select_record(connect, params['id'])

  selected_todo['title'] = escape_html(selected_todo['title'])
  selected_todo['body'] = escape_html(selected_todo['body'])

  @todo = JSON.parse(selected_todo.to_json)
  erb :detail
end

get '/todos/:id/editor' do
  connect = connect_db
  selected_todo = select_record(connect, params['id'])
  selected_todo['title'] = escape_html(selected_todo['title'])
  selected_todo['body'] = escape_html(selected_todo['body'])

  @todo = JSON.parse(selected_todo.to_json)
  erb :edit
end

patch '/todos/:id' do
  connect = connect_db

  todo = {
    'id' => params['id'],
    'title' => params[:title],
    'body' => params[:body]
  }
  update_record(connect, todo)

  redirect to('/todos')
end

delete '/todos/:id' do
  connect = connect_db
  delete_record(connect, params['id'])

  redirect to('/todos')
end

def escape_html(text)
  Rack::Utils.escape_html(text)
end

def db_json
  JSON.parse(File.read('todos.json'))
end

def connect_db
  PG.connect(dbname: 'sinatra')
end

def select_all_record(connect)
  results = []

  connect.exec('SELECT * FROM todos;') do |records|
    records.each do |record|
      results.push(record)
    end
  end

  results
end

def select_record(connect, id)
  result = {}
  connect.exec('SELECT * FROM todos WHERE id = $1', [id]) do |records|
    records.each do |record|
      result = record
    end
  end

  result
end

def create_record(connect, todo)
  connect.exec(
    'INSERT INTO todos (title, body) VALUES ($1, $2);',
    [
      todo['title'],
      todo['body']
    ]
  )
end

def update_record(connect, todo)
  connect.exec(
    'UPDATE todos SET title = $1, body = $2 WHERE id = $3;',
    [
      todo['title'],
      todo['body'],
      todo['id']
    ]
  )
end

def delete_record(connect, id)
  connect.exec('DELETE FROM todos WHERE id=$1;', [id])
end

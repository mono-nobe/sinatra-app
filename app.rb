# frozen_string_literal: true

require 'json'
require 'sinatra'
require 'sinatra/reloader'

get '/todos' do
  json = db_json

  json['todos'].map do |todo|
    todo['title'] = escape_html(todo['title'])
    todo['body'] = escape_html(todo['body'])
  end

  @todos = json['todos']
  erb :todos
end

get '/todos/create' do
  erb :create
end

post '/todos' do
  json = db_json

  max_id = json['todos'].map do |todo|
    todo['id'].to_i
  end.max

  new_todo = {
    id: max_id.nil? ? 1 : max_id + 1,
    title: params[:title],
    body: params[:body]
  }

  json['todos'].push(new_todo)
  File.open('todos.json', 'w') do |file|
    JSON.dump(json, file)
  end

  redirect to('/todos')
end

get '/todos/:id' do
  json = db_json

  selected_todo = json['todos'].find { |todo| todo['id'] == params['id'].to_i }
  selected_todo['title'] = escape_html(selected_todo['title'])
  selected_todo['body'] = escape_html(selected_todo['body'])

  @todo = selected_todo
  erb :detail
end

get '/todos/:id/edit' do
  json = db_json

  selected_todo = json['todos'].find { |todo| todo['id'] == params['id'].to_i }
  selected_todo['title'] = escape_html(selected_todo['title'])
  selected_todo['body'] = escape_html(selected_todo['body'])

  @todo = selected_todo
  erb :edit
end

patch '/todos/:id' do
  json = db_json

  selected_todo = json['todos'].find { |todo| todo['id'] == params['id'].to_i }
  selected_todo['title'] = params[:title]
  selected_todo['body'] = params[:body]

  File.open('todos.json', 'w') do |file|
    JSON.dump(json, file)
  end

  redirect to('/todos')
end

delete '/todos/:id' do
  json = db_json

  json['todos'].delete_if { |todo| todo['id'] == params['id'].to_i }

  File.open('todos.json', 'w') do |file|
    JSON.dump(json, file)
  end

  redirect to('/todos')
end

def escape_html(text)
  Rack::Utils.escape_html(text)
end

def db_json
  json_string = File.read('todos.json') do |file|
    file
  end

  JSON.parse(json_string)
end

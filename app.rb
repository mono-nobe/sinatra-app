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

  @params = json['todos']
  erb :todos
end

get '/create' do
  erb :create
end

post '/create' do
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

  redirect to('/todos'), 303
end

get '/detail/:id' do
  json = db_json

  detail = {}
  json['todos'].map do |todo|
    next unless todo['id'] == params['id'].to_i

    todo['title'] = escape_html(todo['title'])
    todo['body'] = escape_html(todo['body'])
    detail = todo
  end

  @params = detail
  erb :detail
end

get '/edit/:id' do
  json = db_json

  detail = {}
  json['todos'].map do |todo|
    detail = todo if todo['id'] == params['id'].to_i
  end

  @params = detail
  erb :edit
end

patch '/edit' do
  json = db_json

  json['todos'].map do |todo|
    if todo['id'] == params[:id].to_i
      todo['title'] = params[:title]
      todo['body'] = params[:body]
    end
  end

  File.open('todos.json', 'w') do |file|
    JSON.dump(json, file)
  end

  redirect to('/todos'), 303
end

delete '/delete' do
  json = db_json

  json['todos'].delete_if { |todo| todo['id'] == params['id'].to_i }

  File.open('todos.json', 'w') do |file|
    JSON.dump(json, file)
  end

  redirect to('/todos'), 303
end

def escape_html(text)
  Rack::Utils.escape_html(text)
end

def db_json
  json_string = File.read('todos.json') do |file|
    JSON.parse(file)
  end

  JSON.parse(json_string)
end

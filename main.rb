require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17
INTITIAL_POT_AMOUNT = 500

helpers do 
  def calculate_total(cards)
    arr = cards.map{|element| element[1]}

    total = 0
    arr.each do |a|
      if a == "A"
        total += 11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
  end

  #correct for Aces
  arr.select{|element| element == "A"}.count.times do
    break if total <= 21
    total -= 10
  end

    total
  end

  def card_image(card)
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K', 'A'].include?(value)
      value = case card[1]
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'

  "<img src='/images/cards/#{suit}_#{value}.jpg' class= 'card_image'>"
end

def winner! (msg)
  @play_again = true
  @show_hit_or_stay_buttons = false
  session [:player_pot = session [:player_pot] + session[:player_bet]
  @success = "<strong>#{session[:player_name]} wins! </strong> #{msg}"
end

def loser (msg)
  @play_again = true
  @show_hit_or_stay_buttons = false
  @success = "<strong>#{session[:player_name]} loses. </strong> #{msg}"
end

def tie (msg)
  @play_again = true
  @show_hit_or_stay_buttons = false
  @success = "<strong>#{session[:player_name]} It's a tie!! </strong> #{msg}"
  end
end

before do
  @show_hit_or_stay_buttons = true
end



get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player' 
  end
end

get '/new_player' do
  session[:player_pot] = INTITIAL_POT_AMOUNT
  erb :new_player
end

post '/new_player' do
 if params[:player_name].empty?  
  @error = "Name is required"
  halt erb(:new_player)
end

session[:player_name = params[:player_name]
redirect '/bet'
end

get '/bet' do
  session[:player_bet] = nil
  erb :bet
end

post '/bet' 
if params [:bet_amount].nil? || params[:bet_amount].to_i == 0
  @error = "Must make a bet!"
  halt erb (:bet)
elsif params [:bet_amount].to_i > session[:player_pot]
  @error = "Bet amount cannot be greater than what you have ($#{session[player_pot]}"
halt erb (:bet)
else #happy path
  session[:player_bet] = params
  [:bet_amount].to_i
  redirect '/game'
  end
end

get '/game' do
  session [:turn] = session [:player_name]
  #create a deck and put it in session
  suits = ['H', 'D', 'C', 'S']
  values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  session[:deck] = suits.product(values).shuffle 

  #deal cards
  session[:dealer_cards] = []
  session[:player_name] = []
  session[:dealer_cards] << session[deck].pop
  session[:player_name]  << session[deck].pop
  session[:dealer_cards] << session[deck].pop
  session[:player_name]  << session[deck].pop

  erb :game
end

post '/game/player/hit' do
session[:player_name]  << session[deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == BLACKJACK_AMOUNT
    winner! (#{session[:player_name]} hit blackjack!)
  elsif player_total > BLACKJACK_AMOUNT
    @error = (loser!#{session[:player_name]} is busted at #{player_total")
  end

  erb: game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay!"
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session [:turn] = "dealer"
  @show_hit_or_stay_buttons = false
  
  #decision tree

  dealer_total = calculate_total (session[:dealer_cards])

  if dealer_total == BLACKJACK_AMOUNT Loser! ("Dealer hit blackjack!")
  elsif dealer_total > BLACKJACK_AMOUNT Winner! ("Dealer busteed at #{dealer_total}")
  elsif dealer_total >= DEALER_MIN_HIT #17, 18, 19, 20 

    #dealer stays
    redirect '/game/compare'
  else
    #dealer hits
    @show_hit_or_stay_buttons = true
  end

  erb :game
end

post '/game/dealer/hit' do
  session [:dealer_cards] << session [:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons= false

  player_total = calculate_total (session[:player_cards])
  dealer_total = calculate_total (session[:dealer_total])

  if player_total < dealer_total 
  loser! ("#{session[:player_name"]} stayed at #{player_total} and the dealer stayed at #{dealer_total}.")
else 
  winner! ("#{session[:player_name]} stayed at #{player_total}, and the dealer stayed at #{dealer_total}")
else 
  tie! ("Both #{session[:player_name]} and dealer stayed at #{player_total}.")
end

erb :game

get '/game_over' do 
  erb :game_over








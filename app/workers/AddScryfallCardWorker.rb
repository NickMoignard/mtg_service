require "scryfall/cards"

class AddScryfallCardWorker
    include Sidekiq::Worker
    
    def perform(scryfall_id)
        sleep(0.0050)
        card_data = Scryfall::Cards.with_id(scryfall_id)
        @card = Card.new
        @card["scryfall_id"] = card_data["id"]
        @card["multiverse_ids"] = card_data["multiverse_ids"]
        @card["tcgplayer_id"] = card_data["tcgplayer_id"]
        @card["cardmarket_id"] = card_data["cardmarket_id"]
        @card["scryfall_uri"] = card_data["scryfall_uri"]
        @card["name"] = card_data["name"]
        @card.save!
    end

end
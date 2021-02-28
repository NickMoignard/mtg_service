require 'oj'

##
# Simple API for Scryfall (Magic: The Gathering) bulk cards JSON documents 

class ScryfallBulkObjApi < ::Oj::Saj
    ##
    # Create Optimised JSON: Simple API for JSON
    #   Bulk card json documents can be many gigabytes in size
    #   This SAJ provides methods to be called durring the documents injest.
    #   See http://www.ohler.com/oj/doc/Oj/Saj.html for further information.


    def initialize()
        @cards_left_bool = false  # Is current line is inside an array of cards?
        @child_card_bool = false  # Current line inside a child card object?
        @parent_card = nil  # Stores card object whilst datamembers are being populated
        @parent_array_key = nil
        @parent_object_key = nil
    end
    
    def hash_start(key)
        ##
        # could be:
        #   new card
        #   new subcard
        #   new simple hash (ruling, prices etc)

        if !key.blank?
            @parent_object_key = key
            @parent_card["#{key}"] = {}
        end
    end

    def hash_end(key)
        if @child_card_bool && key.blank?
            @child_card_bool = false
        elsif key.blank? 
            @parent_card.save            
            @parent_card = nil
        else
            @parent_object_key = nil
        end
    end

    def array_start(key)
        if key.blank?
            @cards_left_bool = true
        else
            @parent_array_key = key
            @parent_card["#{key}"] = []
        end
    end

    def array_end(key)
        if key.blank?
            @cards_left_bool = false
        else
            @parent_array_key = nil
        end
    end

    def add_value(value, key)
        if key.blank?  # value to be appended to array
            @parent_card["#{@parent_array_key}"] << value unless !@parent_array_key.blank?
        elsif key == "object"
            if value == "card"
                @parent_card = Card.new()
            else
                @child_card_bool = true
            end
        elsif key == "id"  # we want to reindex this data in our db
            @parent_card["scryfall_id"] = value
        elsif !@parent_object_key.nil?  # value to be added to a simple hash_end
            @parent_card["#{@parent_object_key}"].store(key, value)
        else 
            @parent_card[key] = value
        end
    end

    def error(message, line, column)
        puts "line: #{line} column: #{column} #{message}"
    end
end
require './app/json_apis/ScryfallBulkObjApi'

class ImportBulkCardsScryfallWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0
    def perform(file_path)
        scrySaj = ScryfallBulkObjApi.new()
        File.open(file_path, 'r') do |file|
            Oj.saj_parse(scrySaj, file)
        end
    end
end
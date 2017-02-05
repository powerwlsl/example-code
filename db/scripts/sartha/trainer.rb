require 'json'
require 'rest-client' 	#http requests
require 'sanitize'		#html sanitization
require 'htmlentities' 	#html decoding

module Trainer
  @categories = JSON.parse(File.open("categories.json", "r").read)

  def self.resetData
    f_doc_counts = File.open("doc_counts.json", "w")
    f_category_counts = File.open("category_counts.json", "w")
    f_category_dicts = File.open("category_dicts.json", "w")

    @doc_counts = {}
    @doc_counts['total'] = 0
    @categories.each do |category|
      @doc_counts[category] = 0
    end
    f_doc_counts.write(@doc_counts.to_json)

    @category_counts["total"] = 0
    @categories.each do |category|
      @category_counts[category] = 0
    end
    f_category_counts.write(@category_counts.to_json)

    @category_dicts = {}
    @categories.each do |category|
      @category_dicts[category] = {}
    end
    f_category_dicts.write(@category_dicts.to_json)
  end

  def self.train
    f_doc_counts = File.open("doc_counts.json", "r+")
    f_category_counts = File.open("category_counts.json", "r+")
    f_category_dicts = File.open("category_dicts.json", "r+")

    @doc_counts = JSON.parse(f_doc_counts.read)           # hash, maps '<category>' => int, and 'total' => int
    @category_counts = JSON.parse(f_category_counts.read) # hash['<category>'] =>
    @category_dicts = JSON.parse(f_category_dicts.read)   # hash['<category>'] of hashes(word => int)

    @training_data = JSON.parse(RestClient.get("http://www.petrorecruit.co/static_pages/faq")) # list of hashes, id, title, desc, category
    @training_data.each do |document|
      category = document['c']
      description = document['d']
      @doc_counts["total"] += 1
      @doc_counts[category] += 1
      populateDict(category, description)
    end
    @categories.each do |category|
      populateWordOccurrences(category)
    end
    vocabSize

    f_doc_counts.write(@doc_counts)
    f_category_counts.write(@category_counts)
    f_category_dicts.write(@category_dicts)

    f_doc_counts.close
    f_category_dicts.close
    f_category_counts.close
  end

  def populateDict(category, description) # string
    words_list = description.split(/[^a-zA-Z'-]+/).map {|word| word.to_lower}
    words_list.each do |word|
      if @category_dicts[category][word].nil?
        @category_dicts[category][word] = 1
      else
        @category_dicts[category][word] += 1
      end
    end
  end

  def vocabSize
    all_keys = []
    @category_dict.each do |dict|
      all_keys << dict.keys
    end
    all_keys.uniq.size
  end

  def populateWordOccurrences(category)
    total = 0
    @category_dicts[category].each do |k,v|
      total += v
    end
    @category_counts[category] = total
  end
end

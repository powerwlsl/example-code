require 'json'
require 'rest-client' 	#http requests
require 'sanitize'		#html sanitization
require 'htmlentities' 	#html decoding

module Categorizer
  class Document
    attr_reader :id, :title, :description
    def initialize(objHash)
      @id = objHash['i']
      @title = objHash['t']
      @title ||= objHash[:title]
      @description = HTMLEntities.new.decode(Sanitize.fragment objHash['d'])
      @description ||= HTMLEntities.new.decode(Sanitize.fragment "#{objHash[:description]} #{objHash[:qualification]}")

    end
  end

  @categories = JSON.parse(File.open("categories.json", "r").read)
  f_doc_counts = File.open("doc_counts.json", "r")
  f_category_counts = File.open("category_counts.json", "r")
  f_category_dicts = File.open("category_dicts.json", "r")

  @doc_counts = JSON.parse(f_doc_counts.read)           # hash, maps '<category>' => int, and 'total' => int
  @category_counts = JSON.parse(f_category_counts.read) # hash['<category>'] of hashes('occurrences' => int, 'distinct' => int)
  @category_dicts = JSON.parse(f_category_dicts.read)   # hash['<category>'] of hashes(word => int)

  f_doc_counts.close
  f_category_dicts.close
  f_category_counts.close

  def self.categorize(document)
    top_category = @categories.first
    top_score = 0
    @categories.each do |category|
      score = prior(category).log * document_given_category(document, category)
      if score > top_score
        top_category = category
        top_score = score
      end
    end
    top_category, top_score
  end
  # penis
  # Probabilty of a given document being a specific category, P(c)
  def prior(category)
    @doc_counts[category] / @doc_counts['total']
  end

  # Probability of a given word occurring a specific category, P(xi|c)
  def word_given_category(word, category)
    word_category_count = @category_dicts[category][word]
    word_category_count ||= 0
    (word_category_count+1) / (@category_counts["total"]+@category_counts[category])
  end

  def document_given_category(document, category)
    words_list = document.description.split(/[^a-zA-Z'-]+/).map {|word| word.to_lower}
    sum = 0
    words_list.each do |word|
      sum += word_given_category(word, category).log
    end
    sum
  end
end

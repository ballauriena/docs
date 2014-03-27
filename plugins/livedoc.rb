require 'rack'
require 'htmlentities'
require 'uri'

module Jekyll
  class LiveDocTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      parameters = markup.split(" ")
      @method = parameters[0].upcase
      @url = parameters[1]
      data = HTMLEntities.new.decode(parameters[2])

      #parse the querystring data into a hash
      @params = Rack::Utils.parse_nested_query(data)
      super
    end

    def render(context)
      inputs = ""
      @params.each do |key, value| 
        if value.is_a?(Array)
          value = "[" + value.join(",") + "]"
        end

        if value.nil? 
          value = ""
        end

        inputs = inputs + '<div class="form-group"><label>' + key + '</label>'
        inputs = inputs + '<input type="text" class="form-control" name="' + key + '" + value="' + value + '">'
        inputs = inputs + '</input></div>'
      end

      uri = URI.parse(@url);
      if !uri.nil?
        base_url = uri.scheme + "://" + uri.host + uri.path
      end

      #wondering what this syntax is? google "here document"
      output=<<-HTML
      <div class="live-doc">
        <input type="hidden" class="method" value="#{@method}"/>
        <input type="hidden" class="url" value="#{base_url}"/>
        <button class="btn btn-primary tryit">Try It</button>
        <form role="form" class="well">
          #{inputs}
          <button type="input" class="btn btn-default">Make Request</button>
        </form>
      </div>
      HTML

      output
    end
  end
end

Liquid::Template.register_tag('livedoc', Jekyll::LiveDocTag)
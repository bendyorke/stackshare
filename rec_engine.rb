require_relative 'assert.rb'
require_relative 'api.rb'

module RecEngine
  @api = Api.new(ENV['STACKSHARE_ACCESS_TOKEN'])

  def recommend_for_tag tag_id
    stacks = @api.fetch_stacks tag_id
    recommend_for_stacks stacks
  end
  module_function :recommend_for_tag

  def recommend_for_stacks stacks
    tools = tools_for_stacks stacks
    @api.load_layers.map do |layer|
      layer["recommendation"] = recommend_for_layer layer, tools
      layer["tools"] = layer["tools"].length
      layer
    end
  end
  module_function :recommend_for_stacks

  def tools_for_stacks stacks
    stacks.reduce([]) { |memo, stack| memo += stack["tools"] }
  end
  module_function :tools_for_stacks

  def tools_in_layer layer, tools
    tool_ids = layer["tools"].map { |t| t["id"].to_s }
    tools.select do |tool|
      tool_ids.include? tool["id"].to_s
    end
  end
  module_function :tools_in_layer

  def recommend_for_layer layer, tools
    relevant_tools = tools_in_layer layer, tools

    freq = relevant_tools.reduce(Hash.new(0)) { |h,v| h[v["id"]] += 1; h }
    relevant_tools.sort_by { |t| freq[t["id"]] }.last
  end
  module_function :recommend_for_layer

end

if __FILE__ == $0
  def tool id
    {"id" => id}
  end

  def stack id
    {
      "id" => id,
      "tools" => 3.times.collect { |n|  tool(id + n) }
    }
  end

  def layer id, tools
    {
      "id" => id,
      "tools" => tools,
    }
  end

  assert "correctly counts tools for given stacks" do
    tools = RecEngine.tools_for_stacks 3.times.collect { |n| stack n }
    tools.length == 9
  end

  assert "can select tools only present in layer" do
    tools = [tool(1), tool(2)]
    layer_tools = [tool(1)]
    layer = layer 0, layer_tools
    tools_in_layer = RecEngine.tools_in_layer layer, tools
    tools_in_layer == layer_tools
  end

  assert "correctly suggests the most common tool in the layer" do
    tools = 5.times.collect { |n| tool(n % 4) }
    layer = layer 0, tools.uniq { |t| t["id"] }[0..2]
    rec = RecEngine.recommend_for_layer layer, tools
    rec == tool(0)
  end
end

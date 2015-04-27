require "mad_libs/flake/simple_flake"

module MadLibs::Flake::RandomFlake
  ResponseStrategy = MadLibs::Flake::ResponseStrategy

  def self.new(frequency = 8)
    response_strategy = ResponseStrategy.new(:frequency => frequency)
    MadLibs::Flake::SimpleFlake.new(response_strategy)
  end
end

# coding: utf-8

$libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift($libdir) unless $LOAD_PATH.include?($libdir)

require 'sinatra'
require 'json'
require 'json-schema'
require 'services/sensors'
require 'services/sensorMock'
require 'services/scheduler'
require 'services/implementation'


class Environment
	class << self
		attr_accessor :config, :sensors, :debug
	end
    @config = {}
    @sensors = {}
    @debug = false
end

Environment.config  = JSON.parse(File.read("config/configuration.json"))
Environment.debug = Environment.config.has_key?('debug') && Environment.config['debug']

Implementation.register do |i|
  i[:sensors] 	     = (Environment.config.has_key?('mock') && Environment.config['mock'])? SensorMock.new: Sensors.new
  i[:scheduler]		 = Scheduler.new(i[:sensors])
end

load 'app.rb'

run Sinatra::Application

Implementation[:scheduler].start

at_exit do
  Implementation[:scheduler].stop
end
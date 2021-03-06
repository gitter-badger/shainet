require "./spec_helper"
require "csv"

describe SHAInet::Network do
  it "Initialize" do
    nn = SHAInet::Network.new
    nn.should be_a(SHAInet::Network)
  end

  it "figure out xor" do
    training_data = [
      [[0, 0], [0]],
      [[1, 0], [1]],
      [[0, 1], [1]],
      [[1, 1], [0]],
    ]

    xor = SHAInet::Network.new
    xor.add_layer(:input, 2, :memory)
    1.times { |x| xor.add_layer(:hidden, 2, :memory) }
    xor.add_layer(:output, 1, :memory)
    xor.fully_connect

    # data, cost_function, activation_function, epochs, error_threshold, learning_rate, momentum)
    xor.train(training_data, :mse, :sigmoid, 10000, 0.000001)

    (xor.run([0, 0]).first < 0.1).should eq(true)
  end

  it "works on iris dataset" do
    label = {
      "setosa"     => [0.to_f64, 0.to_f64, 1.to_f64],
      "versicolor" => [0.to_f64, 1.to_f64, 0.to_f64],
      "virginica"  => [1.to_f64, 0.to_f64, 0.to_f64],
    }
    iris = SHAInet::Network.new
    iris.add_layer(:input, 4, :memory)
    iris.add_layer(:hidden, 5, :memory)
    iris.add_layer(:hidden, 5, :memory)
    iris.add_layer(:output, 3, :memory)
    iris.fully_connect

    outputs = Array(Array(Float64)).new
    inputs = Array(Array(Float64)).new
    CSV.each_row(File.read(__DIR__ + "/test_data/iris.csv")) do |row|
      row_arr = Array(Float64).new
      row[0..-2].each do |num|
        row_arr << num.to_f64
      end
      inputs << row_arr
      outputs << label[row[-1]]
    end
    normalized = SHAInet::TrainingData.new(inputs, outputs)
    normalized.normalize_min_max
    puts normalized
    iris.train(normalized.data, :mse, :sigmoid, 10000, 0.000001)
  end
end

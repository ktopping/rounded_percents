RSpec.describe RoundedPercents do

  it "has a version number" do
    expect(RoundedPercents::VERSION).not_to be nil
  end

  EXAMPLES = {
    [0.6, 0.6, 1.9, 96.9] => {
      [RoundedPercents::LAD, 0] => [1, 0, 2, 97],
      [RoundedPercents::LRD, 0] => [1, 0, 2, 97],
      [RoundedPercents::LRD_AVOID_ZERO, 0] => [1, 1, 1, 97],
    },
    [0.6, 0.6, 0.6, 98.2] => {
      [RoundedPercents::LAD, 0] => [1, 1, 0, 98],
      [RoundedPercents::LRD, 0] => [1, 0, 0, 99],
      [RoundedPercents::LRD_AVOID_ZERO, 0] => [1, 1, 0, 98],
    },
    [1, 2.5, 1, 1, 1, 1, 1, 1, 3, 3.5] => {
      [RoundedPercents::LAD, 0] => [7, 16, 6, 6, 6, 6, 6, 6, 19, 22],
      [RoundedPercents::LRD, 0] => [7, 16, 6, 6, 6, 6, 6, 6, 19, 22],
      [RoundedPercents::LAD, 1] => [6.3, 15.6, 6.3, 6.3, 6.3, 6.2, 6.2, 6.2, 18.7, 21.9],
      [RoundedPercents::LRD, 1] => [6.3, 15.7, 6.3, 6.2, 6.2, 6.2, 6.2, 6.2, 18.8, 21.9]
    },
    [1, 2.5, 3, 3.5] => {
      [RoundedPercents::LAD, 0] => [10, 25, 30, 35],
      [RoundedPercents::LRD, 0] => [10, 25, 30, 35],
      [RoundedPercents::LAD, 1] => [10, 25, 30, 35],
      [RoundedPercents::LRD, 1] => [10, 25, 30, 35]
    },
    [1.9, 1.9, 1.9, 94.3] => {
      [RoundedPercents::LAD, 0] => [2, 2, 2, 94],
      [RoundedPercents::LRD, 0] => [2, 2, 1, 95],
    },
    [25.5, 25.4, 25.3, 22.8, 1] => {
      [RoundedPercents::LAD, 0] => [26, 25, 25, 23, 1],
      [RoundedPercents::LRD, 0] => [26, 25, 25, 23, 1]
    },
    [25.5, 25.4, 25.3, 23.8] => {
      [RoundedPercents::LAD, 0] => [26, 25, 25, 24],
      [RoundedPercents::LRD, 0] => [26, 25, 25, 24]
    },
    [25.59, 25.42, 25.31, 23.8] => {
      [RoundedPercents::LAD, 1] => [25.5, 25.4, 25.3, 23.8],
      [RoundedPercents::LRD, 1] => [25.5, 25.4, 25.3, 23.8]
    },
    [25.99, 25.99, 25.99, 22.03] => {
      [RoundedPercents::LAD, 1] => [26.0, 26.0, 26.0, 22.0],
      [RoundedPercents::LRD, 1] => [26.0, 26.0, 26.0, 22.0]
    },
    [33.33, 33.33, 33.33] => {
      [RoundedPercents::LAD, 0] => [34, 33, 33],
      [RoundedPercents::LRD, 0] => [34, 33, 33],
      [RoundedPercents::LAD, 1] => [33.4, 33.3, 33.3],
      [RoundedPercents::LRD, 1] => [33.4, 33.3, 33.3]
    },
  }

  EXAMPLES.each do |source, hash|
    hash.each do |arr, expected|
      context "algorithm=#{arr[0]}, precision=#{arr[1]}" do
        let(:subject) { RoundedPercents.new(source, algorithm: arr[0], precision: arr[1]) }
        it "should be as expected" do
          # puts subject.describe
          expect(subject).to eq(expected)
        end
      end
    end
  end

  describe "Parameters" do
    INVALID = {
      [[]] => /empty array/,
      [[0]] => /at least one array value should be >0/,
      [[-1]] => /array values should be >=0/,
      [[1], {precision: -1}] => /bad precision/,
      [[1], {precision: 4}] => /bad precision/,
      [[1], {algorithm: 1}] => /bad algorithm/,
    }
    INVALID.each do |params, error_regex|
      it do
        expect { RoundedPercents.new(*params) }.to raise_exception(error_regex)
      end
    end
  end

end

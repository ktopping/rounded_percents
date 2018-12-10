require 'ostruct'

class RoundedPercents < Array

  LRD = :least_relative_difference
  LAD = :least_absolute_difference
  LRD_AVOID_ZERO = :least_relative_difference_avoid_zero

  class RoundedValue < OpenStruct

    def initialize(p, precision=0)
      super(original: p, precision: precision, ceil: p.ceil(precision), floor: p.floor(precision))
      self.rounded = floor
    end

    def original_already_rounded?
      ceil == original
    end

    def original_would_round_up?
      ceil == original.round(precision)
    end

    def rounding_up_relative_error
      @rounding_up_relative_error ||= case
      when original_already_rounded?
        1 # do these last; they're already precise
      else
        rounding_up_absolute_error / ceil # (make sure it's < 1 (use "ceil" rather than "original"))
      end
    end

    def rounding_up_absolute_error
      @rounding_up_absolute_error ||= case
      when original_already_rounded?
        1 # do these last; they're already precise
      else
        ceil - original
      end
    end

    # Round up the ones that SHOULD have been rounded up first (according to relative val)
    # Prioritize ones between 0 & 1 (so they're not zero-ed)
    # TODO: call "smart" ?
    def least_relative_difference_avoid_zero
      @least_relative_difference_avoid_zero ||= case
      when original_already_rounded?
        # E.g. "0", "10.0" (where precision =0) or "1.1" (where precision =1)
        1
      when original_would_round_up?
        # Ones that ought - ideally - to be rounded up
        if floor == 0
          # Ones between 0 and stepsize
          # Prioritize these (so we turn them into 1 instead of 0)
          rounding_up_relative_error - 3
        else
          # Others that ought - ideally - to be rounded up
          rounding_up_relative_error - 2
        end
      else
        # Ones that ought - ideally - to be rounded down
        rounding_up_relative_error
      end
    end

  end

  attr_reader :algorithm, :precision, :rounded_values

  # https://stackoverflow.com/a/34959983
  # Works our percentages THEN rounds (to precision)
  def initialize(num_array, precision: 0, algorithm: LAD)
    raise "empty array" unless num_array.length > 0
    raise "array values should be >=0" unless num_array.all? {|n| n >= 0}
    raise "at least one array value should be >0" unless num_array.any? {|n| n > 0}
    raise "bad precision" unless [0,1,2,3].include?(precision)
    raise "bad algorithm" unless [LRD, LAD, LRD_AVOID_ZERO].include?(algorithm)
    @precision = precision
    @algorithm = algorithm
    @rounded_values = array_to_percentages(num_array).map {|f| RoundedValue.new(f, precision)}
    unallocated_steps.times { r = least_impact_first.shift; r.rounded = (r.rounded + unallocated_step_size).round(precision) }
    super roundeds
  end

  def describe
    # puts @rounded_values
    puts
    puts "Precision: #{precision}. Algorithm #{algorithm}."
    puts "#{unallocated} unallocated: #{unallocated_steps} steps of #{unallocated_step_size}:"
    puts "  #{originals.inspect}"
    puts "  => #{floors.inspect}.sum = #{floors.sum}"
    puts "     #{rounding_up_relative_errors.inspect} (rel)"
    puts "     #{rounding_up_absolute_errors.inspect} (abs)"
    puts "  => #{roundeds.inspect}.sum = #{roundeds.sum}"
  end

private

  [:rounded, :original, :floor, :rounding_up_relative_error, :rounding_up_absolute_error].each do |m|
    meth = :"#{m}s"
    define_method(meth) do
      rounded_values.map(&m)
    end
    private meth
  end

  def array_to_percentages(num_array)
    total = num_array.sum
    array_of_floats = num_array.map { |n| (100 * n.to_f) / total }
  end

  def unallocated
    @unallocated ||= (100.0 - rounded_values.map(&:rounded).sum).round(precision)
  end

  def least_impact_first
    @least_impact_first ||= begin
      sort_meth = {
        LAD            => :rounding_up_absolute_error,
        LRD            => :rounding_up_relative_error,
        LRD_AVOID_ZERO => :least_relative_difference_avoid_zero
      }[algorithm]
      rounded_values.sort_by(&sort_meth)
    end
  end

  def unallocated_step_size
    @unallocated_step_size ||= 1.0 / (10**precision)
  end

  def unallocated_steps
    @unallocated_steps ||= (unallocated / unallocated_step_size).round.to_i
  end

end

require 'rounded_percents/version'

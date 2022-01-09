# frozen_string_literal: true

require 'pagy'

class Pagy # :nodoc:
  #
  class Bucket < Pagy
    attr_accessor :buckets, :bucket_key

    def initialize(vars) # rubocop:disable Lint/MissingSuper
      vars = self.class::DEFAULT.merge(vars) # subclass specific default

      @buckets = vars[:buckets]

      normalize_vars(vars)
      setup_vars(count: @buckets.length, outset: 0)
      setup_items_var
      setup_pages_var
      setup_params_var

      @page_key = vars[:page] || @buckets.first

      raise ArgumentError.new("Page: #{@page_key} not in Buckets: #{@buckets}") unless @buckets.include?(@page_key)

      @page = @buckets.index(@page_key) + 1

      @offset = (@items * (@page - 1)) + @outset
      @from = [@offset - @outset + 1, @count].min
      @to = [@offset - @outset + @items, @count].min
      @in = [@to - @from + 1, @count].min
      @prev = (@page - 1 unless @page == 1)
      @next = @page == @last ? (1 if @vars[:cycle]) : @page + 1

      @page = @page_key
      @prev = @buckets[@prev - 1] if @prev
      @next = @buckets[@next - 1] if @next
    end

    def series(size: @vars[:size])
      return [] if size.empty?

      page_index = @buckets.index(@page)

      start = 0
      left_gap_start = size[0]
      left_gap_end = page_index - size[1]
      right_gap_start = page_index + size[2]
      right_gap_end = @buckets.length - size[3]

      series = []

      if (left_gap_end - left_gap_start - 1).positive?
        series.push(*@buckets[start..(left_gap_start - 1)], :gap)
        start = left_gap_end
      end

      if (right_gap_end - right_gap_start - 2).positive?
        series.push(*@buckets[start..right_gap_start], :gap)
        start = right_gap_end
      end

      series.push(*@buckets[start...@buckets.length])

      series
    end
  end
end

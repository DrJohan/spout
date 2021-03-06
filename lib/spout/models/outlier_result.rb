# frozen_string_literal: true

require 'spout/helpers/array_statistics'
require 'spout/helpers/json_loader'

module Spout
  module Models
    class OutlierResult
      attr_reader :csv_files, :method, :major_outliers, :minor_outliers, :outliers, :weight, :units, :display_name, :median, :variable_type

      def initialize(subjects, method, csv_files)
        @values = subjects.collect(&method.to_sym)
        @csv_files = csv_files
        @method = method


        calculate_outliers!

        @weight = if @major_outliers.count > 0
          0
        elsif @minor_outliers.count > 0
          1
        else
          2
        end
        variable = Spout::Helpers::JsonLoader::get_variable(method)
        @units = (variable.is_a?(Hash) ? variable['units'] : nil)
        @display_name = (variable.is_a?(Hash) ? variable['display_name'] : nil)
        @variable_type = (variable.is_a?(Hash) ? variable['type'] : nil)
        @median = @values.median
      end

      def calculate_outliers!
        @major_outliers = @values.major_outliers.uniq
        @minor_outliers = @values.minor_outliers.uniq
        @outliers = @values.outliers.uniq
      end

    end

  end
end

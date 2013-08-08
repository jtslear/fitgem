module Fitgem
  class Client
    # ==========================================
    #      Body Measurements Update Methods
    # ==========================================

    # Get the body measurements logged on a specified date
    #
    # @param [DateTime, String] date The date to retrieve body
    #   measurements for.  May be a DateTime object or a String
    #   in "yyyy-MM-dd" format.
    # @return [Hash] A hash containing the logged body measurements
    #   along with any goals set for the current user.
    def body_measurements_on_date(date)
      get("/user/#{@user_id}/body/date/#{format_date(date)}.json")
    end

    # ==========================================
    #      Body Measurements Update Methods
    # ==========================================

    # Log weight to fitbit for the current user
    #
    # @param [Integer, String] weight The weight to log, as either
    #   an integer or a string in "X.XX'" format
    # @param [DateTime, String] date The date the weight should be
    #   logged, as either a DateTime or a String in "yyyy-MM-dd" format
    # @return [Hash]
    #
    # @deprecated {#log_body_measurements} should be used instead of
    #   log_weight
    def log_weight(weight, date, options={})
      post("/user/#{@user_id}/body/weight.json", options.merge(:weight => weight, :date => format_date(date)))
    end

    # Log body measurements to fitbit for the current user
    #
    # At least ONE measurement item is REQUIRED in the call, as well as the
    # date. All measurement values to be logged for the user must be either an
    # Integer, a Decimal value, or a String in "X.XX" format. The
    # measurement units used for the supplied measurements are based on
    # which {Fitgem::ApiUnitSystem} is set in {Fitgem::Client#api_unit_system}.
    #
    # @param [Hash] opts The options including data to log for the user
    # @option opts [Integer, Decimal, String] :weight Weight measurement
    # @option opts [Integer, Decimal, String] :waist Waist measurement
    # @option opts [Integer, Decimal, String] :thigh Thigh measurement
    # @option opts [Integer, Decimal, String] :neck Neck measurement
    # @option opts [Integer, Decimal, String] :hips Hips measurement
    # @option opts [Integer, Decimal, String] :forearm Forearm measurement
    # @option opts [Integer, Decimal, String] :fat Body fat percentage measurement
    # @option opts [Integer, Decimal, String] :chest Chest measurement
    # @option opts [Integer, Decimal, String] :calf Calf measurement
    # @option opts [Integer, Decimal, String] :bicep Bicep measurement
    # @option opts [DateTime, Date, String] :date Date to log measurements
    #   for; provided either as a DateTime, Date, or a String in
    #   "yyyy-MM-dd" format
    #
    # @return [Hash] Hash containing the key +:body+ with an inner hash
    #   of all of the logged measurements
    #
    # @since v0.4.0
    def log_body_measurements(opts)
      # Update the date (if exists)
      opts[:date] = format_date(opts[:date]) if opts[:date]
      post("/user/#{@user_id}/body.json", opts)
    end

    private

    # Determine the URI for the body_weight or body_fat method
    #
    # @params [String] base_uri the base URI for the body weight or body fat method
    # @params [Hash] opts body weight/fat options
    # @option opts [Date] date The date in the format YYYY-mm-dd.
    # @option opts [Date] base-date The end date when period is provided, in the
    #   format yyyy-MM-dd or today; range start date when a date range is provided.
    # @option opts [String] period The date range period. One of 1d, 7d, 30d, 1w, 1m
    # @option opts [Date] end-date Range end date when date range is provided.
    #   Note that period should not be longer than 31 day
    #
    # @return [String] an URI based on the base URI and provided options
    def determine_body_uri(base_uri, opts = {})
      if opts[:date]
        date = format_date opts[:date]
        "#{base_uri}/date/#{date}.json"
      elsif opts[:base_date] && (opts[:period] || opts[:end_date])
        date_range = construct_date_range_fragment opts
        "#{base_uri}/#{date_range}.json"
      else
        raise Fitgem::InvalidArgumentError, "You didn't supply one of the required options."
      end
    end
  end
end

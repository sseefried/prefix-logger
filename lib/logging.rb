#
# Author: Sean Seefried
# Description: A mixin for improved logging
# Date: 04 Mar 2009
#

# This module makes the methods +log_error+ and +log_info+ available as
# instance methods *and* class methods.  It uses the clever idea of
# including +ClassMethods+ twice, once in the body and once in
# self.included

module Logging
  # include the methods as class methods
  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods
    LOGGING_ERROR_PREFIX = "ERROR: "
    LOGGING_INFO_PREFIX  = "INFO: "

    @@logging_logger = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")

    def log_error(o)
      str = o.is_a?(String) ? o : o.inspect
      @@logging_logger.error(logging_add_prefix(LOGGING_ERROR_PREFIX,str))
    end

    def log_info(o)
      str = o.is_a?(String) ? o : o.inspect
      @@logging_logger.info(logging_add_prefix(LOGGING_INFO_PREFIX,str))
    end

    def logging_add_prefix(prefix, str)
      prefix + str.to_s.split(/\n/).join("\n#{prefix}")
    end

    def error_prefix
      LOGGING_ERROR_PREFIX
    end

    def info_prefix
      LOGGING_INFO_PREFIX
    end

    def log_time(description)
      t0 = Time.zone.now
      log_info("#{description}")
      result = yield
      seconds = Time.zone.now - t0
      if seconds < 1
        log_info("[Time] #{description} took %dms" % (seconds * 1000.to_i))
      else
        args = [seconds, (seconds / 60).to_i, seconds.to_i % 60]
        log_info("[Time] #{description} took %.2fs = %d:%02d" % args)
      end
      result
    end

  end

  # include the methods as instance methods
  include ClassMethods

end

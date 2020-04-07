module ScbEasyApi
  VERSION_INFO = [2, 1, 5].freeze
  VERSION = VERSION_INFO.map(&:to_s).join('.').freeze

  def self.version
    VERSION
  end
end
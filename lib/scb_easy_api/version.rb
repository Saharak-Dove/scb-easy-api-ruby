module ScbEasyApi
  VERSION_INFO = [2, 1, 6].freeze
  VERSION = VERSION_INFO.map(&:to_s).join('.').freeze

  def self.version
    VERSION
  end
end
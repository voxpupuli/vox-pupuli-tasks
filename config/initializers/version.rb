# frozen_string_literal: true

VERSION = begin
  File.read('VERSION').chomp
rescue StandardError
  nil
end

BUILD_DATE = begin
  File.read('BUILD_DATE').chomp
rescue StandardError
  Time.now.to_i
end

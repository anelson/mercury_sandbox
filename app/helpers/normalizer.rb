# Normalizes titles and inserts word boundary marks

WORD_SEPARATOR = File::SEPARATOR + File::SEPARATOR

class Normalizer

  def Normalizer.normalize(title)
    normalized_title = String.new(title)

    # Replace non-printable characters with a space
    normalized_title.gsub!(/[^[:print:]]+/, " ")

    # Replace punctuation with a single space
    normalized_title.gsub!(/[[:punct:]]+/, " ")

    # Mark transitions between a lower and upper case letter with a space
    normalized_title.gsub!(/([[:lower:]])([[:upper:]])/, '\1 \2')

    # Mark transitions between an alpha and non-alpha character (and vice versa)
    # with space
    normalized_title.gsub!(/([[:alpha:]])([^[:alpha:]])/, '\1 \2')
    normalized_title.gsub!(/([^[:alpha:]])([[:alpha:]])/, '\1 \2')

    # Remove leading and trailing space
    normalized_title.strip!

    # Collapse whitespace into a single word separator
    normalized_title.gsub!(/\s+/, WORD_SEPARATOR)

    # convert to lower case
    normalized_title.downcase!

    return normalized_title
  end
end

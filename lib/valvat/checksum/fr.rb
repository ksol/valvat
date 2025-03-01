# frozen_string_literal: true

class Valvat
  module Checksum
    class FR < Base
      # the valid characters for the first two digits (O and I are missing)
      ALPHABET = '0123456789ABCDEFGHJKLMNPQRSTUVWXYZ'

      def validate
        return super if str_wo_country[0..1] =~ /^\d+$/

        numeric_start = str_wo_country[0] =~ /\d/

        check = (ALPHABET.index(str_wo_country[0]) * (numeric_start ? 24 : 34)) +
                ALPHABET.index(str_wo_country[1]) - (numeric_start ? 10 : 100)

        (str_wo_country[2..-1].to_i + 1 + (check / 11)) % 11 == check % 11
      end

      def check_digit
        siren = str_wo_country[2..-1].to_i
        (12 + ((3 * siren) % 97)) % 97
      end

      def given_check_digit
        str_wo_country[0..1].to_i
      end
    end
  end
end

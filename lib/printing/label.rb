module Sanger::Barcode::Printing
class Label
  attr_accessor :number, :study, :suffix, :output_plate_purpose, :prefix

  def initialize(options = {})
    unless options.nil?
      @number = options[:number]
      @study = options[:study]
      @suffix = options[:suffix]
      @prefix= options[:prefix]
      if !options[:batch].nil? && !options[:batch].output_plate_purpose.nil?
        @output_plate_purpose = options[:batch].output_plate_purpose.name  
      end
    end
  end
  
  def printable(printer_type, options)
    default_prefix = options[:prefix]
    barcode_type   = options[:type] || "short" 
    study_name     = options[:study_name]
    user_login    = options[:user_login]

    number      = self.number.to_i
    prefix      = self.barcode_prefix(default_prefix)
    suffix      = self.suffix
    description = self.barcode_description
    text        = self.barcode_text(default_prefix)

    #TODO[mb14] deduce barcode_type form printer_type
    if barcode_type == "long"
      text = "#{study_name}" if study_name
      description = "#{user_login} #{output_plate_purpose} #{barcode_name}" if user_login
    end
    scope          = description

    return BarcodeLabelDTO.new(number,
                            description,
                            text,
                            prefix,
                            scope,
                            suffix)
  end


  def barcode_name
    # at that point we should probably remove the first to chars of the study if its LE
    # but the old code doesn't do it, maybe a bug
    # for now, we keep the old (buggy) code behavior
    name = study ?  study.gsub("_", " ").gsub("-"," ") : nil
  end
  def barcode_description
    "#{barcode_name}_#{number}"
  end

  def barcode_prefix(default_prefix)
    #todo move upstream
    prefix || begin 
      p = study[0..1]
      p == "LE" ? p : default_prefix
    end
  end

  def barcode_text(default_prefix)
     "#{barcode_prefix(default_prefix)} #{number.to_s}"
  end


end
end

require "fossilize/version"
require "ffi"

# Public: Provides an interface through Ruby-FFI to the delta encoding algorithm
# written for the Fossil SCM project by D. Richard Hipp. All methods are module methods.
#
# Examples
#
#   delta = Fossilize.create(file1, file2)
#   output = Fossilize.apply(file1, delta)
#
module Fossilize
  extend FFI::Library

  ffi_lib "ext/fossilize/fossil_delta.so"

  attach_function :delta_create, [:pointer, :int, :pointer, :int, :pointer], :int
  attach_function :delta_output_size, [:pointer, :int], :int
  attach_function :delta_apply, [:pointer, :int, :pointer, :int, :pointer], :int


  # Access: Public Module Method

  # Summary
  #   Creates a delta of two strings using the Fossil delta encoding algorithm.

  # Parameters
  #   old - The old string.
  #   new - The new string to create the delta from.

  # Examples

  #   # Create the delta between two strings
  #   Fossilize.create("Hello World!", "Hello Everyone!")

  #   # Create the delta between two files (note the passing of a File object)
  #   source = File.new("README.md", "r")
  #   target = File.new("README_new.md", "r")
  #   Fossilize.create(source, target)

  #   # You can also create a delta between a file and a string (the arguments are interchangeable)
  #   Fossilize(source, "This is the new README for Fossilize!")

  # Returns a String that represents the deltaed differences between the two Strings.
  def self.create(source, target)
    # Because this method can accept three different types of parameter (path, String or File)
    # we need to do a sanity check on the input parameters.
    source_string = check_input(source)
    target_string = check_input(target)

    # Create native memory buffers for the input Strings.
    source_ptr = FFI::MemoryPointer.new(:char, source_string.size)
    source_ptr.put_bytes(0, source_string)
    target_ptr = FFI::MemoryPointer.new(:char, target_string.size)
    target_ptr.put_bytes(0, target_string)

    # Create a bare string to hold to returning delta from the C function that's the
    # size of the target + 60 (according to the Fossil source docs).
    delta = (' ' * (target_string.size + 60))

    # create the delta, retaining the size of the delta output and return the delta,
    # stripping out any excess left over (needs refinement...).
    delta_size = delta_create(source_ptr, source_ptr.size, target_ptr, target_ptr.size, delta)
    return delta.strip!
  end

  # Public / Module Method
  #   Applies a delta string to another string.
  #
  # source - The old string to apply the delta string to.
  # delta - The delta string created using *create* or *create_from_string*.
  #
  # Returns a new unified string created by applying the delta to the source
  # if successful. The algorithm returns -1 as the output_size if the delta was
  # not created from the given source or is malformed. In this case, this method returns nil.
  def self.apply(source, delta)
    # Get the eventual size of the deltaed file and create a string to hold it
    expected_output_size = delta_output_size(delta, delta_size)

    # Check for an error returned from the algorithm
    if expected_output_size == -1
      raise MalformedDeltaError, "Was this delta intended for this string/file?"
      return nil
    end

    # Create an empty string that is at-least the output_size given by *delta_output_size*
    output = ' ' * output_size

    # Apply the delta to the old file to produce the merged result
    output_size = delta_apply(source, source.size, delta, delta.size, output)

    if output_size != expected_output_size
      raise DeltaApplicationError,
      "Output was #{output_size}, but I expected #{expected_output_size}!"
      return nil
    end

    return output.strip!
  end

  # Private: checks that the input given to the delta methods is sane, i.e. can it be passed
  # to the C-extension without any problems? The algorithm itself expects a String no matter what.
  #
  # input - The input to perform the sanity check on.
  #
  # Returns a String as read from a File object (either through a path or a File object) or a
  # direct String as passed to the calling method.
  def self.check_input(input)
    raise ArgumentError, "source or target input was nil!" if input.nil?
    raise ArgumentError,
      "Only Strings (including file paths) and File objects can be used to create deltas." if
      (!input.instance_of? String and !input.instance_of? File)

    # Now we know the input is a valid type, we need to check exactly what type it is.
    # We know straight away if the input is a File object, just read from it.
    if input.instance_of? File
      input_string = input.read
    elsif input.instance_of? String
      # We can determine quickly if the input is a path to a file or merely a String object
      # by checking if it actually exists. Sneaky.
      if File.exists?(input)
        input_string = File.read(input)
      else
        return input
      end
    end

    return input_string
  end
end

class MalformedDeltaError < StandardError; end
class DeltaApplicationError < StandardError; end

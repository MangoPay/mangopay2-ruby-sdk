module MangoPay

  # Generic error superclass for MangoPay specific errors.
  # Currently never instantiated directly.
  # Currently only single subclass used.
  class Error < StandardError
  end

  # See http://docs.mangopay.com/api-references/response-codes-rules/
  # and http://docs.mangopay.com/api-references/error-codes/
  # 
  # Thrown from any MangoPay API call whenever
  # it returns response with HTTP code != 200.
  # Check @details hash for further info.
  # 
  # Two example exceptions with details:
  # 
  # #<MangoPay::ResponseError:
  #   One or several required parameters are missing or incorrect. [...]
  #   Email: The Email field is required.>
  # {"Message"=>"One or several required parameters are missing or incorrect.
  #   An incorrect resource ID also raises this kind of error.",
  #  "Type"=>"param_error",
  #  "Id"=>"66936e92-3f21-4a35-b6cf-f1d17c2fb6e5",
  #  "Date"=>1409047252.0,
  #  "errors"=>{"Email"=>"The Email field is required."},
  #  "Code"=>"400",
  #  "Url"=>"/v2/sdk-unit-tests/users/natural"}
  #  
  # #<MangoPay::ResponseError: Internal Server Error>
  # {"Message"=>"Internal Server Error",
  #  "Type"=>"other",
  #  "Id"=>"7bdc5c6f-2000-4cd3-96f3-2a3fcb746f07",
  #  "Date"=>1409047251.0,
  #  "errors"=>nil,
  #  "Code"=>"500",
  #  "Url"=>"/v2/sdk-unit-tests/payins/3380640/refunds"}  
  class ResponseError < Error

    attr_reader :request_url, :code, :details

    def initialize(request_url, code, details)
      @request_url, @code, @details = request_url, code, details

      @details['Code'] = code
      @details['Url'] = request_url.request_uri

      super(message) if message
    end

    def type;    @details['Type']; end
    def error;   @details['error']; end
    def errors;  @details['errors'] || error; end

    def message;
      if error
        msg = error
      else
        msg = @details['Message']
        msg += errors.sort.map {|k,v| " #{k}: #{v}"}.join if (errors && errors.is_a?(Hash))
        msg
      end
    end

  end
end

module ExceptionalMiddleware::Test
  class BasicRemoteException < RemotelyExceptional::RemoteException
    attr_accessor :action, :continue_value, :raise_exception
  end
end
